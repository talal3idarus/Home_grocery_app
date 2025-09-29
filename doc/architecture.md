# Architecture Documentation

This document describes the technical architecture, design patterns, and structural organization of the Home Grocery App.

## 🏗️ Overall Architecture

The Home Grocery App follows a **layered architecture** with clear separation of concerns:

```
┌─────────────────────────────────────┐
│           Presentation Layer        │  ← UI Screens & Widgets
├─────────────────────────────────────┤
│            Business Logic           │  ← Providers & State Management
├─────────────────────────────────────┤
│             Data Layer              │  ← Repository & Data Sources
├─────────────────────────────────────┤
│            Services Layer           │  ← External APIs & Utilities
└─────────────────────────────────────┘
```

## 🎨 Design Patterns

### 1. Provider Pattern (State Management)
**Why**: Simple, scalable state management that integrates well with Flutter
**Usage**: Managing app-wide state like user data, grocery lists, and settings

```dart
// Example Provider
class HistoryProvider with ChangeNotifier {
  List<ShoppingSession> _shoppingHistory = [];
  
  void addShoppingSession(List<GroceryItem> items) {
    // Business logic
    notifyListeners(); // Notify UI of changes
  }
}
```

### 2. Repository Pattern
**Why**: Abstracts data sources and provides a clean API for data access
**Usage**: Handling both local (SQLite) and remote (Firebase) data

```dart
abstract class GroceryRepository {
  Future<List<GroceryItem>> getItems();
  Future<void> addItem(GroceryItem item);
  Future<void> syncWithRemote();
}
```

### 3. Singleton Pattern
**Why**: Ensures single instance of critical services
**Usage**: Database helpers, authentication services

```dart
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
}
```

### 4. Observer Pattern
**Why**: Decoupled communication between components
**Usage**: Provider notifications, connectivity changes

## 📁 Project Structure

### Current Structure
```
lib/
├── Data/                    # Data Layer
│   ├── Auth.dart           # Authentication service
│   ├── DatabaseHelper.dart # Local database operations
│   ├── DataModel.dart      # Data models and entities
│   ├── HistoryProvider.dart # Shopping history management
│   ├── SettingsProvider.dart # App settings
│   ├── ThemeProvider.dart  # Theme management
│   ├── ConnectivityService.dart # Network status
│   ├── NotificationService.dart # In-app notifications
│   ├── BackupService.dart  # Data backup/restore
│   └── LocalStorageHelper.dart # SQLite operations
├── Screens/                 # Presentation Layer
│   ├── Home.dart           # Main home screen
│   ├── Login.dart          # Authentication screens
│   ├── Register.dart
│   ├── Settings.dart       # Settings screen
│   ├── ShoppingHistoryPage.dart # History & analytics
│   └── NotificationsPage.dart # Notifications view
├── Reusable/               # Shared Components
│   ├── GroceryItemCard.dart # Item display widget
│   ├── AddItemPage.dart    # Add/edit item form
│   ├── AnimatedDialog.dart # Custom dialogs
│   ├── AnimatedLoadingWidget.dart # Loading states
│   └── PageTransitions.dart # Navigation animations
└── main.dart               # App entry point
```

### Planned Structure (Future Refactoring)
```
lib/
├── core/                   # Core utilities and constants
│   ├── constants/          # App constants
│   ├── theme/             # Theme definitions
│   ├── services/          # Global services
│   └── utils/             # Utility functions
├── features/              # Feature-based modules
│   ├── auth/              # Authentication feature
│   │   ├── data/         # Auth data sources
│   │   ├── domain/       # Auth business logic
│   │   └── presentation/ # Auth UI
│   ├── grocery/           # Grocery management
│   ├── settings/          # App settings
│   └── notifications/     # Notifications
├── shared/                # Shared components
│   ├── widgets/          # Reusable widgets
│   ├── models/           # Data models
│   └── providers/        # Shared providers
└── main.dart
```

## 💾 Data Architecture

### Data Flow
```
UI Widget → Provider → Repository → Data Source → Storage
    ↑                                               ↓
    └─────────── notifyListeners() ←──────────────┘
```

### Storage Strategy
- **Local-First**: All data stored locally in SQLite
- **Sync When Online**: Firebase sync when connectivity available
- **Conflict Resolution**: Last-write-wins strategy
- **Offline Support**: Full functionality without internet

### Data Models

#### Core Models
```dart
// Primary entity
class GroceryItem {
  String? key;
  GroceryItemData? itemData;
  String category;
  String urgency;
  bool isCompleted;
  bool isSynced;
}

// Item details
class GroceryItemData {
  String name;
  String? description;
  String? category;
  String? urgency;
  List<String>? tags;
  bool isCompleted;
}

// Shopping session
class ShoppingSession {
  String id;
  List<GroceryItem> items;
  DateTime timestamp;
  int totalItems;
  double totalSpent;
}
```

