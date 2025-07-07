# Home Grocery App 🛒

A modern### UI/UX Enhancements (Recent Updates)
- **Modern Home Screen**: Material 3 design with improved search and filtering
- **Minimalist Item Cards**: Clean grocery item display with swipe-to-delete
- **Enhanced Add Item Page**: Robust form validation and better user experience
- **Responsive Layout**: Fixed overflow issues and improved mobile layout
- **Colorful Category Icons**: Visual category identification with modern icons
- **Smooth Navigation**: Elegant sidebar with user profile and quick access
- **Loading States**: Beautiful loading animations and empty state messages

### Advanced Features
- **Shopping Analytics**: Track shopping history, spending, and patterns
- **Smart Notifications**: In-app notification system with history tracking
- **Data Backup & Restore**: Local backup functionality with export/import
- **Theme Customization**: Dark/light themes with system preference support
- **Settings Management**: Comprehensive app configuration options
- **Connectivity Monitoring**: Smart offline/online detection with sync status

### Recent Bug Fixes & Improvements
- 🐛 **Fixed RenderFlex overflow errors** in search and empty states
- 🐛 **Resolved "Cannot hit test a render box with no size" errors**
- 🐛 **Fixed persistent layout issues** in AddItemPage and item cards
- 🔧 **Improved build system** with latest Android toolchain
- 🔧 **Enhanced error handling** and user feedback
- 🎨 **Updated Material Design** components and theming
- ⚡ **Performance optimizations** for smoother animationsure-rich Flutter grocery management application with Material Design 3, offline support, analytics, notifications, and comprehensive user experience features.

## 📖 Documentation

**Complete documentation is available in the [`/doc`](./doc/) folder:**

- 📋 **[Project Overview](./doc/project-overview.md)** - Understanding the app's purpose and features
- 🏗️ **[Architecture](./doc/architecture.md)** - Technical architecture and design patterns  
- 🚀 **[Setup Guide](./doc/setup-guide.md)** - Complete installation and setup instructions
- 👤 **[User Guide](./doc/user-guide.md)** - How to use all app features
- �‍💻 **[Development Guide](./doc/development-guide.md)** - Developer information and build instructions
- 📚 **[API Reference](./doc/api-reference.md)** - Code documentation and API details
- � **[Changelog](./doc/changelog.md)** - Version history and recent updates

## 🌟 Features Overview

### Core Functionality
- **User Authentication**: Secure login, registration with Firebase Auth
- **Grocery Management**: Add, edit, delete, and organize grocery items with swipe gestures
- **Categories & Urgency**: Organize items with colorful categories and priority levels
- **Search & Filter**: Advanced search and filtering capabilities with real-time results
- **Offline Support**: Full offline functionality with automatic sync when online

### Modern UI/UX (Recently Updated)
- **Material Design 3**: Latest Material You theming with dynamic colors
- **Responsive Layout**: Adaptive design optimized for all screen sizes
- **Swipe Actions**: Intuitive swipe-to-delete with confirmation dialogs
- **Minimalist Cards**: Clean, modern grocery item cards with category icons
- **Smooth Animations**: Enhanced user experience with fluid transitions
- **Modern Sidebar**: Beautiful navigation drawer with user info and quick actions

### Advanced Features
- **Shopping Analytics**: Track shopping history, spending, and patterns
- **Smart Notifications**: In-app notification system with history tracking
- **Data Backup**: Local backup and restore functionality
- **Theme Customization**: Dark/light themes with system preference support
- **Settings Management**: Comprehensive app configuration options
- **Connectivity Monitoring**: Smart offline/online status with auto-sync

## 🚀 Quick Start

### Prerequisites
- **Flutter SDK**: 3.32.5+ (Latest stable)
- **Dart**: 3.8.1+
- **Android**: SDK 35, NDK 27.0.12077973
- **Firebase Project**: For authentication and database
- **Development IDE**: Android Studio or VS Code

### Installation
```bash
git clone <repository-url>
cd Home_grocery_app
flutter pub get
```

**For detailed setup instructions, see the [Setup Guide](./doc/setup-guide.md)**

## 🏗️ Build System (Recently Updated)

### Android Configuration
- **Android Gradle Plugin**: 8.7.2 (Latest)
- **Kotlin**: 1.9.25 (Stable)
- **Gradle**: 8.11.1
- **Compile SDK**: 35 (Android 15)
- **Target SDK**: Latest Flutter target
- **Min SDK**: 23 (Android 6.0+)
- **NDK**: 27.0.12077973 (Required for Firebase)
- **Java**: Version 17 (LTS)

### Recent Build Improvements
- ✅ **Resolved SDK XML version warnings** - Updated to latest Android toolchain
- ✅ **Fixed deprecated API warnings** - Proper compiler configurations
- ✅ **Eliminated Kotlin compilation errors** - Stable Kotlin version with proper cache management
- ✅ **NDK version compatibility** - Updated to match Firebase plugin requirements
- ✅ **Build performance optimized** - Faster builds with improved caching

