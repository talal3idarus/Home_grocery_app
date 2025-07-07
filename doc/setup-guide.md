# Setup Guide

This guide will help you set up the Home Grocery App development environment and get the project running on your local machine.

## 📋 Prerequisites

### Required Software & Versions (Updated 2025-07-08)
1. **Flutter SDK** (3.32.5 or later) - Latest stable
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Add Flutter to your PATH
   - Verify: `flutter --version`

2. **Dart SDK** (3.8.1 or later) - Included with Flutter

3. **Android Development Tools**:
   - **Android SDK**: API Level 35 (Android 15)
   - **Android NDK**: 27.0.12077973 (Required for Firebase)
   - **Build Tools**: 35.0.0
   - **Java**: OpenJDK 17 (LTS) - Required for Gradle
   - **Android Gradle Plugin**: 8.7.2
   - **Gradle**: 8.11.1
   - **Kotlin**: 1.9.25

4. **IDE** (Choose one):
   - **Android Studio** (2024.1+) - Recommended for full Flutter support
   - **Visual Studio Code** - With Flutter/Dart extensions
   - **IntelliJ IDEA** - With Flutter plugin

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication (Email/Password)
3. Enable Realtime Database
4. Download configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS

## 🚀 Installation Steps

### 1. Environment Verification
Before starting, verify your environment:
```bash
# Check Flutter installation
flutter doctor -v

# Check Android toolchain
flutter doctor --android-licenses

# Verify Java version (should be 17)
java -version
```

### 2. Clone the Repository
```bash
git clone <repository-url>
cd Home_grocery_app
```

### 3. Install Dependencies
```bash
flutter clean
flutter pub get
```

### 4. Configure Firebase

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

### 5. Verify Installation
```bash
flutter doctor
```
Fix any issues reported by Flutter Doctor.

### 6. Run the App
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

## 🔧 Build System Updates (July 2025)

### Recent Improvements
The project has been updated with the latest Android build tools:

- ✅ **Android Gradle Plugin**: Updated to 8.7.2
- ✅ **Kotlin**: Updated to 1.9.25 (stable)
- ✅ **Gradle**: Updated to 8.11.1
- ✅ **Compile SDK**: Updated to 35 (Android 15)
- ✅ **NDK**: Updated to 27.0.12077973
- ✅ **Build warnings resolved**: SDK XML and deprecated API warnings fixed

### Build Configuration Verification
Check your `android/app/build.gradle` for these settings:
```gradle
android {
    compileSdk = 35
    ndkVersion = "27.0.12077973"
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    defaultConfig {
        minSdkVersion 23
        targetSdk = flutter.targetSdkVersion
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }
}
```

### Build Commands (Updated)
```bash
# Clean and rebuild (recommended after updates)
flutter clean
flutter pub get
flutter build apk --debug

# Verify no issues
flutter analyze
flutter doctor -v

# Production build
flutter build apk --release
```

## 🔧 Troubleshooting

### Common Build Issues

#### SDK XML Version Warning (RESOLVED)
This warning has been resolved in the latest build system update. If you still see it:
```bash
flutter clean
flutter pub get
```

#### Deprecated API Warnings (RESOLVED)
These warnings have been suppressed with proper compiler configurations. The warnings were from external dependencies, not project code.

#### Kotlin Compilation Errors
If you encounter Kotlin compilation issues:
```bash
# Clear all caches
flutter clean
rm -rf android/.gradle
rm -rf build
flutter pub get
```

#### NDK Version Conflicts
If you see NDK version warnings:
- The project now uses NDK 27.0.12077973 (latest required by Firebase)
- This is automatically configured in build.gradle

### Legacy Issues (Pre-July 2025)
