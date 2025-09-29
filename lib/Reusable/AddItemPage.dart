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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _nameController.clear();
              _quantityController.clear();
              _tagsController.clear();
              setState(() {
                _selectedUrgency = 'Low';
                if (_categories.isNotEmpty) {
                  _selectedCategory = _categories.first['name'];
                }
              });
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                          Text(
                            'Item Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Item Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Item Name',
                              hintText: 'e.g., Milk, Bread, Apples...',
                              prefixIcon: Icon(Icons.label),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Quantity
                          TextFormField(
                            controller: _quantityController,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: 'Enter number',
                              prefixIcon: Icon(Icons.numbers),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Tags
                          TextFormField(
                            controller: _tagsController,
                            decoration: const InputDecoration(
                              labelText: 'Tags (optional)',
                              hintText: 'organic, healthy, sale...',
                              prefixIcon: Icon(Icons.tag),
                              border: OutlineInputBorder(),
                              helperText: 'Separate with commas',
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'Classification',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Category Dropdown
                          if (_categories.isNotEmpty)
                            DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category),
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
                                  child: Text('${category['icon'] ?? '📦'} ${category['name']}'),
                                );
                              }).toList(),
                            ),
                          
                          const SizedBox(height: 16),
                          
                          // Priority Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedUrgency,
                            decoration: const InputDecoration(
                              labelText: 'Priority Level',
                              prefixIcon: Icon(Icons.priority_high),
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedUrgency = newValue!;
                              });
                            },
                            items: const [
                              DropdownMenuItem<String>(
                                value: 'Low',
                                child: Text('🟢 Low Priority'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'Medium',
                                child: Text('🟡 Medium Priority'),
                              ),
                              DropdownMenuItem<String>(
                                value: 'High',
                                child: Text('🔴 High Priority'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          
          // Add Button (Fixed at bottom)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Grocery List'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
