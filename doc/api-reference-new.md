# API Reference

This document provides detailed information about the Home Grocery App's classes, methods, and APIs.

## 📱 Core Components (Updated July 2025)

### Authentication (`lib/Data/Auth.dart`)

#### Class: `Auth`
Handles Firebase authentication operations with enhanced error handling.

```dart
class Auth {
  static Future<UserCredential?> signInWithEmailAndPassword(String email, String password)
  static Future<UserCredential?> createUserWithEmailAndPassword(String email, String password)
  static Future<void> signOut()
  static User? getCurrentUser()
  static Stream<User?> authStateChanges()
}
```

**Recent Updates:**
- Enhanced error handling with user-friendly messages
- Improved validation for email and password formats
- Better handling of network connectivity issues

### Database Operations (`lib/Data/DatabaseHelper.dart`)

#### Class: `DatabaseHelper`
Manages Firebase Realtime Database operations with offline support.

```dart
class DatabaseHelper {
  // CRUD Operations
  static Future<void> addGroceryItem(GroceryItem item)
  static Future<void> updateGroceryItem(GroceryItem item)
  static Future<void> deleteGroceryItem(String itemId)
  static Future<List<GroceryItem>> getGroceryItems()
  
  // Enhanced Features (Recent)
  static Stream<List<GroceryItem>> getGroceryItemsStream()
  static Future<List<GroceryItem>> searchItems(String query)
  static Future<List<GroceryItem>> filterByCategory(String category)
  static Future<void> markItemCompleted(String itemId, bool completed)
}
```

**Recent Improvements:**
- Real-time data streaming for instant updates
- Enhanced search functionality with filtering
- Better error handling and retry mechanisms
- Optimized queries for better performance

### Local Storage (`lib/Data/LocalStorageHelper.dart`)

#### Class: `LocalStorageHelper`
Manages SQLite local database for offline functionality.

```dart
class LocalStorageHelper {
  // Database Management
  static Future<Database> _getDatabase()
  static Future<void> initializeDatabase()
  
  // Item Operations
  static Future<void> insertGroceryItem(GroceryItem item)
  static Future<void> updateGroceryItem(GroceryItem item)
  static Future<void> deleteGroceryItem(String itemId)
  static Future<List<GroceryItem>> getAllGroceryItems()
  
  // Sync Operations
  static Future<void> syncWithFirebase()
  static Future<bool> hasUnsyncedData()
}
```

### Data Models (`lib/Data/DataModel.dart`)

#### Class: `GroceryItem`
Enhanced data model with additional properties.

```dart
class GroceryItem {
  String id;
  String name;
  String category;      // Enhanced with colorful categories
  String urgency;       // Low, Medium, High with color coding
  bool isCompleted;
  DateTime createdAt;
  DateTime? updatedAt;
  String? notes;        // New: Additional notes
  String? userId;       // Enhanced: User association
  bool isLocal;         // New: Offline indicator
  
  // Methods
  Map<String, dynamic> toMap()
  static GroceryItem fromMap(Map<String, dynamic> map)
  GroceryItem copyWith({...})  // Enhanced for immutability
}
```

**Recent Enhancements:**
- Added `notes` field for additional item information
- Enhanced `category` with visual color coding
- Added `isLocal` flag for offline state management
- Improved `copyWith` method for better state management

## 🎨 UI Components (Modernized July 2025)

### Home Screen (`lib/Screens/Home.dart`)

#### Class: `_HomeState`
Main application screen with Material Design 3 implementation.

```dart
class _HomeState extends State<Home> {
  // Enhanced Search & Filter
  void _performSearch(String query)
  void _filterByCategory(String category)
  void _filterByUrgency(String urgency)
  void _clearFilters()
  
  // Item Management (Enhanced)
  Future<void> _addItem()
  Future<void> _editItem(GroceryItem item)
  Future<void> _deleteItem(String itemId)  // With confirmation
  Future<void> _toggleItemCompleted(GroceryItem item)
  
  // UI State Management
  void _toggleDrawer()
  void _refreshData()
  void _handleEmptyState()  // New: Empty state handling
}
```

**Recent UI Improvements:**
- Material Design 3 theming with dynamic colors
- Enhanced search with real-time filtering
- Improved empty state with call-to-action
- Fixed RenderFlex overflow issues
- Better responsive layout for all screen sizes

### Grocery Item Card (`lib/Reusable/GroceryItemCard.dart`)

#### Class: `GroceryItemCard`
Modernized item display component with swipe actions.

