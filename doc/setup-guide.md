# Setup Guide

This guide will help you set up the Home Grocery App development environment and get the project running on your local machine.

## 📋 Prerequisites

### Required Software
1. **Flutter SDK** (3.0 or later)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH

2. **Dart SDK** (Included with Flutter)

3. **IDE** (Choose one):
   - **Android Studio** (Recommended) - Full Flutter support
   - **Visual Studio Code** - With Flutter/Dart extensions
   - **IntelliJ IDEA** - With Flutter plugin

4. **Platform-specific requirements**:
   - **Android**: Android SDK, Android Emulator or physical device
   - **iOS** (macOS only): Xcode, iOS Simulator or physical device

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Realtime Database
4. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

## 🚀 Installation Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd Home_grocery_app
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Firebase

#### Android Configuration
1. Place `google-services.json` in `android/app/`
2. Verify the file is in the correct location:
   ```
   android/
     app/
       google-services.json  ← Should be here
   ```

#### iOS Configuration (if targeting iOS)
1. Place `GoogleService-Info.plist` in `ios/Runner/`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Add the file to the Runner target

### 4. Verify Installation
```bash
flutter doctor
```
Fix any issues reported by Flutter Doctor.

### 5. Run the App
```bash
# Run on connected device/emulator
flutter run

# Run in debug mode
flutter run --debug

# Run on specific device
flutter devices
flutter run -d <device-id>
```

## 🔧 Development Environment Setup

### Android Studio Setup
1. Install Flutter and Dart plugins
2. Configure Flutter SDK path in Settings
3. Set up Android Emulator:
   - Tools → AVD Manager
   - Create Virtual Device
   - Choose a system image (API 21+)

### VS Code Setup
1. Install extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets (optional)
2. Open Command Palette (Ctrl+Shift+P)
3. Run "Flutter: New Project" to verify setup

### Device Setup

#### Android Physical Device
1. Enable Developer Options
2. Enable USB Debugging
3. Connect via USB
4. Accept debugging permissions

#### Android Emulator
1. Open Android Studio
2. Tools → AVD Manager
3. Create Virtual Device
4. Start emulator

#### iOS Simulator (macOS only)
1. Install Xcode from App Store
2. Open Simulator app
3. Choose iOS version and device

## 📁 Project Structure Overview

```
Home_grocery_app/
├── android/           # Android-specific files
├── ios/              # iOS-specific files
├── lib/              # Flutter/Dart source code
│   ├── Data/         # Data models and providers
│   ├── Reusable/     # Reusable widgets
│   ├── Screens/      # App screens
│   └── main.dart     # App entry point
├── test/             # Unit and widget tests
├── doc/              # Documentation
├── pubspec.yaml      # Project dependencies
└── README.md         # Project README
```

## 🔥 Firebase Configuration Details

### Realtime Database Rules
```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    },
    "grocery_items": {
      "$uid": {
        ".read": "$uid === auth.uid",
        ".write": "$uid === auth.uid"
      }
    }
  }
}
```

### Authentication Settings
1. Sign-in method: Email/Password
2. Authorized domains: Add your domain if deploying
3. Email templates: Customize as needed

## 🐛 Troubleshooting

### Common Issues

#### Flutter Doctor Issues
```bash
# Update Flutter
flutter upgrade

# Fix Android license issues
flutter doctor --android-licenses

# Clear Flutter cache
flutter clean
flutter pub get
```

#### Build Issues
```bash
# Clean build
flutter clean
cd android && ./gradlew clean && cd ..
flutter pub get
flutter run
```

#### Firebase Connection Issues
1. Verify `google-services.json` is in correct location
2. Check Firebase project configuration
3. Ensure internet connectivity
4. Check Firebase console for any service issues

#### Dependency Issues
```bash
# Update dependencies
flutter pub upgrade

# Get specific package
flutter pub add <package_name>

# Remove dependency conflicts
flutter pub deps
```

### Performance Issues
1. Run in release mode: `flutter run --release`
2. Use physical device instead of emulator
3. Check for memory leaks in debug mode

## 📱 Testing

### Run Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter drive --target=test_driver/app.dart

# Test on specific device
flutter test -d <device-id>
```

### Debug Mode Features
- Hot reload: Press `r` in terminal
- Hot restart: Press `R` in terminal
- Debug console: Use `print()` statements
- Flutter Inspector: Available in IDEs

## 🚀 Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## 🔐 Environment Variables

Create a `.env` file in the root directory (not tracked in git):
```
FIREBASE_API_KEY=your_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
```

## 📚 Next Steps

After successful setup:
1. Read the [User Guide](user-guide.md) to understand app features
2. Check the [Development Guide](development-guide.md) for coding standards
3. Review the [Architecture](architecture.md) documentation
4. Start developing or testing the app

## 🆘 Getting Help

- Check [Known Issues](known-issues.md)
- Review Flutter documentation: [flutter.dev](https://flutter.dev)
- Firebase documentation: [firebase.google.com](https://firebase.google.com/docs)
- Stack Overflow: Tag questions with `flutter` and `firebase`

---

*If you encounter any issues not covered here, please create an issue or update this documentation.*
