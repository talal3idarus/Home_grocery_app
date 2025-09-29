import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/HistoryProvider.dart';
import '../Reusable/AnimatedDialog.dart';
import 'package:intl/intl.dart';

class ShoppingHistoryPage extends StatefulWidget {
  @override
  _ShoppingHistoryPageState createState() => _ShoppingHistoryPageState();
}

class _ShoppingHistoryPageState extends State<ShoppingHistoryPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping History'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: () => _clearHistory(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Tab Bar
              Container(
                margin: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        'Analytics',
                        0,
                        Icons.analytics,
                        colorScheme,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        'History',
                        1,
                        Icons.history,
                        colorScheme,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: Consumer<HistoryProvider>(
                  builder: (context, historyProvider, child) {
                    switch (_selectedTabIndex) {
                      case 0:
                        return _buildAnalyticsTab(historyProvider, colorScheme);
                      case 1:
                        return _buildHistoryTab(historyProvider, colorScheme);
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon, ColorScheme colorScheme) {
    final isSelected = _selectedTabIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab(HistoryProvider historyProvider, ColorScheme colorScheme) {
    final analytics = historyProvider.getShoppingAnalytics();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildAnalyticsCard(
            'Shopping Overview',
            [
              _buildAnalyticsItem('Total Sessions', '${analytics['totalSessions']}', Icons.shopping_cart),
              _buildAnalyticsItem('Average Items', '${analytics['averageItemsPerSession'].toStringAsFixed(1)}', Icons.inventory),
              _buildAnalyticsItem('Estimated Spent', '\$${analytics['averageSpentPerSession'].toStringAsFixed(2)}', Icons.attach_money),
            ],
            colorScheme,
          ),
          
          SizedBox(height: 16),
          
          _buildAnalyticsCard(
            'Most Frequent Items',
            (analytics['mostFrequentItems'] as List<String>).isEmpty
                ? [Text('No data available yet', style: TextStyle(color: colorScheme.onSurfaceVariant))]
                : (analytics['mostFrequentItems'] as List<String>).map((item) =>
                    ListTile(
                      leading: Icon(Icons.favorite, color: colorScheme.primary),
                      title: Text(item),
                      trailing: Text('${historyProvider.itemFrequency[item]} times'),
                      dense: true,
                    ),
                  ).toList(),
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, List<Widget> children, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(HistoryProvider historyProvider, ColorScheme colorScheme) {
    final history = historyProvider.shoppingHistory;
    
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: colorScheme.onSurfaceVariant),
            SizedBox(height: 16),
            Text(
              'No shopping history yet',
              style: TextStyle(
                fontSize: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Complete some shopping trips to see your history',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final session = history[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Text(
                '${session.totalItems}',
                style: TextStyle(color: colorScheme.onPrimary),
              ),
            ),
            title: Text(DateFormat('MMM dd, yyyy').format(session.timestamp)),
            subtitle: Text('${session.totalItems} items • \$${session.totalSpent.toStringAsFixed(2)}'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showSessionDetails(session, colorScheme),
          ),
        );
      },
    );
  }

  void _showSessionDetails(ShoppingSession session, ColorScheme colorScheme) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shopping Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${DateFormat('MMM dd, yyyy HH:mm').format(session.timestamp)}'),
            Text('Total Items: ${session.totalItems}'),
            Text('Estimated Spent: \$${session.totalSpent.toStringAsFixed(2)}'),
            SizedBox(height: 16),
            Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: ListView.builder(
                itemCount: session.items.length,
                itemBuilder: (context, index) {
                  final item = session.items[index];
                  return ListTile(
                    dense: true,
                    title: Text(item.itemData?.name ?? 'Unknown'),
                    subtitle: Text('Qty: ${item.itemData?.quantity ?? 1}'),
                    leading: Icon(Icons.check_circle, color: Colors.green),
                  );
                },
              ),
            ),
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

  void _clearHistory(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Clear History',
      message: 'Are you sure you want to clear all shopping history? This action cannot be undone.',
      confirmText: 'Clear',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );
    
    if (result == true) {
      Provider.of<HistoryProvider>(context, listen: false).clearHistory();
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Shopping history cleared successfully.',
      );
    }
  }
}