```dart
class GroceryItemCard extends StatelessWidget {
  final GroceryItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onToggleCompleted;
  
  // Enhanced Features
  Widget _buildCategoryIcon()     // New: Colorful category icons
  Widget _buildUrgencyIndicator() // Enhanced: Color-coded urgency
  Widget _buildSwipeActions()     // New: Swipe-to-delete
  Widget _buildItemContent()      // Improved: Better layout
}
```

**Design Updates:**
- Minimalist card design with better spacing
- Colorful category icons for visual identification
- Swipe-to-delete with confirmation dialog
- Improved typography and color scheme
- Better accessibility support

### Add Item Page (`lib/Reusable/AddItemPage.dart`)

#### Class: `_AddItemPageState`
Enhanced form for adding grocery items.

```dart
class _AddItemPageState extends State<AddItemPage> {
  // Form Management (Enhanced)
  final GlobalKey<FormState> _formKey
  final TextEditingController _nameController
  final TextEditingController _notesController  // New
  
  // Validation (Improved)
  String? _validateItemName(String? value)
  String? _validateCategory(String? value)
  
  // UI Helpers
  Widget _buildNameField()       // Enhanced validation
  Widget _buildCategoryDropdown() // Visual category selection
  Widget _buildUrgencySelector() // Color-coded urgency
  Widget _buildNotesField()      // New: Optional notes
  Widget _buildSaveButton()      // Improved styling
}
```

**Form Improvements:**
- Better input validation with real-time feedback
- Visual category selection with icons
- Enhanced layout preventing overflow issues
- Added notes field for additional information
- Improved button styling and interactions

## 🔧 Services & Providers

### Theme Provider (`lib/Data/ThemeProvider.dart`)

#### Class: `ThemeProvider`
Manages application theming with Material Design 3.

```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  // Theme Management
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Actions
  Future<void> setThemeMode(ThemeMode mode)
  Future<void> toggleTheme()
  ThemeData get lightTheme  // Material 3 light theme
  ThemeData get darkTheme   // Material 3 dark theme
}
```

### Connectivity Service (`lib/Data/ConnectivityService.dart`)

#### Class: `ConnectivityService`
Enhanced network monitoring with auto-sync capabilities.

```dart
class ConnectivityService {
  static Stream<ConnectivityResult> get connectivityStream
  static Future<bool> isConnected()
  static Future<void> handleConnectivityChange(bool isConnected)
  
  // Auto-sync Features (New)
  static Future<void> syncWhenOnline()
  static void showConnectionStatus(BuildContext context)
}
```

### Notification Service (`lib/Data/NotificationService.dart`)

#### Class: `NotificationService`
In-app notification system with history tracking.

```dart
class NotificationService extends ChangeNotifier {
  List<AppNotification> _notifications = [];
  
  // Notification Management
  void showNotification(String message, NotificationType type)
  void markAsRead(String notificationId)
  void clearAll()
  
  // History
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
}
```

## 🏗️ Build Configuration (Updated July 2025)

### Android Build Settings
Recent updates to support latest Android toolchain:

```gradle
// android/app/build.gradle
android {
    compileSdk = 35                    // Android 15 support
    ndkVersion = "27.0.12077973"       // Firebase compatible
    
    defaultConfig {
        minSdkVersion 23               // Android 6.0+
        targetSdk = flutter.targetSdkVersion
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17  // Java 17 LTS
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'               // Kotlin targeting Java 17
    }
}
```

### Dependencies (pubspec.yaml)
Key dependencies with current versions:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.6.0           # Enhanced: Latest Firebase
  firebase_auth: ^5.3.1           # Enhanced: Auth improvements
  firebase_database: ^11.1.4      # Enhanced: Database optimizations
  sqflite: ^2.3.0                 # Enhanced: Local storage
  provider: ^6.1.2                # State management
  connectivity_plus: ^4.0.2       # Network monitoring
  shared_preferences: ^2.2.2      # Local preferences
```

## 🧪 Testing APIs

### Test Utilities
Enhanced testing support for UI components:

```dart
// test/widget_test.dart
class TestUtils {
  static Widget createTestWidget(Widget child)
  static Future<void> pumpAndSettle(WidgetTester tester)
  static Future<void> enterText(WidgetTester tester, String text)
  static Future<void> tapButton(WidgetTester tester, String buttonText)
}
```

## 🔒 Security & Privacy

### Data Protection
- All sensitive data encrypted in local storage
- Firebase security rules properly configured
- User authentication required for all operations
- No personal data stored without explicit consent

### Privacy Features
- Local data backup with user control
- Option to delete all user data
- Transparent data usage policies
- No third-party analytics without permission

---

**Last Updated**: July 8, 2025
**Version**: 0.4.0
**Flutter Version**: 3.32.5+
**Android Target**: API 35 (Android 15)
