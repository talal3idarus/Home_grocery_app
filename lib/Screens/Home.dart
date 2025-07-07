import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Data/Auth.dart';
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
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    _databaseHelper.readFirebaseRealtimeDBMain((List<GroceryItem> items) {
      if (mounted) {
        setState(() {
          _productList = items;
          _isLoading = false;
        });
      }
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
      if (mounted) {
        setState(() {
          _categories = categories;
        });
      }
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
      
      return matchesSearch && matchesUrgency && matchesCategory;
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
        title: Row(
          children: [
            Icon(
              Icons.shopping_cart_rounded,
              color: colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Home Grocery',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          // Connectivity Status Indicator
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isConnected 
                  ? Colors.green.withOpacity(0.1) 
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isConnected ? Colors.green : Colors.red,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isConnected ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Animated Refresh Button
          AnimatedBuilder(
            animation: _refreshAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _refreshAnimation.value * 2 * 3.14159, // Full rotation
                child: IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: _isLoading 
                        ? colorScheme.onSurfaceVariant.withOpacity(0.5)
                        : colorScheme.primary,
                  ),
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
      floatingActionButton: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToAddItemPage,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              elevation: 8,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
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
          
          // Search Bar with enhanced design
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.surfaceContainerHighest,
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search grocery items...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 24,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _searchQuery = "";
                          });
                        },
                      )
                    : Icon(
                        Icons.tune_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Priority Filter with dropdown
          Row(
            children: [
              Icon(
                Icons.priority_high_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Priority:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: colorScheme.outline.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedUrgency,
                      hint: Text(
                        'Select Priority',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      isExpanded: true,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 14,
                      ),
                      dropdownColor: colorScheme.surfaceContainerHighest,
                      items: [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Row(
                            children: [
                              Icon(
                                Icons.clear_all_rounded,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'All Priorities',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Low',
                          child: Row(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Low Priority',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Medium',
                          child: Row(
                            children: [
                              Icon(
                                Icons.remove_rounded,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Medium Priority',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        DropdownMenuItem<String>(
                          value: 'High',
                          child: Row(
                            children: [
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'High Priority',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          _selectedUrgency = value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
            return _buildCategoryChip('All', '📦');
          }
          
          final category = _categories[index - 1];
          return _buildCategoryChip(
            category['name'], 
            category['icon'] ?? '🏷️',
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String name, String? emoji) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    bool isSelected = (_selectedCategory == name) || (name == 'All' && _selectedCategory == null);
    
    // Get category-specific colorful icon color for background and border
    Color getIconColor() {
      switch (name.toLowerCase()) {
        case 'all':
          return colorScheme.primary;
        case 'dairy':
          return Colors.blue;
        case 'meat':
          return Colors.red;
        case 'vegetables':
          return Colors.green;
        case 'fruits':
          return Colors.orange;
        case 'snacks':
          return Colors.amber;
        case 'beverages':
          return Colors.brown;
        case 'household':
          return Colors.purple;
        case 'personal care':
          return Colors.pink;
        case 'frozen':
          return Colors.lightBlue;
        case 'bakery':
          return Colors.deepOrange;
        default:
          return Colors.grey;
      }
    }
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: getIconColor().withOpacity(isSelected ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              emoji ?? (name == 'All' ? '📦' : '🏷️'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
        label: Text(name),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = (name == 'All') ? null : (selected ? name : null);
          });
        },
        backgroundColor: colorScheme.surfaceContainerHighest,
        selectedColor: getIconColor().withOpacity(0.15),
        checkmarkColor: getIconColor(),
        labelStyle: TextStyle(
          color: isSelected 
              ? getIconColor()
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected 
              ? getIconColor()
              : Colors.transparent,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Animated loading container
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1500),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.shopping_cart_rounded,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // Loading text with typewriter effect
          TweenAnimationBuilder<int>(
            duration: const Duration(milliseconds: 2000),
            tween: IntTween(begin: 0, end: 'Loading your grocery items...'.length),
            builder: (context, value, child) {
              return Text(
                'Loading your grocery items...'.substring(0, value),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              );
            },
          ),
          
          const SizedBox(height: 12),
          
          // Pulsing dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 800 + (index * 200)),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(value),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              );
            }),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
            // Animated Icon
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.8 + (0.2 * value),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        (_searchQuery.isNotEmpty || _selectedUrgency != null || _selectedCategory != null)
                            ? Icons.search_off_rounded
                            : Icons.shopping_cart_outlined,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              (_searchQuery.isNotEmpty || _selectedUrgency != null || _selectedCategory != null)
                  ? 'No items found'
                  : 'Your grocery list is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              (_searchQuery.isNotEmpty || _selectedUrgency != null || _selectedCategory != null)
                  ? 'Try adjusting your search terms or filters'
                  : 'Start by adding your first grocery item',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            if (_searchQuery.isNotEmpty || _selectedUrgency != null || _selectedCategory != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _searchQuery = "";
                        _selectedUrgency = null;
                        _selectedCategory = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all_rounded),
                    label: const Text('Clear Filters'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _navigateToAddItemPage,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _navigateToAddItemPage,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Your First Item'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
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
          margin: const EdgeInsets.only(bottom: 12),
          child: GroceryItemCard(
            item: item,
            onDelete: (key) async {
              try {
                await _databaseHelper.deleteGroceryItem(key);
                
                if (mounted) {
                  _fetchGroceryItems();
                }
              } catch (e) {
                debugPrint('Error deleting item: $e');
                // Optionally show an error message to user
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete item: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
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
