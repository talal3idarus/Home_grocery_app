import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Data/ConnectivityService.dart';
import '../Data/ThemeProvider.dart';
import '../Reusable/AnimatedGroceryItemCard.dart';
import '../Reusable/AddItemPage.dart';
import '../Reusable/PageTransitions.dart';
import '../Reusable/AnimatedLoadingWidget.dart';
import '../Reusable/AnimatedDialog.dart';
import '../Screens/Login.dart';
import '../Data/Auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ConnectivityService _connectivity = ConnectivityService();
  List<GroceryItem> _productList = []; // Initialize your product list
  bool _isLoading = true; // Flag to manage loading state
  String _searchQuery = ""; // For handling search queries
  String? _selectedUrgency; // For handling urgency filter
  String? _selectedCategory; // For handling category filter
  List<Map<String, dynamic>> _categories = [];
  bool _isConnected = true;
  bool _isSelectionMode = false; // For bulk operations
  Set<String> _selectedItems = {}; // Selected item keys
  
  // Animation controllers
  late AnimationController _fabAnimationController;
  late AnimationController _categoryFilterAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _categoryFilterSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _categoryFilterAnimationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Initialize animations
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _categoryFilterSlideAnimation = Tween<Offset>(
      begin: Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _categoryFilterAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Fetch grocery items when the page loads
    _fetchGroceryItems();
    _loadCategories();
    _checkConnectivity();
    // Try to sync unsynced items
    _databaseHelper.syncUnsyncedItems();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
    
    // Start animations
    _fabAnimationController.forward();
    _categoryFilterAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _categoryFilterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    bool connected = await _connectivity.isConnected();
    setState(() {
      _isConnected = connected;
    });
    if (connected) {
      _databaseHelper.syncUnsyncedItems();
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  // Method to fetch grocery items from the database
  void _fetchGroceryItems() async {
    try {
      await _databaseHelper.readFirebaseRealtimeDBMain((groceryList) {
        setState(() {
          _productList = groceryList;
          _isLoading = false;
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AnimatedDialog.showError(
        context: context,
        message: 'Error fetching items: $e',
      );
    }
  }

  // Filter items by search query, selected urgency, and category
  List<GroceryItem> _filterItems(String query, String? urgency, String? category) {
    return _productList.where((item) {
      bool matchesUrgency = urgency == null || item.itemData!.urgency == urgency;
      bool matchesCategory = category == null || item.itemData!.category == category;
      
      // Enhanced search: name, category, and tags
      String searchTarget = '${item.itemData!.name} ${item.itemData!.category ?? ''} ${item.itemData!.tags?.join(' ') ?? ''}'.toLowerCase();
      bool matchesQuery = searchTarget.contains(query.toLowerCase());
      
      return matchesUrgency && matchesCategory && matchesQuery;
    }).toList();
  }

  // Method to delete a grocery item
  void _deleteGroceryItem(String key) async {
    await _databaseHelper.deleteGroceryItem(key);
    _fetchGroceryItems();
  }

  // Method to toggle item completion
  void _toggleItemCompletion(String key, bool isCompleted) async {
    await _databaseHelper.toggleItemCompletion(key, isCompleted);
    _fetchGroceryItems(); // Refresh the list
  }

  // Method to toggle selection mode
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  // Method to toggle item selection
  void _toggleItemSelection(String key) {
    setState(() {
      if (_selectedItems.contains(key)) {
        _selectedItems.remove(key);
      } else {
        _selectedItems.add(key);
      }
    });
  }

  // Method to delete selected items
  void _bulkDelete() async {
    bool? confirmed = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Delete Selected Items',
      message: 'Are you sure you want to delete ${_selectedItems.length} selected items? This action cannot be undone.',
      confirmText: 'Delete All',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
      icon: Icons.delete_sweep,
    );
    
    if (confirmed != true) return;
    
    int deletedCount = _selectedItems.length;
    for (String key in _selectedItems) {
      await _databaseHelper.deleteGroceryItem(key);
    }
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
    _fetchGroceryItems();
    AnimatedDialog.showSuccess(
      context: context,
      message: '$deletedCount items deleted',
    );
  }

  // Method to mark selected items as completed
  void _bulkComplete() async {
    bool? confirmed = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Complete Selected Items',
      message: 'Mark ${_selectedItems.length} selected items as completed?',
      confirmText: 'Mark Complete',
      cancelText: 'Cancel',
      confirmColor: Colors.green,
      icon: Icons.check_circle_outline,
    );
    
    if (confirmed != true) return;
    
    int completedCount = _selectedItems.length;
    for (String key in _selectedItems) {
      await _databaseHelper.toggleItemCompletion(key, true);
    }
    setState(() {
      _selectedItems.clear();
      _isSelectionMode = false;
    });
    _fetchGroceryItems();
    AnimatedDialog.showSuccess(
      context: context,
      message: '$completedCount items marked as completed',
    );
  }

  // Method to handle logout action
  void _logout() async {
    bool? confirmed = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
      confirmColor: Colors.orange,
      icon: Icons.logout,
    );
    
    if (confirmed != true) return;
    
    try {
      await Auth().signOut();
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Logged out successfully',
        onPressed: () {
          // Navigate to the login page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      );
    } catch (e) {
      AnimatedDialog.showError(
        context: context,
        message: 'Error logging out: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GroceryItem> displayedItems = _filterItems(_searchQuery, _selectedUrgency, _selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List', style: TextStyle(fontSize: 30)),
        centerTitle: true,
        leading: IconButton( // Add leading icon button for logout
          icon: Icon(Icons.logout),
          onPressed: _logout, // Call the logout method
        ),
        actions: [
          // Bulk selection toggle button
          IconButton(
            icon: Icon(
              _isSelectionMode ? Icons.check_circle : Icons.select_all,
              color: _isSelectionMode ? Colors.blue : null,
            ),
            onPressed: _toggleSelectionMode,
          ),
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          // Connection status indicator
          Container(
            margin: EdgeInsets.only(right: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done : Icons.cloud_off,
                  color: _isConnected ? Colors.green : Colors.orange,
                  size: 20,
                ),
                SizedBox(width: 4),
                Text(
                  _isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isConnected ? Colors.green : Colors.orange,
                  ),
                ),
                if (!_isConnected) ...[
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.sync, size: 20),
                    onPressed: () async {
                      await _checkConnectivity();
                      if (_isConnected) {
                        AnimatedDialog.showInfo(
                          context: context,
                          title: 'Syncing',
                          message: 'Syncing your data with the server...',
                          onPressed: () async {
                            await _databaseHelper.syncUnsyncedItems();
                            AnimatedDialog.showSuccess(
                              context: context,
                              message: 'Sync completed successfully!',
                            );
                          },
                        );
                      } else {
                        AnimatedDialog.showWarning(
                          context: context,
                          message: 'No internet connection. Please check your network and try again.',
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.1),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Category filter
          if (_categories.isNotEmpty)
            SlideTransition(
              position: _categoryFilterSlideAnimation,
              child: Container(
                height: 60,
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Categories:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length + 1, // +1 for "All" option
                        itemBuilder: (context, index) {
                        if (index == 0) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = null;
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _selectedCategory == null ? Colors.blue : Colors.grey[200],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'All',
                                style: TextStyle(
                                  color: _selectedCategory == null ? Colors.white : Colors.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }
                        final category = _categories[index - 1];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedCategory = _selectedCategory == category['name'] ? null : category['name'];
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedCategory == category['name'] ? Colors.blue : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(category['icon'] ?? '📦', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                    color: _selectedCategory == category['name'] ? Colors.white : Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ),
          // Row for urgency levels (Now clickable)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _UrgencyColumn(
                  label: 'Low',
                  color: Colors.green,
                  isSelected: _selectedUrgency == 'Low',
                  onTap: () {
                    setState(() {
                      _selectedUrgency = _selectedUrgency == 'Low' ? null : 'Low';
                    });
                  },
                ),
                _UrgencyColumn(
                  label: 'Medium',
                  color: Colors.yellow,
                  isSelected: _selectedUrgency == 'Medium',
                  onTap: () {
                    setState(() {
                      _selectedUrgency = _selectedUrgency == 'Medium' ? null : 'Medium';
                    });
                  },
                ),
                _UrgencyColumn(
                  label: 'High',
                  color: Colors.red,
                  isSelected: _selectedUrgency == 'High',
                  onTap: () {
                    setState(() {
                      _selectedUrgency = _selectedUrgency == 'High' ? null : 'High';
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? AnimatedLoadingWidget(
                    message: 'Loading your grocery list...',
                  ) // Show animated loading spinner
                : displayedItems.isEmpty
                ? Center(
                    child: TweenAnimationBuilder<double>(
                      duration: Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Opacity(
                            opacity: value,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No items found.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tap the + button to add your first item!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ) // Animated empty state message
                : RefreshIndicator(
                    onRefresh: () async {
                      _fetchGroceryItems();
                    },
                    child: ListView.builder(
                      itemCount: displayedItems.length,
                      itemBuilder: (context, index) {
                        final item = displayedItems[index];
                        return Dismissible(
                          key: Key(item.key!), // Unique key for each item
                          direction: DismissDirection.endToStart, // Swipe from right to left
                          background: Container(
                            color: Colors.red, // Background color when swiping
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.only(right: 20),
                            child: Icon(Icons.delete, color: Colors.white), // Delete icon
                          ),
                          confirmDismiss: (direction) async {
                            // Show animated confirmation dialog
                            return await AnimatedDialog.showConfirmation(
                              context: context,
                              title: 'Confirm Delete',
                              message: 'Are you sure you want to delete ${item.itemData?.name}?',
                              confirmText: 'Delete',
                              cancelText: 'Cancel',
                              confirmColor: Colors.red,
                              icon: Icons.delete_outline,
                            );
                          },
                          onDismissed: (direction) {
                            String itemName = item.itemData?.name ?? 'Item';
                            _deleteGroceryItem(item.key!); // Call the delete method
                            AnimatedDialog.showSuccess(
                              context: context,
                              message: '$itemName deleted',
                            );
                          },
                          child: GestureDetector(
                            onTap: _isSelectionMode 
                                ? () => _toggleItemSelection(item.key!)
                                : null,
                            child: Container(
                              decoration: _isSelectionMode && _selectedItems.contains(item.key!)
                                  ? BoxDecoration(
                                      border: Border.all(color: Colors.blue, width: 2),
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                              child: AnimatedGroceryItemCard(
                                item: item,
                                index: index,
                                onToggleCompletion: _isSelectionMode ? null : _toggleItemCompletion,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to AddItemPage with custom page transition animation
            Navigator.push(
              context,
              SlidePageRoute(child: AddItemPage()),
            );
          },
          child: Icon(Icons.add),
        ),
      ),
      bottomNavigationBar: _isSelectionMode && _selectedItems.isNotEmpty 
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _bulkComplete,
                    icon: Icon(Icons.check_circle),
                    label: Text('Complete ${_selectedItems.length}'),
                  ),
                  TextButton.icon(
                    onPressed: _bulkDelete,
                    icon: Icon(Icons.delete),
                    label: Text('Delete ${_selectedItems.length}'),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

// Widget to represent each urgency level with a color box and click handler
class _UrgencyColumn extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _UrgencyColumn({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handles tap events
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(isSelected ? 1.0 : 0.5), // Highlight selected urgency
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.black, width: 2) : null, // Add border if selected
            ),
          ),
          SizedBox(height: 8), // Space between the box and the label
          Text(label),
        ],
      ),
    );
  }
}
