import 'package:flutter/material.dart';
import '../Data/DatabaseHelper.dart';
import '../Data/DataModel.dart';
import '../Reusable/GroceryItemCard.dart'; // Import your GroceryItemCard widget
import '../Reusable/AddItemPage.dart';
import '../Screens/Login.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<GroceryItem> _productList = []; // Initialize your product list
  bool _isLoading = true; // Flag to manage loading state
  String _searchQuery = ""; // For handling search queries
  String? _selectedUrgency; // For handling urgency filter

  @override
  void initState() {
    super.initState();
    // Fetch grocery items when the page loads
    _fetchGroceryItems();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching items: $e')),
      );
    }
  }

  // Filter items by search query and selected urgency
  List<GroceryItem> _filterItems(String query, String? urgency) {
    return _productList.where((item) {
      bool matchesUrgency = urgency == null || item.itemData!.urgency == urgency;
      bool matchesQuery = item.itemData!.name!.toLowerCase().contains(query.toLowerCase());
      return matchesUrgency && matchesQuery;
    }).toList();
  }

  // Method to delete a grocery item
  void _deleteGroceryItem(String key) async {
    await _databaseHelper.deleteGroceryItem(key);
    _fetchGroceryItems();
  }

  // Method to handle logout action
  void _logout() {
    // Implement your logout logic here (e.g., clearing user session)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged out')),
    );

    // Navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), // Replace with your actual login page widget
    );
  }


  @override
  Widget build(BuildContext context) {
    List<GroceryItem> displayedItems = _filterItems(_searchQuery, _selectedUrgency);

    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery List', style: TextStyle(fontSize: 30)),
        centerTitle: true,
        leading: IconButton( // Add leading icon button for logout
          icon: Icon(Icons.logout),
          onPressed: _logout, // Call the logout method
        ),
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
                ? Center(child: CircularProgressIndicator()) // Show loading spinner
                : displayedItems.isEmpty
                ? Center(child: Text('No items found.')) // Message if no items are found
                : ListView.builder(
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
                  onDismissed: (direction) {
                    _deleteGroceryItem(item.key!); // Call the delete method
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item.itemData?.name} deleted')),
                    );
                  },
                  child: GroceryItemCard(
                    item: item,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddItemPage
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddItemPage()),
          );
        },
        child: Icon(Icons.add),
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
