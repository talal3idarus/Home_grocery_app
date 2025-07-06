# Development Guide

This guide covers development standards, coding practices, and contribution guidelines for the Home Grocery App.

## 🛠️ Development Environment

### Required Tools
- **Flutter SDK**: Version 3.0 or higher
- **Dart SDK**: Version 2.17 or higher  
- **IDE**: Android Studio (recommended) or VS Code
- **Git**: For version control
- **Firebase CLI**: For backend management

### Recommended VS Code Extensions
```json
{
  "recommendations": [
    "dart-code.flutter",
    "dart-code.dart-code",
    "ms-vscode.vscode-json",
    "bradlc.vscode-tailwindcss",
    "usernamehw.errorlens"
  ]
}
```

### Project Setup
```bash
# Clone repository
git clone <repository-url>
cd Home_grocery_app

# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter packages pub run build_runner build

# Run the app
flutter run
```

## 📝 Coding Standards

### Dart Style Guide
Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style):

#### Naming Conventions
```dart
// Classes: PascalCase
class GroceryItemProvider extends ChangeNotifier {}

// Methods and variables: camelCase
void addGroceryItem() {}
String itemName = '';

// Constants: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = 'https://api.example.com';

// Private members: prefix with underscore
String _privateProperty;
void _privateMethod() {}
```

#### File Organization
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

// 4. Local imports
import '../Data/DatabaseHelper.dart';
import '../Models/GroceryItem.dart';
```

### Code Structure

#### Widget Structure
```dart
class ExampleWidget extends StatefulWidget {
  // 1. Constructor and properties
  const ExampleWidget({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends State<ExampleWidget> {
  // 2. State variables
  bool _isLoading = false;
  
  // 3. Lifecycle methods
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }

  // 4. Private methods
  void _initialize() {
    // Implementation
  }

  // 5. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Implementation
    );
  }

  // 6. Helper methods (if any)
  Widget _buildCustomWidget() {
    // Implementation
  }
}
```

#### Provider Structure
```dart
class ExampleProvider extends ChangeNotifier {
  // 1. Private state variables
  List<Item> _items = [];
  bool _isLoading = false;

  // 2. Public getters
  List<Item> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // 3. Public methods
  Future<void> loadItems() async {
    _setLoading(true);
    try {
      // Implementation
      notifyListeners();
    } catch (e) {
      // Error handling
    } finally {
      _setLoading(false);
    }
  }

  // 4. Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

## 🏗️ Architecture Guidelines

### State Management
- Use **Provider** pattern for app-wide state
- Keep providers focused on single responsibilities
- Use `Consumer` widgets to limit rebuilds
- Dispose of resources properly in provider dispose methods

### Data Layer
```dart
abstract class Repository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<void> save(T item);
  Future<void> delete(String id);
}

class GroceryRepository implements Repository<GroceryItem> {
  final DatabaseHelper _dbHelper;
  final FirebaseService _firebaseService;
  
  // Implementation
}
```

### Error Handling
```dart
// Use Result pattern for better error handling
abstract class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;
  const Failure(this.message, [this.exception]);
}
```

## 🧪 Testing Guidelines

### Test Structure
```
test/
├── unit/           # Unit tests
│   ├── providers/  # Provider tests
│   ├── services/   # Service tests
│   └── utils/      # Utility tests
├── widget/         # Widget tests
└── integration/    # Integration tests
```

### Unit Testing
```dart
void main() {
  group('GroceryProvider', () {
    late GroceryProvider provider;

    setUp(() {
      provider = GroceryProvider();
    });

    test('should add item to list', () {
      // Arrange
      const item = GroceryItem(name: 'Test Item');
      
      // Act
      provider.addItem(item);
      
      // Assert
      expect(provider.items.length, 1);
      expect(provider.items.first.name, 'Test Item');
    });
  });
}
```

### Widget Testing
```dart
void main() {
  testWidgets('GroceryItemCard displays item name', (tester) async {
    // Arrange
    const item = GroceryItem(name: 'Test Item');
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: GroceryItemCard(item: item),
      ),
    );
    
    // Assert
    expect(find.text('Test Item'), findsOneWidget);
  });
}
```

## 📦 Package Management

### Adding Dependencies
```bash
# Add a new dependency
flutter pub add package_name

# Add a dev dependency
flutter pub add --dev package_name

# Update dependencies
flutter pub upgrade
```

### Dependency Guidelines
- Prefer official Flutter/Dart packages
- Check package popularity and maintenance status
- Pin versions for production builds
- Document why each dependency is needed

## 🔧 Build and Deployment

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release

# App bundle (recommended for Play Store)
flutter build appbundle --release

# iOS build (macOS only)
flutter build ios --release
```

### Environment Configuration
```dart
// lib/config/environment.dart
abstract class Environment {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://api.example.com',
  );
  
