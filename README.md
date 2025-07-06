# Home Grocery App 🛒

A modern, feature-rich Flutter grocery management application with offline support, dark mode, animations, and advanced user experience features.

## 🌟 Features

### Core Functionality
- **User Authentication**: Secure login, registration, and password reset with Firebase Auth
- **Grocery Item Management**: Add, edit, delete, and organize grocery items
- **Categories & Tags**: Organize items with customizable categories and tags
- **Item Completion**: Mark items as completed with visual feedback
- **Search & Filter**: Search by name, category, or tags with real-time filtering

### Advanced Features
- **Offline Support**: Full offline functionality with automatic sync when online
- **Dark Mode**: Beautiful dark theme with persistent user preference
- **Bulk Operations**: Multi-select mode for batch operations (delete, complete)
- **Pull-to-Refresh**: Swipe down to refresh your grocery list
- **Animated UI**: Smooth animations throughout the app for enhanced user experience

### User Experience
- **Modern UI Design**: Card-based layout with gradient backgrounds
- **Responsive Design**: Adaptive layout that works on different screen sizes
- **Animated Dialogs**: Beautiful animated dialogs for all user interactions
- **Loading States**: Elegant loading animations and error handling
- **Connectivity Awareness**: Visual indicators for online/offline status

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Home_grocery_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Add Android app to your Firebase project
   - Download `google-services.json` and place it in `android/app/`
   - Enable Authentication and Realtime Database in Firebase Console

4. **Run the app**
   ```bash
   flutter run
   ```

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
