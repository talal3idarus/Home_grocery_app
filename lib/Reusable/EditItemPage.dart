import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import "../Data/DataModel.dart";
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AnimatedDialog.dart';

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
      AnimatedDialog.showWarning(
        context: context,
        message: 'Please enter valid item details.',
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
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Item updated successfully!',
        onPressed: () {
          Navigator.pop(context);
        },
      );
    } catch (e) {
      AnimatedDialog.showError(
        context: context,
        message: 'Failed to update item: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              // Reset to original values
              _nameController.text = widget.item.itemData?.name ?? '';
              _quantityController.text = widget.item.itemData?.quantity.toString() ?? '';
              _tagsController.text = widget.item.itemData?.tags?.join(', ') ?? '';
              setState(() {
                _selectedUrgency = widget.item.itemData?.urgency ?? 'Low';
                _selectedCategory = widget.item.itemData?.category;
              });
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Form',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
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
                ],
              ),
            ),
            
            // Update Button (Fixed at bottom)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _updateItem,
                  icon: const Icon(Icons.save),
                  label: const Text('Update Item'),
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
