import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import "../Data/DataModel.dart";
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AnimatedDialog.dart';


class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String _selectedUrgency = 'Low';
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
      if (_categories.isNotEmpty) {
        _selectedCategory = _categories.first['name'];
      }
    });
  }

 void _addItem() async {
    String name = _nameController.text.trim();
    int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    List<String> tags = _tagsController.text.trim().isEmpty 
        ? [] 
        : _tagsController.text.trim().split(',').map((e) => e.trim()).toList();

    if (name.isEmpty || quantity <= 0) {
      AnimatedDialog.showWarning(
        context: context,
        message: 'Please enter valid item details.',
      );
      return;
    }
    
    final User? user = FirebaseAuth.instance.currentUser;
    String? addedBy = user?.email;
    
    GroceryItemData newItemData = GroceryItemData(
      name: name,
      quantity: quantity,
      urgency: _selectedUrgency,
      addedBy: addedBy,
      timestamp: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      category: _selectedCategory,
      tags: tags.isEmpty ? null : tags,
      isCompleted: false,
      isSynced: true,
    );

    try {
      await _databaseHelper.addNewGroceryItem(newItemData);
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Item added successfully!',
        onPressed: () {
          _nameController.clear();
          _quantityController.clear();
          _tagsController.clear();
          Navigator.pop(context);
        },
      );
    } catch (e) {
      AnimatedDialog.showError(
        context: context,
        message: 'Failed to add item: $e',
      );
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Item')),
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
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _addItem,
                child: const Text('Add Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
