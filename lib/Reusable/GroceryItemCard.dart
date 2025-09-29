import 'package:flutter/material.dart';
import '../Data/DataModel.dart';
import 'EditItemPage.dart';

class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;
  final Function(String)? onDelete;

  const GroceryItemCard({
    super.key,
    required this.item,
    this.onDelete,
  });

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
        return Colors.green; // Low urgency color
      case 'medium':
        return Colors.orange; // Medium urgency color
      case 'high':
        return Colors.red; // High urgency color
      default:
        return Colors.grey; // Default color for unknown urgency
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = item.itemData?.isCompleted ?? false;
    
    // Get the name of the user who added the item
    String addedBy = item.itemData?.addedBy ?? 'Unknown User';
    String userName = addedBy.split('@').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(item.key!),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.delete,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
        onDismissed: (direction) {
          if (onDelete != null) {
            onDelete!(item.key!);
          }
        },
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Delete Item'),
                content: Text('Are you sure you want to delete "${item.itemData?.name ?? 'this item'}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              );
            },
          );
        },
        child: Material(
          elevation: isCompleted ? 1 : 2,
          borderRadius: BorderRadius.circular(12),
          color: isCompleted 
              ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
              : colorScheme.surface,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getUrgencyColor(item.itemData?.urgency ?? 'low').withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Main row with title, quantity, and priority
                  Row(
                    children: [
                      // Item name and quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.itemData?.name ?? 'No Name',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isCompleted 
                                    ? colorScheme.onSurfaceVariant 
                                    : colorScheme.onSurface,
                                decoration: isCompleted 
                                    ? TextDecoration.lineThrough 
                                    : null,
                              ),
                            ),
                            Text(
                              'Qty: ${item.itemData?.quantity ?? 0}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Priority indicator
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(item.itemData?.urgency ?? 'low'),
                          shape: BoxShape.circle,
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Edit button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditItemPage(item: item),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Secondary info row (optional - only show if there's additional info)
                  if (item.itemData?.category != null || 
                      (item.itemData?.tags != null && item.itemData!.tags!.isNotEmpty) ||
                      item.itemData?.isSynced == false) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Category
                        if (item.itemData?.category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.itemData!.category!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        
                        // First tag only
                        if (item.itemData?.tags != null && item.itemData!.tags!.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.itemData!.tags!.first,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.secondary,
                              ),
                            ),
                          ),
                          if (item.itemData!.tags!.length > 1) ...[
                            const SizedBox(width: 4),
                            Text(
                              '+${item.itemData!.tags!.length - 1}',
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                        
                        const Spacer(),
                        
                        // Sync status
                        if (item.itemData?.isSynced == false) ...[
                          Icon(
                            Icons.cloud_off,
                            size: 12,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4),
                        ],
                        
                        // User name
                        Text(
                          userName,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
