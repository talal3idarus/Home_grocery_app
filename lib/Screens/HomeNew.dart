import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
  List<GroceryItem> _productList = [];
  bool _isLoading = true;
  String _searchQuery = "";
  String? _selectedUrgency;
  String? _selectedCategory;
  List<Map<String, dynamic>> _categories = [];
  bool _isConnected = true;
  bool _isSelectionMode = false;
  Set<String> _selectedItems = {};
  
  // Animation controllers
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fetchGroceryItems();
    _loadCategories();
    _checkConnectivity();
    _databaseHelper.syncUnsyncedItems();
    
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
    
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    bool connected = await _connectivity.isConnected();
    setState(() {
      _isConnected = connected;
    });
  }

  Future<void> _fetchGroceryItems() async {
    setState(() {
      _isLoading = true;
    });
    
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
    }
  }

  Future<void> _loadCategories() async {
    final categories = await _databaseHelper.getCategories();
    setState(() {
      _categories = categories;
    });
  }

  List<GroceryItem> _filterItems(String query, String? urgency, String? category) {
    return _productList.where((item) {
      final matchesQuery = item.itemData?.name?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final matchesUrgency = urgency == null || item.itemData?.urgency == urgency;
      final matchesCategory = category == null || item.itemData?.category == category;
      return matchesQuery && matchesUrgency && matchesCategory;
    }).toList();
  }

  void _deleteGroceryItem(String key) async {
    await _databaseHelper.deleteGroceryItem(key);
    _fetchGroceryItems();
  }

  void _toggleItemCompletion(String key, bool isCompleted) async {
    await _databaseHelper.toggleItemCompletion(key, isCompleted);
    _fetchGroceryItems();
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String key) {
    setState(() {
      if (_selectedItems.contains(key)) {
        _selectedItems.remove(key);
      } else {
        _selectedItems.add(key);
      }
    });
  }

  void _bulkDelete() async {
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
      message: 'Selected items deleted',
    );
  }

  void _bulkComplete() async {
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
      message: 'Selected items completed',
    );
  }

  Future<void> _logout() async {
    final confirmed = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );
    
    if (confirmed != true) return;
    
    try {
      await Auth().signOut();
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Logged out successfully',
        onPressed: () {
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

  void _trackCompletedItems() async {
    final completedItems = _productList.where((item) => item.itemData?.isCompleted == true).toList();
    
    if (completedItems.isNotEmpty) {
      final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.addShoppingSession(completedItems);
      
      for (final item in completedItems) {
        if (item.key != null) {
          await _databaseHelper.deleteGroceryItem(item.key!);
        }
      }
      
      _fetchGroceryItems();
      
      AnimatedDialog.showSuccess(
        context: context,
        message: '${completedItems.length} items completed and added to history!',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<GroceryItem> displayedItems = _filterItems(_searchQuery, _selectedUrgency, _selectedCategory);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : CupertinoColors.systemGroupedBackground,
      body: CustomScrollView(
        slivers: [
          // iOS-style App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: Builder(
              builder: (context) => IconButton(
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.menu_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isSelectionMode 
                          ? theme.primaryColor 
                          : theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _isSelectionMode ? Icons.check_circle_rounded : Icons.checklist_rounded,
                      color: _isSelectionMode ? Colors.white : theme.primaryColor,
                      size: 20,
                    ),
                  ),
                  onPressed: _toggleSelectionMode,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.white,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 60, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'My Groceries',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            // Connection status indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _isConnected ? Colors.green : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    _isConnected ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _isConnected ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${displayedItems.length} items',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? CupertinoColors.tertiarySystemFill : CupertinoColors.tertiarySystemFill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search groceries...',
                    hintStyle: TextStyle(
                      color: CupertinoColors.placeholderText,
                      fontSize: 16,
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(
                        CupertinoIcons.search,
                        color: CupertinoColors.placeholderText,
                        size: 20,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),
          ),

          // Filter Pills
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Categories filter
                  ..._buildCategoryFilters(isDark),
                  SizedBox(width: 12),
                  // Urgency filters
                  ..._buildUrgencyFilters(isDark),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Loading or Content
          _isLoading
              ? SliverFillRemaining(
                  child: AnimatedLoadingWidget(
                    message: 'Loading your groceries...',
                  ),
                )
              : displayedItems.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(isDark),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = displayedItems[index];
                          return _buildGroceryItemCard(item, index, isDark);
                        },
                        childCount: displayedItems.length,
                      ),
                    ),
        ],
      ),
      drawer: _buildDrawer(context),
      floatingActionButton: _buildFloatingActionButtons(),
      bottomNavigationBar: _isSelectionMode && _selectedItems.isNotEmpty 
          ? _buildBottomActionBar(isDark)
          : null,
    );
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
                : (isDark ? CupertinoColors.tertiarySystemFill : CupertinoColors.tertiarySystemFill),
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
                      : (isDark ? CupertinoColors.label : CupertinoColors.label),
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
                      CupertinoIcons.cart,
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
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                  SizedBox(height: 32),
                  CupertinoButton.filled(
                    onPressed: () {
                      Navigator.push(
                        context,
                        SlidePageRoute(child: AddItemPage()),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.add, size: 18),
                        SizedBox(width: 8),
                        Text('Add Item'),
                      ],
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
            color: CupertinoColors.destructiveRed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(CupertinoIcons.delete, color: Colors.white, size: 24),
        ),
        confirmDismiss: (direction) async {
          return await AnimatedDialog.showConfirmation(
            context: context,
            title: 'Delete Item',
            message: 'Remove "${item.itemData?.name}" from your list?',
            confirmText: 'Delete',
            cancelText: 'Cancel',
            confirmColor: CupertinoColors.destructiveRed,
            icon: CupertinoIcons.delete,
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
              color: isDark ? CupertinoColors.secondarySystemGroupedBackground : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected 
                  ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                  : null,
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
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
            icon: Icon(CupertinoIcons.bag),
            label: Text('Complete Shopping'),
            backgroundColor: CupertinoColors.systemGreen,
            foregroundColor: Colors.white,
            heroTag: "complete",
            elevation: 8,
          ),
          SizedBox(height: 16),
        ],
        ScaleTransition(
          scale: _fabScaleAnimation,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(child: AddItemPage()),
              );
            },
            child: Icon(CupertinoIcons.add),
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            elevation: 8,
            heroTag: "add",
          ),
        ),
      ],
    );
  }

  // Helper method to build bottom action bar
  Widget _buildBottomActionBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? CupertinoColors.secondarySystemGroupedBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? CupertinoColors.separator : CupertinoColors.separator,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: _bulkComplete,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.checkmark_circle, size: 18),
                      SizedBox(width: 8),
                      Text('Complete (${_selectedItems.length})'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CupertinoButton(
                  onPressed: _bulkDelete,
                  color: CupertinoColors.destructiveRed,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(CupertinoIcons.delete, size: 18),
                      SizedBox(width: 8),
                      Text('Delete (${_selectedItems.length})'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to build the modern iOS-style navigation drawer
  Widget _buildDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDark ? CupertinoColors.secondarySystemGroupedBackground : CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      CupertinoIcons.cart_fill,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grocery App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: CupertinoColors.label,
                          ),
                        ),
                        Text(
                          'Smart shopping made easy',
                          style: TextStyle(
                            fontSize: 14,
                            color: CupertinoColors.secondaryLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            Container(
              height: 1,
              color: CupertinoColors.separator,
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    icon: CupertinoIcons.arrow_2_circlepath,
                    title: 'Sync Now',
                    subtitle: _isConnected ? 'Sync your items to cloud' : 'No internet connection',
                    onTap: () async {
                      Navigator.pop(context);
                      if (_isConnected) {
                        await _databaseHelper.syncUnsyncedItems();
                        AnimatedDialog.showSuccess(
                          context: context,
                          message: 'Items synced successfully!',
                        );
                      } else {
                        AnimatedDialog.showWarning(
                          context: context,
                          message: 'No internet connection. Please check your network and try again.',
                        );
                      }
                    },
                    isDark: isDark,
                    iconColor: _isConnected ? CupertinoColors.systemBlue : CupertinoColors.systemGrey,
                  ),
                  
                  _buildDrawerItem(
                    icon: CupertinoIcons.bell,
                    title: 'Notifications',
                    subtitle: 'Manage your alerts',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        SlidePageRoute(child: NotificationsPage()),
                      );
                    },
                    isDark: isDark,
                    trailing: Consumer<NotificationService>(
                      builder: (context, notificationService, child) {
                        final unreadCount = notificationService.unreadCount;
                        if (unreadCount > 0) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CupertinoColors.destructiveRed,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : '$unreadCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ),
                  
                  _buildDrawerItem(
                    icon: CupertinoIcons.chart_bar,
                    title: 'Shopping Analytics',
                    subtitle: 'View insights & history',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        SlidePageRoute(child: ShoppingHistoryPage()),
                      );
                    },
                    isDark: isDark,
                  ),
                  
                  SizedBox(height: 16),
                  Container(
                    height: 1,
                    color: CupertinoColors.separator,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                  ),
                  SizedBox(height: 16),
                  
                  _buildDrawerItem(
                    icon: CupertinoIcons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        SlidePageRoute(child: SettingsPage()),
                      );
                    },
                    isDark: isDark,
                  ),
                  
                  _buildDrawerItem(
                    icon: CupertinoIcons.info_circle,
                    title: 'About',
                    subtitle: 'App information',
                    onTap: () {
                      Navigator.pop(context);
                      AnimatedDialog.showInfo(
                        context: context,
                        title: 'About Grocery App',
                        message: 'A modern grocery list app with offline support, categories, and smart features.\n\nVersion 1.0.0\nBuilt with Flutter',
                      );
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            
            Container(
              height: 1,
              color: CupertinoColors.separator,
              margin: EdgeInsets.symmetric(horizontal: 16),
            ),
            
            _buildDrawerItem(
              icon: CupertinoIcons.square_arrow_right,
              title: 'Sign Out',
              subtitle: 'Log out of your account',
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
              isDark: isDark,
              iconColor: CupertinoColors.destructiveRed,
              titleColor: CupertinoColors.destructiveRed,
            ),
            
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Helper method to build drawer items
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
    Color? titleColor,
    Widget? trailing,
  }) {
    return CupertinoListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor?.withOpacity(0.1) ?? CupertinoColors.tertiarySystemFill),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor ?? CupertinoColors.label,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? CupertinoColors.label,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
      trailing: trailing ?? Icon(CupertinoIcons.chevron_right, size: 16, color: CupertinoColors.tertiaryLabel),
      onTap: onTap,
    );
  }
}

// Custom CupertinoListTile widget since it's not available in older Flutter versions
class CupertinoListTile extends StatelessWidget {
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CupertinoListTile({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) title!,
                  if (subtitle != null) ...[
                    SizedBox(height: 2),
                    subtitle!,
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