  static const bool isProduction = bool.fromEnvironment('PRODUCTION');
}
```

## 🔍 Code Review Guidelines

### Before Submitting
- [ ] Code follows Dart style guide
- [ ] All tests pass
- [ ] No lint warnings
- [ ] Documentation updated if needed
- [ ] Breaking changes documented

### Review Checklist
- [ ] Code is readable and well-documented
- [ ] Error handling is appropriate
- [ ] Performance considerations addressed
- [ ] Security best practices followed
- [ ] UI/UX is consistent with design

## 📊 Performance Guidelines

### Widget Optimization
```dart
// Use const constructors when possible
const Text('Static text');

// Minimize widget rebuilds
Consumer<GroceryProvider>(
  builder: (context, provider, child) {
    return Text(provider.itemCount.toString());
  },
);

// Use ListView.builder for large lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemWidget(items[index]),
);
```

### Memory Management
- Dispose of controllers and streams
- Use weak references when appropriate
- Monitor memory usage during development
- Implement pagination for large datasets

## 🚀 Git Workflow

### Branch Naming
- `feature/add-barcode-scanning`
- `bugfix/fix-sync-issue`
- `hotfix/critical-crash-fix`
- `refactor/improve-provider-structure`

### Commit Messages
```
type(scope): description

feat(auth): add biometric authentication
fix(sync): resolve Firebase connection timeout
docs(readme): update setup instructions
refactor(providers): simplify state management
```

### Pull Request Process
1. Create feature branch from `develop`
2. Implement changes with tests
3. Update documentation if needed
4. Submit PR with clear description
5. Address review feedback
6. Merge after approval

## 📱 Platform-Specific Guidelines

### Android
- Follow Material Design principles
- Test on different Android versions
- Optimize for various screen sizes
- Consider Android-specific features

### iOS (Future)
- Follow Human Interface Guidelines
- Test on different iOS versions
- Consider iOS-specific patterns
- Handle platform differences gracefully

## 🔒 Security Guidelines

### Data Protection
- Never store sensitive data in SharedPreferences
- Use secure storage for authentication tokens
- Validate all user inputs
- Implement proper authentication checks

### API Security
- Use HTTPS for all network requests
- Implement proper error handling
- Don't expose sensitive information in logs
- Follow Firebase security best practices

## 📚 Learning Resources

### Flutter/Dart
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Flutter Cookbook](https://flutter.dev/docs/cookbook)

### State Management
- [Provider Documentation](https://pub.dev/packages/provider)
- [State Management Options](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)

### Firebase
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

## 🆘 Getting Help

### Internal Resources
- Check existing documentation
- Review similar implementations in codebase
- Ask team members for guidance

### External Resources
- Stack Overflow (tag: flutter, dart)
- Flutter Community Discord
- GitHub Issues for package-specific problems

---

**Remember**: Good code is not just working code, but code that is readable, maintainable, and follows established patterns.

**Last Updated**: July 7, 2025
