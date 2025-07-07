import 'package:flutter/material.dart';
import '../Data/DataModel.dart';
import 'package:intl/intl.dart'; // Import this for date formatting
import 'EditItemPage.dart';

class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;
  final Function(String, bool)? onToggleCompletion;

  const GroceryItemCard({
    super.key,
    required this.item,
    this.onToggleCompletion,
  });

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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: item.itemData?.isCompleted == true 
          ? Colors.grey.withOpacity(0.3) 
          : null,
      child: ListTile(
        leading: Checkbox(
          value: item.itemData?.isCompleted ?? false,
          onChanged: onToggleCompletion != null 
              ? (value) => onToggleCompletion!(item.key!, value ?? false)
              : null,
        ),
        title: Text(
          item.itemData?.name ?? 'No Name',
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold,
            decoration: item.itemData?.isCompleted == true 
                ? TextDecoration.lineThrough 
                : null,
            color: item.itemData?.isCompleted == true 
                ? Colors.grey 
                : null,
          ),
        ), // Display grocery item name
        subtitle: Opacity(
          opacity: item.itemData?.isCompleted == true ? 0.6 : 1.0,        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            Text(
              'Quantity: ${item.itemData?.quantity ?? 0}', // Display quantity
            ),
            if (item.itemData?.category != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.category, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.itemData!.category!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
              if (item.itemData?.tags != null && item.itemData!.tags!.isNotEmpty) ...[
                SizedBox(height: 4),
                Wrap(
                  spacing: 4.0,
                  children: item.itemData!.tags!.map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(fontSize: 10, color: Colors.blue[700]),
                      ),
                    );
                  }).toList(),
                ),
              ],
              SizedBox(height: 4), // Add some space between the lines
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Added By: $userName | Date: $formattedTimestamp', 
                      style: TextStyle(fontStyle: FontStyle.italic, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (item.itemData?.isSynced == false) ...[
                    SizedBox(width: 4),
                    Icon(Icons.sync_disabled, size: 12, color: Colors.orange),
                    Text('Offline', style: TextStyle(fontSize: 10, color: Colors.orange)),
                  ],
                ],
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditItemPage(item: item),
                  ),
                );
              },
              icon: Icon(Icons.edit, color: Colors.blue),
            ),
            Container(
              width: 40, // Fixed width for the urgency box
              height: 40, // Fixed height for the urgency box
              decoration: BoxDecoration(
                color: _getUrgencyColor(item.itemData?.urgency ?? 'Unknown'), // Get color based on urgency
                shape: BoxShape.circle, // Make it circular
              ),
            ),
          ],
        ),
      ),
    );
  }
}
