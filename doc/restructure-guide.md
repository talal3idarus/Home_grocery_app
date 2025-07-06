# Project Structure Reorganization

## New Project Structure

The project has been reorganized to follow Flutter best practices with a feature-based architecture for better scalability and maintainability.

### Directory Structure

```
lib/
├── main.dart                           # App entry point
├── core/                              # Core functionality, shared across the app
│   ├── constants/                     # App constants and configuration
│   │   ├── app_constants.dart         # General app constants
│   │   └── app_strings.dart           # Text strings and localization
│   ├── theme/                         # Theme-related files
│   │   └── theme_provider.dart        # Theme management
│   ├── services/                      # Global services
│   │   ├── backup_service.dart        # Backup functionality
│   │   ├── connectivity_service.dart  # Network connectivity
│   │   └── local_storage_helper.dart  # Local storage operations
│   └── core.dart                      # Core exports
├── features/                          # Feature-based organization
│   ├── auth/                          # Authentication feature
│   │   ├── data/                      # Auth data layer
│   │   │   └── auth_service.dart      # Authentication service
│   │   ├── presentation/              # Auth UI components
│   │   │   ├── login_page.dart        # Login screen
│   │   │   └── register_page.dart     # Registration screen
│   │   └── auth.dart                  # Auth feature exports
│   ├── grocery/                       # Main grocery feature
│   │   ├── data/                      # Grocery data layer
│   │   │   └── database_helper.dart   # Database operations
│   │   ├── providers/                 # State management
│   │   │   └── history_provider.dart  # Shopping history management
│   │   ├── presentation/              # Grocery UI components
│   │   │   ├── home_page.dart         # Main home screen
│   │   │   └── shopping_history_page.dart # Shopping history screen
│   │   └── grocery.dart               # Grocery feature exports
│   ├── settings/                      # Settings feature
│   │   ├── providers/                 # Settings state management
│   │   │   └── settings_provider.dart # App settings management
│   │   ├── presentation/              # Settings UI
│   │   │   └── settings_page.dart     # Settings screen
│   │   └── settings.dart              # Settings feature exports
│   └── notifications/                 # Notifications feature
│       ├── data/                      # Notifications data layer
│       │   └── notification_service.dart # Notification service
│       ├── presentation/              # Notifications UI
│       │   └── notifications_page.dart # Notifications screen
│       └── notifications.dart         # Notifications feature exports
└── shared/                            # Shared components across features
    ├── models/                        # Shared data models
    │   └── data_model.dart            # Core data models
    ├── widgets/                       # Reusable UI components
    │   ├── AddItemPage.dart           # Add item dialog/page
    │   ├── AnimatedButton.dart        # Custom animated button
    │   ├── AnimatedDialog.dart        # Custom animated dialog
    │   ├── AnimatedGroceryItemCard.dart # Animated grocery item card
    │   ├── AnimatedLoadingWidget.dart # Loading animations
    │   ├── AnimatedSnackBar.dart      # Custom snackbar
    │   ├── EditItemPage.dart          # Edit item dialog/page
    │   ├── GroceryItemCard.dart       # Basic grocery item card
    │   └── PageTransitions.dart       # Custom page transitions
    └── shared.dart                    # Shared exports
```

## Benefits of New Structure

1. **Feature-based Organization**: Code is organized by features rather than by type (screens, data, etc.)
2. **Better Scalability**: Easy to add new features without cluttering existing folders
3. **Improved Maintainability**: Related code is grouped together
4. **Clear Separation of Concerns**: Data, presentation, and business logic are clearly separated
5. **Easier Testing**: Feature-based structure makes unit testing more straightforward
6. **Better Imports**: Centralized exports reduce import complexity

## Import Strategy

### Before (Old Structure)
```dart
import 'Screens/Home.dart';
import 'Data/HistoryProvider.dart';
import 'Data/ThemeProvider.dart';
import 'Reusable/AddItemPage.dart';
```

### After (New Structure)
```dart
import 'features/grocery/grocery.dart';
import 'core/core.dart';
import 'shared/shared.dart';
```

## Migration Status

✅ **Completed:**
- Created new folder structure
- Moved all files to appropriate locations
- Created centralized export files
- Updated core constants and strings
- Updated HistoryProvider to use new constants

🔄 **In Progress:**
- Updating import statements in all files
- Testing the new structure

⏳ **Remaining:**
- Update all import statements
- Remove old folders after verification
- Update documentation references

## Next Steps

1. Update all import statements in moved files
2. Test the application to ensure everything works
3. Remove old folders and files
4. Update any remaining documentation
5. Run final tests and builds

## Development Guidelines

### Adding New Features
1. Create a new folder under `features/`
2. Follow the established structure: `data/`, `presentation/`, `providers/` (if needed)
3. Create a feature export file (e.g., `feature_name.dart`)
4. Update imports in `main.dart` if needed

### Adding Shared Components
1. Add widgets to `shared/widgets/`
2. Add models to `shared/models/`
3. Update `shared/shared.dart` export file

### Adding Core Services
1. Add services to `core/services/`
2. Add constants to `core/constants/`
3. Update `core/core.dart` export file