### Quick Build Commands
```bash
# Clean build (recommended after updates)
flutter clean && flutter pub get

# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# Check for issues
flutter analyze
flutter doctor -v

## 📱 App Architecture

### Data Layer
- **Auth.dart**: Firebase authentication management
- **DatabaseHelper.dart**: Firebase Realtime Database operations
- **LocalStorageHelper.dart**: SQLite local storage for offline functionality
- **ConnectivityService.dart**: Network connectivity monitoring
- **ThemeProvider.dart**: Theme management and persistence

### UI Layer
- **Screens/**: Main application screens (Home, Login, Register)
- **Reusable/**: Reusable UI components and widgets
- **Animated Components**: Custom animated widgets for enhanced UX

### Key Components
```
lib/
├── Data/                    # Data management layer
│   ├── Auth.dart           # Authentication service
│   ├── DatabaseHelper.dart # Firebase database operations
│   ├── LocalStorageHelper.dart # Local SQLite operations
│   ├── ConnectivityService.dart # Network monitoring
│   ├── ThemeProvider.dart  # Theme management
│   └── DataModel.dart      # Data models
├── Screens/                # Main screens
│   ├── Home.dart          # Main grocery list screen
│   ├── Login.dart         # Login screen
│   └── Register.dart      # Registration screen
└── Reusable/              # Reusable components
    ├── AddItemPage.dart   # Add new item screen
    ├── EditItemPage.dart  # Edit existing item
    ├── GroceryItemCard.dart # Item display card
    ├── AnimatedGroceryItemCard.dart # Animated item card
    ├── AnimatedDialog.dart # Custom animated dialogs
    ├── AnimatedLoadingWidget.dart # Loading animations
    ├── AnimatedButton.dart # Animated buttons
    └── PageTransitions.dart # Custom page transitions
```

## 🎨 Features in Detail

### Authentication System
- **Secure Login**: Email/password authentication with validation
- **User Registration**: New user signup with form validation
- **Password Reset**: Email-based password recovery
- **Session Management**: Automatic login state persistence

### Grocery Management
- **Add Items**: Quick item addition with category and tag selection
- **Edit Items**: Inline editing of existing items
- **Delete Items**: Swipe-to-delete with confirmation dialogs
- **Item Completion**: Checkbox to mark items as completed/purchased
- **Categories**: Predefined categories (Fruits, Vegetables, Dairy, etc.)
- **Tags**: Custom tags for better organization

### Offline Functionality
- **Local Database**: SQLite storage for offline access
- **Auto Sync**: Automatic synchronization when connection is restored
- **Conflict Resolution**: Smart handling of data conflicts
- **Sync Status**: Visual indicators showing sync status

### Theme System
- **Light/Dark Mode**: Toggle between light and dark themes
- **Persistent Settings**: Theme preference saved locally
- **Adaptive Colors**: Theme-aware color schemes
- **Smooth Transitions**: Animated theme switching

### Bulk Operations
- **Multi-Select Mode**: Long-press to enter selection mode
- **Batch Actions**: Delete or complete multiple items at once
- **Selection UI**: Clear visual feedback for selected items
- **Quick Actions**: Bottom action bar for bulk operations

## 🛠️ Dependencies

### Core Dependencies
- `flutter`: UI framework
- `firebase_auth`: Authentication
- `firebase_database`: Real-time database
- `firebase_core`: Firebase core functionality

### Local Storage & Connectivity
- `sqflite`: Local SQLite database
- `path`: File path manipulation
- `connectivity_plus`: Network connectivity monitoring

### State Management & Utilities
- `provider`: State management
- `shared_preferences`: Local preferences storage

### UI & Animations
- Various Flutter animation libraries for enhanced user experience

## 🔧 Configuration

### Firebase Configuration
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an Android app to your project
3. Download `google-services.json` and place in `android/app/`
4. Enable Authentication and Realtime Database

### Database Rules
Set up Firebase Realtime Database rules:
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

## 🧪 Testing

Run tests:
```bash
flutter test
```

The app includes:
- Unit tests for data models
- Widget tests for UI components
- Integration test coverage for core features

## 🚀 Building for Release

### Android
```bash
flutter build apk --release
```

### Generate signed APK
```bash
flutter build apk --split-per-abi
```

## 📝 Development Notes

### Code Quality
- Follows Flutter best practices
- Comprehensive error handling
- Responsive design patterns
- Clean architecture principles

### Performance
- Efficient list rendering with ListView.builder
- Lazy loading for large datasets
- Optimized animations and transitions
- Memory-efficient image handling

### Accessibility
- Semantic labels for screen readers
- High contrast support
- Keyboard navigation support
- Font scaling support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Community contributors and testers

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

**Happy Grocery Shopping! 🛒✨**