## 🔄 State Management

### Provider Hierarchy
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => HistoryProvider()),
    ChangeNotifierProvider(create: (_) => SettingsProvider()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => NotificationService()),
    ChangeNotifierProvider(create: (_) => BackupService()),
  ],
  child: MyApp(),
)
```

### State Lifecycle
1. **Initialization**: Providers load data from local storage
2. **User Interaction**: UI triggers provider methods
3. **State Update**: Provider modifies state and calls `notifyListeners()`
4. **UI Rebuild**: Consumer widgets rebuild with new state
5. **Persistence**: Changed data saved to local storage
6. **Sync**: Background sync with Firebase when online

## 🌐 Network Architecture

### API Strategy
- **Primary**: Firebase Realtime Database
- **Authentication**: Firebase Auth
- **Offline Handling**: SQLite cache with sync queue
- **Error Handling**: Retry logic with exponential backoff

### Connectivity Handling
```dart
class ConnectivityService {
  Stream<ConnectivityResult> get onConnectivityChanged;
  Future<bool> isConnected();
  
  void _handleConnectivityChange(bool isConnected) {
    if (isConnected) {
      _syncPendingChanges();
    }
  }
}
```

## 🔐 Security Architecture

### Authentication Flow
```
App Start → Check Auth State → Login/Register → Firebase Auth
    ↓              ↓                ↓              ↓
Local Data → Load User Data → Store Auth Token → Access Control
```

### Data Security
- **Authentication**: Firebase Auth with email/password
- **Authorization**: User-specific data access rules
- **Local Storage**: SQLite with no sensitive data caching
- **Network**: HTTPS/TLS for all Firebase communication

## 📱 UI Architecture

### Component Hierarchy
```
MaterialApp
├── Theme Provider (Dark/Light)
├── Router/Navigator
└── Screen Widgets
    ├── AppBar
    ├── Body (Consumer Widgets)
    ├── FloatingActionButton
    └── Drawer/BottomNav
```

### Widget Design Principles
- **Reusability**: Create modular, configurable widgets
- **Responsiveness**: Support different screen sizes
- **Accessibility**: Proper semantics and contrast
- **Performance**: Efficient rebuilds with `Consumer` widgets

### Navigation Strategy
- **Declarative Routing**: Using Navigator 2.0 patterns
- **Page Transitions**: Custom animations for better UX
- **Deep Linking**: Support for URL-based navigation (future)

## ⚡ Performance Architecture

### Optimization Strategies
1. **Lazy Loading**: Load data on-demand
2. **Widget Rebuilding**: Minimize rebuilds with specific `Consumer` widgets
3. **Image Caching**: Cache category icons and user images
4. **Database Indexing**: Optimize SQLite queries
5. **Memory Management**: Proper disposal of controllers and streams

### Monitoring
- **Performance Metrics**: Track app startup time, frame rates
- **Memory Usage**: Monitor for memory leaks
- **Network Usage**: Track Firebase API calls
- **Error Tracking**: Log and track exceptions

## 🧪 Testing Architecture

### Testing Pyramid
```
┌─────────────────┐
│   E2E Tests     │  ← Full app workflows
├─────────────────┤
│ Integration     │  ← Widget interactions
├─────────────────┤
│  Unit Tests     │  ← Business logic
└─────────────────┘
```

### Test Strategy
- **Unit Tests**: Provider methods, utility functions
- **Widget Tests**: Individual widget behavior
- **Integration Tests**: Screen interactions and data flow
- **E2E Tests**: Complete user journeys

## 🔮 Future Architecture Considerations

### Scalability
- **Microservices**: Break into smaller, focused modules
- **Federation**: Support multiple data sources
- **Caching**: Advanced caching strategies
- **CDN**: Content delivery for static assets

### Technology Evolution
- **State Management**: Consider Riverpod or Bloc if complexity grows
- **Backend**: Evaluate cloud functions for complex operations
- **Real-time**: WebSocket connections for live collaboration
- **AI/ML**: On-device recommendations and smart features

## 📋 Architecture Decisions (ADR)

### ADR-001: Provider for State Management
**Decision**: Use Provider pattern for state management
**Rationale**: Simple, well-documented, good Flutter integration
**Alternatives Considered**: Bloc, Riverpod, GetX
**Status**: Accepted

### ADR-002: SQLite for Local Storage
**Decision**: Use SQLite via sqflite package
**Rationale**: Reliable, performant, good offline support
**Alternatives Considered**: Hive, SharedPreferences, Isar
**Status**: Accepted

### ADR-003: Firebase for Backend
**Decision**: Use Firebase Realtime Database
**Rationale**: Real-time sync, good authentication, minimal setup
**Alternatives Considered**: Custom REST API, Supabase, AWS
**Status**: Accepted

---

*This architecture documentation should be updated as the project evolves and new patterns are adopted.*
