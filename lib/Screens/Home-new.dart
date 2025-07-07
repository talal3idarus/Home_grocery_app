import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Data/Auth.dart';
import '../Data/HistoryProvider.dart';
import '../Data/SettingsProvider.dart';
import '../Data/ThemeProvider.dart';
import '../Data/ConnectivityService.dart';
import '../Reusable/GroceryItemCard.dart';
import '../Reusable/AddItemPage.dart';
import '../Screens/Login.dart';
import '../Screens/Settings.dart';
import '../Screens/ShoppingHistoryPage.dart';
import '../Screens/NotificationsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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

  Future<void> _loadCategories() async {
    try {
      List<Map<String, dynamic>> categories = await _databaseHelper.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error loading categories: $e');
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
    final isDark = theme.brightness == Brightness.dark;
    final filteredProducts = _getFilteredProducts();

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        title: Text(
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
              color: Colors.orange,
            ),
          SizedBox(width: 8),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return IconButton(
                icon: Icon(Icons.notifications_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NotificationsPage()),
                ),
              );
            },
          ),
        ],
      ),
      drawer: _buildSideDrawer(isDark),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilters(isDark),
            _buildCategoryFilter(isDark),
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
        icon: Icon(Icons.add),
        label: Text('Add Item'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSideDrawer(bool isDark) {
    return Drawer(
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark 
                    ? [Colors.grey[800]!, Colors.grey[900]!]
                    : [Colors.blue[400]!, Colors.blue[600]!],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Grocery Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Stay organized, shop smart',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
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
                Divider(height: 32),
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
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
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
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? theme.primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected 
              ? theme.primaryColor
              : (isDark ? Colors.grey[300] : Colors.grey[700]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected 
                ? theme.primaryColor
                : (isDark ? Colors.grey[300] : Colors.grey[700]),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search grocery items...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          SizedBox(height: 16),
          
          // Urgency Filter
          Row(
            children: [
              Text(
                'Priority:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildUrgencyChip('Low', Colors.green, isDark),
                      SizedBox(width: 8),
                      _buildUrgencyChip('Medium', Colors.orange, isDark),
                      SizedBox(width: 8),
                      _buildUrgencyChip('High', Colors.red, isDark),
                      SizedBox(width: 8),
                      _buildClearFiltersChip(isDark),
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

  Widget _buildUrgencyChip(String urgency, Color color, bool isDark) {
    bool isSelected = _selectedUrgency == urgency;
    
    return FilterChip(
      label: Text(urgency),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedUrgency = selected ? urgency : null;
        });
      },
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      selectedColor: color.withOpacity(0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : (isDark ? Colors.grey[300] : Colors.grey[700]),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? color : Colors.transparent,
        width: 1.5,
      ),
    );
  }

  Widget _buildClearFiltersChip(bool isDark) {
    bool hasFilters = _selectedUrgency != null || _selectedCategory != null;
    
    if (!hasFilters) return SizedBox.shrink();
    
    return ActionChip(
      label: Text('Clear'),
      onPressed: () {
        setState(() {
          _selectedUrgency = null;
          _selectedCategory = null;
        });
      },
      backgroundColor: isDark ? Colors.grey[700] : Colors.grey[300],
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
    );
  }

  Widget _buildCategoryFilter(bool isDark) {
    if (_categories.isEmpty) return SizedBox.shrink();
    
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCategoryChip('All', null, isDark);
          }
          
          final category = _categories[index - 1];
          return _buildCategoryChip(
            category['name'],
            Color(int.parse(category['color'].substring(1), radix: 16) + 0xFF000000),
            isDark,
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String name, Color? color, bool isDark) {
    bool isSelected = (_selectedCategory == name) || (name == 'All' && _selectedCategory == null);
    
    return Container(
      margin: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = (name == 'All') ? null : (selected ? name : null);
          });
        },
        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
        selectedColor: color?.withOpacity(0.2) ?? Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: color ?? Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected 
              ? (color ?? Theme.of(context).primaryColor)
              : (isDark ? Colors.grey[300] : Colors.grey[700]),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected 
              ? (color ?? Theme.of(context).primaryColor)
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
