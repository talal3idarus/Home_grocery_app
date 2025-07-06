import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Data/ConnectivityService.dart';
import '../Data/Auth.dart';
import '../Data/HistoryProvider.dart';
import '../Data/NotificationService.dart';
import '../Reusable/AnimatedGroceryItemCard.dart';
import '../Reusable/AddItemPage.dart';
import '../Reusable/PageTransitions.dart';
import '../Reusable/AnimatedLoadingWidget.dart';
import '../Reusable/AnimatedDialog.dart';
import '../Screens/Login.dart';
import '../Screens/Settings.dart';
import '../Screens/ShoppingHistoryPage.dart';
import '../Screens/NotificationsPage.dart';
import 'package:provider/provider.dart';

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

  // Method to build the navigation drawer
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.shopping_cart,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Grocery App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      color: _isConnected ? Colors.white : Colors.red[200],
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      _isConnected ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: _isConnected ? Colors.white : Colors.red[200],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Sync Data
          ListTile(
            leading: Icon(Icons.sync),
            title: Text('Sync Data'),
            subtitle: Text('Sync with server'),
            onTap: () async {
              Navigator.pop(context); // Close drawer
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
          
          Divider(),
          
          // Notifications
          Consumer<NotificationService>(
            builder: (context, notificationService, child) {
              final unreadCount = notificationService.unreadCount;
              return ListTile(
                leading: Stack(
                  children: [
                    Icon(Icons.notifications),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text('Notifications'),
                subtitle: Text(unreadCount > 0 ? '$unreadCount new' : 'All caught up'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    SlidePageRoute(child: NotificationsPage()),
                  );
                },
              );
            },
          ),
          
          // Shopping History & Analytics
          ListTile(
            leading: Icon(Icons.analytics),
            title: Text('Shopping Analytics'),
            subtitle: Text('View your shopping history & insights'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                SlidePageRoute(child: ShoppingHistoryPage()),
              );
            },
          ),
          
          Divider(),
          
          // Settings
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            subtitle: Text('App preferences & configuration'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                SlidePageRoute(child: SettingsPage()),
              );
            },
          ),
          
          // About
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('About'),
            subtitle: Text('App information'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              AnimatedDialog.showInfo(
                context: context,
                title: 'About Grocery App',
                message: 'A modern grocery list app with offline support, categories, and smart features.\n\nVersion 1.0.0\nBuilt with Flutter',
              );
            },
          ),
          
          Divider(),
          
          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.orange),
            title: Text('Logout', style: TextStyle(color: Colors.orange)),
            subtitle: Text('Sign out of your account'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _logout();
            },
          ),
        ],
      ),
    );
  }

  // Method to track completed shopping session
  void _trackCompletedItems() async {
    final completedItems = _productList.where((item) => item.itemData?.isCompleted == true).toList();
    
    if (completedItems.isNotEmpty) {
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.addShoppingSession(completedItems);
      
      // Remove completed items from the current list
      for (final item in completedItems) {
        if (item.key != null) {
          await _databaseHelper.deleteGroceryItem(item.key!);
        }
      }
      
      _fetchGroceryItems(); // Refresh the list
      
      AnimatedDialog.showSuccess(
        context: context,
        message: '${completedItems.length} items completed and added to history!',
      );
    }
  }

  // Helper method to build category filter pills
  List<Widget> _buildCategoryFilters(bool isDark) {
    List<Widget> filters = [];
    
    // Add "All" filter
    filters.add(_buildFilterPill(
      label: 'All',
      isSelected: _selectedCategory == null,
      onTap: () {
        setState(() {
          _selectedCategory = null;
        });
      },
      isDark: isDark,
    ));
    
    // Add category filters
    for (final category in _categories) {
      filters.add(_buildFilterPill(
        label: category['name'],
        emoji: category['icon'],
        isSelected: _selectedCategory == category['name'],
        onTap: () {
          setState(() {
            _selectedCategory = _selectedCategory == category['name'] ? null : category['name'];
          });
        },
        isDark: isDark,
      ));
    }
    
    return filters;
  }

  // Helper method to build urgency filter pills
  List<Widget> _buildUrgencyFilters(bool isDark) {
    final urgencies = [
      {'label': 'Low', 'color': Colors.green},
      {'label': 'Medium', 'color': Colors.orange},
      {'label': 'High', 'color': Colors.red},
    ];
    
    return urgencies.map((urgency) {
      final isSelected = _selectedUrgency == urgency['label'];
      return _buildFilterPill(
        label: urgency['label'] as String,
        color: urgency['color'] as Color,
        isSelected: isSelected,
        onTap: () {
          setState(() {
            _selectedUrgency = isSelected ? null : urgency['label'] as String;
          });
        },
        isDark: isDark,
      );
    }).toList();
  }

  // Helper method to build individual filter pills
  Widget _buildFilterPill({
    required String label,
    String? emoji,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected 
                ? (color ?? Theme.of(context).primaryColor)
                : (isDark ? Colors.grey[800] : Colors.grey[200]),
            borderRadius: BorderRadius.circular(20),
            border: isSelected && color == null 
                ? null 
                : Border.all(
                    color: color?.withOpacity(0.3) ?? Colors.transparent,
                    width: 1,
                  ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null) ...[
                Text(emoji, style: TextStyle(fontSize: 14)),
                SizedBox(width: 6),
              ],
              if (color != null && !isSelected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected 
                      ? Colors.white
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build empty state
  Widget _buildEmptyState(bool isDark) {
    return Center(
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 40,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Your grocery list is empty',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first item to get started',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(child: AddItemPage()),
                      );
                    },
                    icon: Icon(Icons.add_rounded),
                    label: Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper method to build grocery item cards
  Widget _buildGroceryItemCard(GroceryItem item, int index, bool isDark) {
    final isSelected = _isSelectionMode && _selectedItems.contains(item.key!);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Dismissible(
        key: Key(item.key!),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.delete_rounded, color: Colors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          return await AnimatedDialog.showConfirmation(
            context: context,
            title: 'Delete Item',
            message: 'Remove "${item.itemData?.name}" from your list?',
            confirmText: 'Delete',
            cancelText: 'Cancel',
            confirmColor: Colors.red,
            icon: Icons.delete_outline_rounded,
          );
        },
        onDismissed: (direction) {
          String itemName = item.itemData?.name ?? 'Item';
          _deleteGroceryItem(item.key!);
          AnimatedDialog.showSuccess(
            context: context,
            message: '$itemName removed',
          );
        },
        child: GestureDetector(
          onTap: _isSelectionMode 
              ? () => _toggleItemSelection(item.key!)
              : null,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            margin: EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedGroceryItemCard(
              item: item,
              index: index,
              onToggleCompletion: _isSelectionMode ? null : _toggleItemCompletion,
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build floating action buttons
  Widget _buildFloatingActionButtons() {
    final hasCompletedItems = _productList.any((item) => item.itemData?.isCompleted == true);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (hasCompletedItems) ...[
          FloatingActionButton.extended(
            onPressed: _trackCompletedItems,
            icon: Icon(Icons.shopping_bag_rounded),
            label: Text('Complete Shopping'),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            heroTag: "complete",
            elevation: 8,
          ),
          SizedBox(height: 16),
        ],
        FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              SlidePageRoute(child: AddItemPage()),
            );
          },
          child: Icon(Icons.add_rounded),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          elevation: 8,
          heroTag: "add",
        ),
      ],
    );
  }

  // Helper method to build bottom action bar
  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkComplete,
                  icon: Icon(Icons.check_circle_rounded),
                  label: Text('Complete (${_selectedItems.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _bulkDelete,
                  icon: Icon(Icons.delete_rounded),
                  label: Text('Delete (${_selectedItems.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
