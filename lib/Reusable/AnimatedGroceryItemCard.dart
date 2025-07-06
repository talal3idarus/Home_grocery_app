import 'package:flutter/material.dart';
import '../Data/DataModel.dart';
import 'package:intl/intl.dart';
import 'EditItemPage.dart';

class AnimatedGroceryItemCard extends StatefulWidget {
  final GroceryItem item;
  final Function(String, bool)? onToggleCompletion;
  final int index;

  const AnimatedGroceryItemCard({
    Key? key,
    required this.item,
    this.onToggleCompletion,
    required this.index,
  }) : super(key: key);

  @override
  State<AnimatedGroceryItemCard> createState() => _AnimatedGroceryItemCardState();
}

class _AnimatedGroceryItemCardState extends State<AnimatedGroceryItemCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600 + (widget.index * 100)),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
    
    // Start animation with delay based on index
    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) {
        _slideController.forward();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.yellow;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedTimestamp = widget.item.itemData?.timestamp ?? 'No Date';
    if (formattedTimestamp != 'No Date') {
      DateTime dateTime = DateTime.parse(formattedTimestamp);
      formattedTimestamp = DateFormat('yyyy-MM-dd').format(dateTime);
    }

    String addedBy = widget.item.itemData?.addedBy ?? 'Unknown User';
    String userName = addedBy.split('@').first;

    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: widget.item.itemData?.isCompleted == true 
                    ? Colors.grey.withOpacity(0.3) 
                    : null,
                child: ListTile(
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Checkbox(
                      value: widget.item.itemData?.isCompleted ?? false,
                      onChanged: widget.onToggleCompletion != null 
                          ? (value) => widget.onToggleCompletion!(widget.item.key!, value ?? false)
                          : null,
                    ),
                  ),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 20, 
                      fontWeight: FontWeight.bold,
                      decoration: widget.item.itemData?.isCompleted == true 
                          ? TextDecoration.lineThrough 
                          : null,
                      color: widget.item.itemData?.isCompleted == true 
                          ? Colors.grey 
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    child: Text(widget.item.itemData?.name ?? 'No Name'),
                  ),
                  subtitle: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: widget.item.itemData?.isCompleted == true ? 0.6 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quantity: ${widget.item.itemData?.quantity ?? 0}'),
                        if (widget.item.itemData?.category != null) ...[
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.category, size: 14, color: Colors.grey),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.item.itemData!.category!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (widget.item.itemData?.tags != null && widget.item.itemData!.tags!.isNotEmpty) ...[
                          SizedBox(height: 4),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            child: Wrap(
                              spacing: 4.0,
                              children: widget.item.itemData!.tags!.map((tag) {
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 300 + (widget.item.itemData!.tags!.indexOf(tag) * 50)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: Container(
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
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        SizedBox(height: 4),
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
                            if (widget.item.itemData?.isSynced == false) ...[
                              SizedBox(width: 4),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.sync_disabled, size: 12, color: Colors.orange),
                                    Text('Offline', style: TextStyle(fontSize: 10, color: Colors.orange)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) => EditItemPage(item: widget.item),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                          icon: Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _getUrgencyColor(widget.item.itemData?.urgency ?? 'Unknown'),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
