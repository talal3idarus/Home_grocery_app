import 'package:flutter/material.dart';
import '../Data/DataModel.dart';
import 'package:intl/intl.dart'; // Import this for date formatting

class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;

  const GroceryItemCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
        return Colors.green; // Low urgency color
      case 'medium':
        return Colors.yellow; // Medium urgency color
      case 'high':
        return Colors.red; // High urgency color
      default:
        return Colors.grey; // Default color for unknown urgency
    }
  }

  @override
  Widget build(BuildContext context) {
    // Parse the timestamp string back to a DateTime object
    String formattedTimestamp = item.itemData?.timestamp ?? 'No Date'; // Default if timestamp is null
    if (formattedTimestamp != 'No Date') {
      // Optionally format the date to a more readable format
      DateTime dateTime = DateTime.parse(formattedTimestamp);
      formattedTimestamp = DateFormat('yyyy-MM-dd').format(dateTime);
    }

    // Get the name of the user who added the item, extracting the part before '@gmail.com'
    String addedBy = item.itemData?.addedBy ?? 'Unknown User';
    String userName = addedBy.split('@').first; // Get the part before '@'

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          item.itemData?.name ?? 'No Name',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ), // Display grocery item name
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            Text(
              'Quantity: ${item.itemData?.quantity ?? 0}', // Display quantity and timestamp
            ),
            SizedBox(height: 4), // Add some space between the lines
            Text(
              'Added By: $userName |  Date: $formattedTimestamp', // Display who added the item, before @
              style: TextStyle(fontStyle: FontStyle.italic), // Optional: make it italic
            ),
          ],
        ),
        trailing: Container(
          width: 40, // Fixed width for the urgency box
          height: 40, // Fixed height for the urgency box
          decoration: BoxDecoration(
            color: _getUrgencyColor(item.itemData?.urgency ?? 'Unknown'), // Get color based on urgency
            shape: BoxShape.circle, // Make it circular
          ),
        ),
      ),
    );
  }
}
