/// App-wide constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'Grocery List';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themePreferenceKey = 'theme_preference';
  static const String settingsKey = 'app_settings';
  static const String shoppingHistoryKey = 'shopping_history';
  static const String itemFrequencyKey = 'item_frequency';
  static const String lastPurchasedKey = 'last_purchased';
  static const String notificationsKey = 'notifications';
  static const String backupSettingsKey = 'backup_settings';
  
  // Default Values
  static const int maxHistorySessions = 50;
  static const double defaultItemPrice = 5.0;
  static const int maxNotifications = 100;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
}

/// Feature flags for enabling/disabling features
class FeatureFlags {
  static const bool enableAnalytics = true;
  static const bool enableBackup = true;
  static const bool enableNotifications = true;
  static const bool enableOfflineMode = true;
}

/// Error messages
class ErrorMessages {
  static const String networkError = 'Network connection error. Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String dataLoadError = 'Failed to load data. Please try again.';
  static const String dataSaveError = 'Failed to save data. Please try again.';
  static const String unknownError = 'An unexpected error occurred. Please try again.';
}
