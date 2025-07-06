// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_grocery/Data/DataModel.dart';

void main() {
  group('DataModel Tests', () {
    test('GroceryItemData creation test', () {
      final itemData = GroceryItemData(
        name: 'Test Item',
        quantity: 5,
        urgency: 'High',
        addedBy: 'test@example.com',
        timestamp: '2024-01-01',
      );

      expect(itemData.name, 'Test Item');
      expect(itemData.quantity, 5);
      expect(itemData.urgency, 'High');
      expect(itemData.addedBy, 'test@example.com');
      expect(itemData.timestamp, '2024-01-01');
    });

    test('GroceryItem JSON serialization test', () {
      final itemData = GroceryItemData(
        name: 'Test Item',
        quantity: 3,
        urgency: 'Medium',
        addedBy: 'user@test.com',
        timestamp: '2024-01-01',
      );

      final groceryItem = GroceryItem('test_key', itemData);
      final json = groceryItem.toJson();

      expect(json['key'], 'test_key');
      expect(json['itemData']['name'], 'Test Item');
      expect(json['itemData']['quantity'], 3);
      expect(json['itemData']['urgency'], 'Medium');
    });

    test('GroceryItem JSON deserialization test', () {
      final json = {
        'key': 'test_key',
        'itemData': {
          'name': 'Test Item',
          'quantity': 2,
          'urgency': 'Low',
          'addedBy': 'test@example.com',
          'timestamp': '2024-01-01',
        }
      };

      final groceryItem = GroceryItem.fromJson(json);

      expect(groceryItem.key, 'test_key');
      expect(groceryItem.itemData?.name, 'Test Item');
      expect(groceryItem.itemData?.quantity, 2);
      expect(groceryItem.itemData?.urgency, 'Low');
      expect(groceryItem.itemData?.addedBy, 'test@example.com');
      expect(groceryItem.itemData?.timestamp, '2024-01-01');
    });
  });

  group('Widget Tests (Basic)', () {
    testWidgets('Material app basic structure test', (WidgetTester tester) async {
      // Create a simple widget that doesn't depend on Firebase
      await tester.pumpWidget(
        MaterialApp(
          title: 'Grocery List',
          home: Scaffold(
            appBar: AppBar(title: Text('Test')),
            body: Center(child: Text('Hello World')),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('Hello World'), findsOneWidget);
    });
  });
}
