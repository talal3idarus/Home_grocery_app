# API Reference

This document provides detailed information about the key classes, methods, and APIs used in the Home Grocery App.

## 📋 Table of Contents

- [Data Models](#data-models)
- [Providers](#providers)
- [Services](#services)
- [Database Layer](#database-layer)
- [UI Components](#ui-components)
- [Utilities](#utilities)

## 🗂️ Data Models

### GroceryItem

Main entity representing a grocery item.

```dart
class GroceryItem {
  String? key;
  GroceryItemData? itemData;
  String category;
  String urgency;
  bool isCompleted;
  bool isSynced;

  GroceryItem({
    this.key,
    this.itemData,
    required this.category,
    required this.urgency,
    this.isCompleted = false,
    this.isSynced = false,
  });

  // Serialization methods
  Map<String, dynamic> toJson();
  factory GroceryItem.fromJson(Map<String, dynamic> json);
}
```

**Properties:**
- `key`: Unique identifier for the item
- `itemData`: Detailed information about the item
- `category`: Item category (e.g., "Produce", "Dairy")
- `urgency`: Priority level ("Low", "Medium", "High")
- `isCompleted`: Whether the item has been purchased
- `isSynced`: Whether the item is synchronized with remote storage

### GroceryItemData

Detailed information about a grocery item.

```dart
class GroceryItemData {
  String name;
  String? description;
  String? category;
  String? urgency;
  List<String>? tags;
  bool isCompleted;

  GroceryItemData({
    required this.name,
    this.description,
    this.category,
    this.urgency,
    this.tags,
    this.isCompleted = false,
  });

  // Serialization methods
  Map<String, dynamic> toJson();
  factory GroceryItemData.fromJson(Map<String, dynamic> json);
}
```

### ShoppingSession

Represents a completed shopping trip.

```dart
class ShoppingSession {
  String id;
  List<GroceryItem> items;
  DateTime timestamp;
  int totalItems;
  double totalSpent;

  ShoppingSession({
    required this.id,
    required this.items,
    required this.timestamp,
    required this.totalItems,
    required this.totalSpent,
  });

  // Serialization methods
  Map<String, dynamic> toJson();
  factory ShoppingSession.fromJson(Map<String, dynamic> json);
}
```

## 🔄 Providers

### HistoryProvider

Manages shopping history and analytics.

```dart
class HistoryProvider extends ChangeNotifier {
  // Public getters
  List<ShoppingSession> get shoppingHistory;
  Map<String, int> get itemFrequency;

  // Methods
  Future<void> loadHistory();
  Future<void> saveHistory();
  void addShoppingSession(List<GroceryItem> completedItems);
  Map<String, dynamic> getShoppingAnalytics();
  void clearHistory();
}
```

**Key Methods:**

#### `loadHistory()`
Loads shopping history from local storage.
- **Returns**: `Future<void>`
- **Usage**: Called during app initialization

#### `addShoppingSession(List<GroceryItem> completedItems)`
Records a completed shopping session.
- **Parameters**: 
  - `completedItems`: List of purchased items
- **Side Effects**: Updates frequency tracking, saves to storage

#### `getShoppingAnalytics()`
Returns analytics data for the dashboard.
- **Returns**: `Map<String, dynamic>` containing:
  - `totalSessions`: Number of shopping trips
  - `averageItemsPerSession`: Average items per trip
  - `averageSpentPerSession`: Average spending per trip
  - `mostFrequentItems`: Top 5 frequently bought items
  - `totalSpent`: Total estimated spending

### SettingsProvider

Manages app settings and preferences.

```dart
class SettingsProvider extends ChangeNotifier {
  // Settings properties
  bool get notificationsEnabled;
  bool get autoSync;
  bool get confirmDeletion;
  bool get biometricAuth;
  String get defaultCategory;
  String get sortBy;

  // Methods
  Future<void> loadSettings();
  Future<void> setNotificationsEnabled(bool enabled);
  Future<void> setAutoSync(bool enabled);
  Future<void> setConfirmDeletion(bool enabled);
  Future<void> setBiometricAuth(bool enabled);
  Future<void> setDefaultCategory(String category);
  Future<void> setSortBy(String sortOption);
}
```

### ThemeProvider

Manages app theme and appearance.

```dart
class ThemeProvider extends ChangeNotifier {
  bool get isDarkMode;
  ThemeData get currentTheme;

  Future<void> toggleTheme();
  Future<void> setTheme(bool isDark);
  Future<void> loadTheme();
}
```

## 🛠️ Services

### DatabaseHelper

Handles local database operations and Firebase synchronization.

```dart
class DatabaseHelper {
  // Singleton instance
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  // Core methods
  Future<List<GroceryItem>> getGroceryItems();
  Future<void> addNewGroceryItem(GroceryItemData groceryItemData);
  Future<void> updateGroceryItem(String key, String name, String category, String urgency, bool isCompleted);
  Future<void> deleteGroceryItem(String key);
  
  // Sync methods
  Future<void> syncUnsyncedItems();
  Future<void> readFirebaseRealtimeDBMain(Function(List<GroceryItem>) productListCallback);
  
  // Category management
  Future<List<Map<String, dynamic>>> getCategories();
  Future<void> addCategory(String name, String icon);
}
```

**Key Methods:**

#### `getGroceryItems()`
Retrieves all grocery items from local database.
- **Returns**: `Future<List<GroceryItem>>`
- **Usage**: Load items for display in UI

#### `addNewGroceryItem(GroceryItemData groceryItemData)`
Adds a new grocery item to both local and remote storage.
- **Parameters**: 
  - `groceryItemData`: Item details to add
- **Returns**: `Future<void>`
- **Side Effects**: Saves locally, queues for Firebase sync

#### `syncUnsyncedItems()`
Synchronizes local changes with Firebase.
- **Returns**: `Future<void>`
- **Usage**: Called when connectivity is restored

### ConnectivityService

Monitors network connectivity status.

```dart
class ConnectivityService {
  Stream<ConnectivityResult> get onConnectivityChanged;
  
  Future<bool> isConnected();
  void dispose();
}
```

### NotificationService

Manages in-app notifications.

```dart
class NotificationService extends ChangeNotifier {
  List<AppNotification> get notifications;
  int get unreadCount;

  void addNotification(String title, String message, NotificationType type);
  void markAsRead(String id);
  void markAllAsRead();
  void clearAllNotifications();
  void removeNotification(String id);
}
```

#### Notification Types
```dart
enum NotificationType {
  info,
  success,
  warning,
  error,
  reminder,
  alert
}
```

### Auth

Handles user authentication with Firebase.

```dart
class Auth {
  static Future<User?> signInWithEmail(String email, String password);
  static Future<User?> registerWithEmail(String email, String password);
  static Future<void> signOut();
  static Future<void> logout();
  static User? getCurrentUser();
  static Stream<User?> get authStateChanges;
}
```

### BackupService

Manages data backup and restoration.

```dart
class BackupService extends ChangeNotifier {
  bool get isBackingUp;
  bool get autoBackupEnabled;
  DateTime? get lastBackupTime;

  Future<void> createBackup();
  Future<void> restoreFromBackup(String filePath);
  Future<void> setAutoBackupEnabled(bool enabled);
}
```

## 🎨 UI Components

### GroceryItemCard

Displays a grocery item in the list.

```dart
class GroceryItemCard extends StatelessWidget {
  final GroceryItem groceryItem;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final bool isSelected;

  const GroceryItemCard({
    Key? key,
    required this.groceryItem,
    this.onComplete,
    this.onDelete,
    this.onEdit,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context);
}
```

### AnimatedDialog

Custom dialog with animations.

```dart
class AnimatedDialog {
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  });

  static void showError(
    BuildContext context, {
    required String title,
    required String message,
  });

  static void showSuccess(
    BuildContext context, {
    required String title,
    required String message,
  });

  static void showInfo(
    BuildContext context, {
    required String title,
    required String message,
  });
}
```

### AddItemPage

Screen for adding/editing grocery items.

```dart
class AddItemPage extends StatefulWidget {
  final GroceryItem? existingItem;
  
  const AddItemPage({Key? key, this.existingItem}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}
```

## 🔧 Utilities

### LocalStorageHelper

Wrapper for SQLite database operations.

```dart
class LocalStorageHelper {
  Future<Database> get database;
  
  // Grocery items
  Future<int> insertGroceryItem(GroceryItem item);
  Future<List<GroceryItem>> getAllGroceryItems();
  Future<int> updateGroceryItem(String key, GroceryItemData itemData);
  Future<int> deleteGroceryItem(String key);
  
  // Categories
  Future<List<Map<String, dynamic>>> getCategories();
  Future<int> insertCategory(String name, String icon);
  
  // Utility
  Future<List<GroceryItem>> getUnsyncedItems();
  Future<GroceryItem?> getGroceryItemByKey(String key);
}
```

### Constants

App-wide constants and configuration.

```dart
class AppConstants {
  // Firebase collections
  static const String USERS_COLLECTION = 'users';
  static const String GROCERY_ITEMS_COLLECTION = 'grocery_items';
  
  // Local storage keys
  static const String THEME_KEY = 'theme_preference';
  static const String SETTINGS_KEY = 'app_settings';
  
  // Default values
  static const String DEFAULT_CATEGORY = 'Other';
  static const String DEFAULT_URGENCY = 'Medium';
  
  // UI constants
  static const double CARD_BORDER_RADIUS = 12.0;
  static const double PADDING_STANDARD = 16.0;
}
```

## 📊 Error Handling

### Exception Types

```dart
class DatabaseException implements Exception {
  final String message;
  final dynamic originalException;
  
  DatabaseException(this.message, [this.originalException]);
}

class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, [this.statusCode]);
}

class AuthException implements Exception {
  final String message;
  final String? code;
  
  AuthException(this.message, [this.code]);
}
```

### Error Handling Pattern

```dart
Future<Result<T>> performOperation<T>() async {
  try {
    final result = await someAsyncOperation();
    return Success(result);
  } on DatabaseException catch (e) {
    return Failure('Database error: ${e.message}');
  } on NetworkException catch (e) {
    return Failure('Network error: ${e.message}');
  } catch (e) {
    return Failure('Unexpected error: $e');
  }
}
```

## 🔐 Security Considerations

### Data Validation

```dart
class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateItemName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Item name is required';
    }
    if (name.trim().length > 100) {
      return 'Item name too long';
    }
    return null;
  }
}
```

## 🚀 Performance Tips

### Efficient Widget Building

```dart
// Use const constructors
const Text('Static text');

// Use Builder widgets to limit rebuild scope
Consumer<GroceryProvider>(
  builder: (context, provider, child) {
    return Text('${provider.itemCount} items');
  },
);

// Cache expensive computations
class ExpensiveWidget extends StatefulWidget {
  @override
  State<ExpensiveWidget> createState() => _ExpensiveWidgetState();
}

class _ExpensiveWidgetState extends State<ExpensiveWidget> {
  late final String _cachedValue = expensiveComputation();
  
  @override
  Widget build(BuildContext context) {
    return Text(_cachedValue);
  }
}
```

### Database Optimization

```dart
// Use transactions for multiple operations
await database.transaction((txn) async {
  for (final item in items) {
    await txn.insert('grocery_items', item.toJson());
  }
});

// Use batch operations
final batch = database.batch();
for (final item in items) {
  batch.insert('grocery_items', item.toJson());
}
await batch.commit();
```

---

**Note**: This API reference covers the main components as of version 0.3.0. For the most up-to-date information, always refer to the source code and inline documentation.

**Last Updated**: July 7, 2025
