import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _notificationsKey = 'notifications_enabled';
  static const String _autoSyncKey = 'auto_sync_enabled';
  static const String _confirmDeletionKey = 'confirm_deletion';
  static const String _biometricAuthKey = 'biometric_auth';
  static const String _defaultCategoryKey = 'default_category';
  static const String _sortByKey = 'sort_by';
  
  SharedPreferences? _prefs;
  
  // Settings values
  bool _notificationsEnabled = true;
  bool _autoSync = true;
  bool _confirmDeletion = true;
  bool _biometricAuth = false;
  String _defaultCategory = 'Other';
  String _sortBy = 'Name';
  
  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSync => _autoSync;
  bool get confirmDeletion => _confirmDeletion;
  bool get biometricAuth => _biometricAuth;
  String get defaultCategory => _defaultCategory;
  String get sortBy => _sortBy;
  
  SettingsProvider() {
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = _prefs?.getBool(_notificationsKey) ?? true;
    _autoSync = _prefs?.getBool(_autoSyncKey) ?? true;
    _confirmDeletion = _prefs?.getBool(_confirmDeletionKey) ?? true;
    _biometricAuth = _prefs?.getBool(_biometricAuthKey) ?? false;
    _defaultCategory = _prefs?.getString(_defaultCategoryKey) ?? 'Other';
    _sortBy = _prefs?.getString(_sortByKey) ?? 'Name';
    
    notifyListeners();
  }
  
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs?.setBool(_notificationsKey, value);
    notifyListeners();
  }
  
  Future<void> setAutoSync(bool value) async {
    _autoSync = value;
    await _prefs?.setBool(_autoSyncKey, value);
    notifyListeners();
  }
  
  Future<void> setConfirmDeletion(bool value) async {
    _confirmDeletion = value;
    await _prefs?.setBool(_confirmDeletionKey, value);
    notifyListeners();
  }
  
  Future<void> setBiometricAuth(bool value) async {
    _biometricAuth = value;
    await _prefs?.setBool(_biometricAuthKey, value);
    notifyListeners();
  }
  
  Future<void> setDefaultCategory(String value) async {
    _defaultCategory = value;
    await _prefs?.setString(_defaultCategoryKey, value);
    notifyListeners();
  }
  
  Future<void> setSortBy(String value) async {
    _sortBy = value;
    await _prefs?.setString(_sortByKey, value);
    notifyListeners();
  }
  
  // Reset all settings to defaults
  Future<void> resetToDefaults() async {
    _notificationsEnabled = true;
    _autoSync = true;
    _confirmDeletion = true;
    _biometricAuth = false;
    _defaultCategory = 'Other';
    _sortBy = 'Name';
    
    await _prefs?.setBool(_notificationsKey, _notificationsEnabled);
    await _prefs?.setBool(_autoSyncKey, _autoSync);
    await _prefs?.setBool(_confirmDeletionKey, _confirmDeletion);
    await _prefs?.setBool(_biometricAuthKey, _biometricAuth);
    await _prefs?.setString(_defaultCategoryKey, _defaultCategory);
    await _prefs?.setString(_sortByKey, _sortBy);
    
    notifyListeners();
  }
  
  // Get all available categories
  List<String> get availableCategories => [
    'Fruits', 'Vegetables', 'Dairy', 'Meat', 'Bakery', 
    'Beverages', 'Snacks', 'Household', 'Personal Care', 'Other'
  ];
  
  // Get all available sort options
  List<String> get availableSortOptions => [
    'Name', 'Date Added', 'Category', 'Priority', 'Completion Status'
  ];
}
