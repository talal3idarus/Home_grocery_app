import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import "../Data/DataModel.dart";
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  _AddItemPageState createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUrgency = 'Low';

  final DatabaseHelper _databaseHelper = DatabaseHelper();

 void _addItem() async {
    String name = _nameController.text.trim();
    int quantity = int.tryParse(_quantityController.text.trim()) ?? 0;

    if (name.isEmpty || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid item details.')),
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
  timestamp: DateFormat('yyyy-MM-dd').format(DateTime.now()), // Store as a formatted string
);

    try {
      await _databaseHelper.addNewGroceryItem(newItemData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item added successfully!')),
      );
      _nameController.clear();
      _quantityController.clear();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item: $e')),
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
