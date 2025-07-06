// Migration helper for updating import statements
// This file contains mappings from old imports to new imports

class ImportMigrationHelper {
  static const Map<String, String> importMappings = {
    // Old Data imports -> New structure
    'Data/Auth.dart': 'features/auth/data/auth_service.dart',
    'Data/HistoryProvider.dart': 'features/grocery/providers/history_provider.dart',
    'Data/SettingsProvider.dart': 'features/settings/providers/settings_provider.dart',
    'Data/ThemeProvider.dart': 'core/theme/theme_provider.dart',
    'Data/NotificationService.dart': 'features/notifications/data/notification_service.dart',
    'Data/BackupService.dart': 'core/services/backup_service.dart',
    'Data/ConnectivityService.dart': 'core/services/connectivity_service.dart',
    'Data/LocalStorageHelper.dart': 'core/services/local_storage_helper.dart',
    'Data/DatabaseHelper.dart': 'features/grocery/data/database_helper.dart',
    'Data/DataModel.dart': 'shared/models/data_model.dart',
    
    // Old Screen imports -> New structure
    'Screens/Home.dart': 'features/grocery/presentation/home_page.dart',
    'Screens/Login.dart': 'features/auth/presentation/login_page.dart',
    'Screens/Register.dart': 'features/auth/presentation/register_page.dart',
    'Screens/Settings.dart': 'features/settings/presentation/settings_page.dart',
    'Screens/ShoppingHistoryPage.dart': 'features/grocery/presentation/shopping_history_page.dart',
    'Screens/NotificationsPage.dart': 'features/notifications/presentation/notifications_page.dart',
    
    // Old Reusable imports -> New structure
    'Reusable/AddItemPage.dart': 'shared/widgets/AddItemPage.dart',
    'Reusable/AnimatedButton.dart': 'shared/widgets/AnimatedButton.dart',
    'Reusable/AnimatedDialog.dart': 'shared/widgets/AnimatedDialog.dart',
    'Reusable/AnimatedGroceryItemCard.dart': 'shared/widgets/AnimatedGroceryItemCard.dart',
    'Reusable/AnimatedLoadingWidget.dart': 'shared/widgets/AnimatedLoadingWidget.dart',
    'Reusable/AnimatedSnackBar.dart': 'shared/widgets/AnimatedSnackBar.dart',
    'Reusable/EditItemPage.dart': 'shared/widgets/EditItemPage.dart',
    'Reusable/GroceryItemCard.dart': 'shared/widgets/GroceryItemCard.dart',
    'Reusable/PageTransitions.dart': 'shared/widgets/PageTransitions.dart',
  };
  
  // Feature-based imports (recommended approach)
  static const Map<String, String> featureImports = {
    'auth': 'features/auth/auth.dart',
    'grocery': 'features/grocery/grocery.dart',
    'settings': 'features/settings/settings.dart',
    'notifications': 'features/notifications/notifications.dart',
    'core': 'core/core.dart',
    'shared': 'shared/shared.dart',
  };
  
  // Files that need import updates
  static const List<String> filesToUpdate = [
    'lib/main.dart',
    'lib/features/auth/presentation/login_page.dart',
    'lib/features/auth/presentation/register_page.dart',
    'lib/features/grocery/presentation/home_page.dart',
    'lib/features/grocery/presentation/shopping_history_page.dart',
    'lib/features/settings/presentation/settings_page.dart',
    'lib/features/notifications/presentation/notifications_page.dart',
    'lib/features/notifications/data/notification_service.dart',
    'lib/core/services/backup_service.dart',
    'lib/shared/widgets/AddItemPage.dart',
    'lib/shared/widgets/EditItemPage.dart',
    // Add more files as needed
  ];
}
