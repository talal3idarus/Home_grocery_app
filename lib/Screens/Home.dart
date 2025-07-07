import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Data/Auth.dart';
import '../Data/HistoryProvider.dart';
import '../Data/ThemeProvider.dart';
import '../Data/ConnectivityService.dart';
import '../Reusable/GroceryItemCard.dart';
import '../Reusable/AddItemPage.dart';
import '../Screens/Login.dart';
import '../Screens/Settings.dart';
import '../Screens/ShoppingHistoryPage.dart';
import '../Screens/NotificationsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _refreshAnimationController;
  late Animation<double> _refreshAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    // Initialize refresh animation
    _refreshAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _refreshAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _refreshAnimationController, curve: Curves.easeInOut),
    );
    
    _fetchGroceryItems();
    _loadCategories();
    _checkConnectivity();
    
    // Start animation
    _animationController.forward();
    
    // Try to sync unsynced items
    _databaseHelper.syncUnsyncedItems();
    
    // Listen to connectivity changes
    _connectivity.onConnectivityChanged.listen((result) {
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshAnimationController.dispose();
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
    
    _databaseHelper.readFirebaseRealtimeDBMain((List<GroceryItem> items) {
      setState(() {
        _productList = items;
        _isLoading = false;
      });
    });
  }

  Future<void> _refreshData() async {
    // Start refresh animation
    _refreshAnimationController.forward();
    
    // Fetch fresh data
    await _fetchGroceryItems();
    await _loadCategories();
    await _checkConnectivity();
    
    // Reset animation after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshAnimationController.reset();
  }

  Future<void> _loadCategories() async {
    try {
      List<Map<String, dynamic>> categories = await _databaseHelper.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      // Error loading categories - using empty list
    }
  }

  List<GroceryItem> _getFilteredProducts() {
    return _productList.where((item) {
      bool matchesSearch = _searchQuery.isEmpty ||
          (item.itemData?.name?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      bool matchesUrgency = _selectedUrgency == null || item.itemData?.urgency == _selectedUrgency;
      bool matchesCategory = _selectedCategory == null || item.itemData?.category == _selectedCategory;
      
      return matchesSearch && matchesUrgency && matchesCategory && !(item.itemData?.isCompleted ?? false);
    }).toList();
  }

  void _navigateToAddItemPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddItemPage()),
    );
    
    if (result == true) {
      await _fetchGroceryItems();
    }
  }

  void _logout() async {
    try {
      final auth = Auth();
      await auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging out: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Home Grocery',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isConnected)
            Icon(
              Icons.wifi_off,
              color: colorScheme.error,
            ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _refreshAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshAnimation.value * 2 * 3.14159, // Full rotation
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh',
                  onPressed: _isLoading ? null : _refreshData,
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildSideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : filteredProducts.isEmpty
                      ? _buildEmptyState()
                      : _buildProductList(filteredProducts),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddItemPage,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 6,
      ),
    );
  }

  Widget _buildSideDrawer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Drawer(
      backgroundColor: colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 240, maxHeight: 300),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
                  colorScheme.secondary.withOpacity(0.3),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    
                    // App Title with Emoji
                    Row(
                      children: [
                        Text(
                          '🛒',
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Home Grocery',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              height: 1.1,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Subtitle
                    Text(
                      'Smart shopping made simple',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Statistics or additional info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onPrimary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            color: colorScheme.onPrimary.withOpacity(0.9),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Organize your lists efficiently',
                              style: TextStyle(
                                color: colorScheme.onPrimary.withOpacity(0.9),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'Home',
                  isSelected: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'Shopping History',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShoppingHistoryPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => NotificationsPage()),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                ),
                Divider(
                  height: 32,
                  color: colorScheme.outline.withOpacity(0.2),
                  indent: 16,
                  endIndent: 16,
                ),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return _buildDrawerItem(
                      icon: themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      title: themeProvider.isDarkMode ? 'Light Mode' : 'Dark Mode',
                      onTap: () {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline,
                  title: 'About',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog();
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? colorScheme.primaryContainer
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: colorScheme.surfaceContainerHighest,
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search grocery items...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Urgency Filter
          Row(
            children: [
              Text(
                'Priority:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildUrgencyChip('Low', Colors.green),
                      const SizedBox(width: 8),
                      _buildUrgencyChip('Medium', Colors.orange),
                      const SizedBox(width: 8),
                      _buildUrgencyChip('High', Colors.red),
                      const SizedBox(width: 8),
                      _buildClearFiltersChip(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrgencyChip(String urgency, Color color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isSelected = _selectedUrgency == urgency;
    
    return FilterChip(
      label: Text(urgency),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedUrgency = selected ? urgency : null;
        });
      },
      backgroundColor: colorScheme.surfaceContainerHighest,
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
        width: 1.5,
      ),
    );
  }

  Widget _buildClearFiltersChip() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool hasFilters = _selectedUrgency != null || _selectedCategory != null;
    
    if (!hasFilters) return const SizedBox.shrink();
    
    return ActionChip(
      label: const Text('Clear'),
      onPressed: () {
        setState(() {
          _selectedUrgency = null;
          _selectedCategory = null;
        });
      },
      backgroundColor: colorScheme.errorContainer,
      labelStyle: TextStyle(
        color: colorScheme.onErrorContainer,
      ),
    );
  }

  Widget _buildCategoryFilter() {
    if (_categories.isEmpty) return const SizedBox.shrink();
    
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', null);
          }
          
          final category = _categories[index - 1];
          return _buildCategoryChip(
            category['name'],
            Color(int.parse(category['color'].substring(1), radix: 16) + 0xFF000000),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String name, Color? color) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isSelected = (_selectedCategory == name) || (name == 'All' && _selectedCategory == null);
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = (name == 'All') ? null : (selected ? name : null);
          });
        },
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: color?.withOpacity(0.2) ?? colorScheme.primaryContainer,
        checkmarkColor: color ?? colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected 
              ? (color ?? colorScheme.primary)
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected 
              ? (color ?? colorScheme.primary)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading your grocery items...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty 
                ? 'Try adjusting your search'
                : 'Add your first grocery item',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddItemPage,
            icon: Icon(Icons.add),
            label: Text('Add Item'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<GroceryItem> items) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: GroceryItemCard(
            item: item,
            onToggleCompletion: (key, isCompleted) async {
              await _databaseHelper.toggleItemCompletion(key, isCompleted);
              if (isCompleted) {
                final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
                historyProvider.addShoppingSession([item]);
              }
              _fetchGroceryItems();
            },
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Home Grocery'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 0.4.0'),
            SizedBox(height: 8),
            Text('A smart grocery list app that helps you stay organized and shop efficiently.'),
            SizedBox(height: 12),
            Text('Features:'),
            Text('• Offline support'),
            Text('• Smart categorization'),
            Text('• Shopping history'),
            Text('• Dark mode'),
            Text('• Priority levels'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
