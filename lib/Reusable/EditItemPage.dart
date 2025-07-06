import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import "../Data/DataModel.dart";
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditItemPage extends StatefulWidget {
  final GroceryItem item;
  
  const EditItemPage({super.key, required this.item});

  @override
  _EditItemPageState createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late TextEditingController _nameController;
  late TextEditingController _quantityController;
  late TextEditingController _tagsController;
  late String _selectedUrgency;
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.itemData?.name ?? '');
    _quantityController = TextEditingController(text: widget.item.itemData?.quantity.toString() ?? '');
    _tagsController = TextEditingController(text: widget.item.itemData?.tags?.join(', ') ?? '');
    _selectedUrgency = widget.item.itemData?.urgency ?? 'Low';
    _selectedCategory = widget.item.itemData?.category;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
      if (_selectedCategory == null && _categories.isNotEmpty) {
        _selectedCategory = _categories.first['name'];
      }
    });
  }

  void _updateItem() async {
    String name = _nameController.text.trim();
    int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    List<String> tags = _tagsController.text.trim().isEmpty 
        ? [] 
        : _tagsController.text.trim().split(',').map((e) => e.trim()).toList();

    if (name.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid item details.')),
      );
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    String? addedBy = user?.email;
    
    GroceryItemData updatedItemData = GroceryItemData(
      name: name,
      quantity: quantity,
      urgency: _selectedUrgency,
      addedBy: addedBy,
      timestamp: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      category: _selectedCategory,
      tags: tags.isEmpty ? null : tags,
      isCompleted: widget.item.itemData?.isCompleted ?? false,
      isSynced: false, // Mark as unsynced since it's been modified
    );

    try {
      await _databaseHelper.updateGroceryItem(widget.item.key!, updatedItemData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update item: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma separated)',
                border: OutlineInputBorder(),
                hintText: 'organic, healthy, sale',
              ),
            ),
            const SizedBox(height: 16.0),
            if (_categories.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                items: _categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['name'],
                    child: Row(
                      children: [
                        Text(category['icon'] ?? '📦'),
                        const SizedBox(width: 8),
                        Text(category['name']),
                      ],
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedUrgency,
              decoration: const InputDecoration(
                labelText: 'Urgency',
                border: OutlineInputBorder(),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedUrgency = newValue!;
                });
              },
              items: <String>['Low', 'Medium', 'High']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _updateItem,
              child: const Text('Update Item'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
