import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'DataModel.dart';
import 'LocalStorageHelper.dart';
import 'NotificationService.dart';

class BackupService with ChangeNotifier {
  final LocalStorageHelper _localStorage = LocalStorageHelper();
  final NotificationService _notificationService;
  
  bool _isBackingUp = false;
  DateTime? _lastBackupTime;
  bool _autoBackupEnabled = true;
  int _backupFrequencyHours = 24;

  BackupService(this._notificationService);

  bool get isBackingUp => _isBackingUp;
  DateTime? get lastBackupTime => _lastBackupTime;
  bool get autoBackupEnabled => _autoBackupEnabled;
  int get backupFrequencyHours => _backupFrequencyHours;

  static const String _lastBackupKey = 'last_backup_time';
  static const String _autoBackupKey = 'auto_backup_enabled';
  static const String _backupFrequencyKey = 'backup_frequency_hours';
  static const String _backupDataKey = 'backup_data';

  Future<void> loadBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lastBackupString = prefs.getString(_lastBackupKey);
    if (lastBackupString != null) {
      _lastBackupTime = DateTime.parse(lastBackupString);
    }
    
    _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? true;
    _backupFrequencyHours = prefs.getInt(_backupFrequencyKey) ?? 24;
    
    notifyListeners();
  }

  Future<void> saveBackupSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_lastBackupTime != null) {
      await prefs.setString(_lastBackupKey, _lastBackupTime!.toIso8601String());
    }
    
    await prefs.setBool(_autoBackupKey, _autoBackupEnabled);
    await prefs.setInt(_backupFrequencyKey, _backupFrequencyHours);
  }

  void setAutoBackupEnabled(bool enabled) {
    _autoBackupEnabled = enabled;
    saveBackupSettings();
    notifyListeners();
  }

  void setBackupFrequency(int hours) {
    _backupFrequencyHours = hours;
    saveBackupSettings();
    notifyListeners();
  }

  Future<Map<String, dynamic>> createBackupData() async {
    try {
      final groceryItems = await _localStorage.getAllGroceryItems();
      
      final backupData = {
        'version': '1.0.0',
        'timestamp': DateTime.now().toIso8601String(),
        'groceryItems': groceryItems.map((item) => item.toJson()).toList(),
        'deviceInfo': {
          'platform': defaultTargetPlatform.toString(),
          'backupSource': 'offline_backup',
        },
      };

      return backupData;
    } catch (e) {
      throw Exception('Failed to create backup data: $e');
    }
  }

  Future<bool> performBackup() async {
    if (_isBackingUp) return false;

    _isBackingUp = true;
    notifyListeners();

    try {
      final backupData = await createBackupData();
      final prefs = await SharedPreferences.getInstance();
      
      // Save backup data
      final backupJson = json.encode(backupData);
      await prefs.setString(_backupDataKey, backupJson);
      
      _lastBackupTime = DateTime.now();
      await saveBackupSettings();

      _notificationService.sendBackupComplete();
      
      _isBackingUp = false;
      notifyListeners();
      
      return true;
    } catch (e) {
      _isBackingUp = false;
      notifyListeners();
      
      _notificationService.addNotification(
        'Backup Failed',
        'Failed to create backup: ${e.toString()}',
        NotificationType.error,
      );
      
      return false;
    }
  }

  Future<bool> restoreFromBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final backupJson = prefs.getString(_backupDataKey);
      
      if (backupJson == null) {
        throw Exception('No backup data found');
      }

      final backupData = json.decode(backupJson) as Map<String, dynamic>;
      
      // Validate backup data
      if (!backupData.containsKey('groceryItems') || !backupData.containsKey('version')) {
        throw Exception('Invalid backup data format');
      }

      // Clear existing data
      await _localStorage.clearAllData();

      // Restore grocery items
      final groceryItemsData = backupData['groceryItems'] as List<dynamic>;
      for (final itemData in groceryItemsData) {
        final item = GroceryItem.fromJson(itemData);
        await _localStorage.insertGroceryItem(item);
      }

      _notificationService.addNotification(
        'Restore Complete',
        'Successfully restored ${groceryItemsData.length} items from backup',
        NotificationType.success,
      );

      return true;
    } catch (e) {
      _notificationService.addNotification(
        'Restore Failed',
        'Failed to restore from backup: ${e.toString()}',
        NotificationType.error,
      );
      
      return false;
    }
  }

  Future<String> exportBackupData() async {
    try {
      final backupData = await createBackupData();
      return json.encode(backupData);
    } catch (e) {
      throw Exception('Failed to export backup data: $e');
    }
  }

  Future<bool> importBackupData(String backupJson) async {
    try {
      final backupData = json.decode(backupJson) as Map<String, dynamic>;
      
      // Validate backup data
      if (!backupData.containsKey('groceryItems')) {
        throw Exception('Invalid backup data: missing groceryItems');
      }

      // Clear existing data
      await _localStorage.clearAllData();

      // Import grocery items
      final groceryItemsData = backupData['groceryItems'] as List<dynamic>;
      for (final itemData in groceryItemsData) {
        final item = GroceryItem.fromJson(itemData);
        await _localStorage.insertGroceryItem(item);
      }

      _notificationService.addNotification(
        'Import Complete',
        'Successfully imported ${groceryItemsData.length} items',
        NotificationType.success,
      );

      return true;
    } catch (e) {
      _notificationService.addNotification(
        'Import Failed',
        'Failed to import backup data: ${e.toString()}',
        NotificationType.error,
      );
      
      return false;
    }
  }

  bool shouldAutoBackup() {
    if (!_autoBackupEnabled || _lastBackupTime == null) {
      return _autoBackupEnabled;
    }

    final timeSinceLastBackup = DateTime.now().difference(_lastBackupTime!);
    return timeSinceLastBackup.inHours >= _backupFrequencyHours;
  }

  Future<void> checkAndPerformAutoBackup() async {
    if (shouldAutoBackup()) {
      await performBackup();
    }
  }

  Map<String, dynamic> getBackupStats() {
    return {
      'lastBackupTime': _lastBackupTime,
      'autoBackupEnabled': _autoBackupEnabled,
      'backupFrequencyHours': _backupFrequencyHours,
      'isBackingUp': _isBackingUp,
      'shouldAutoBackup': shouldAutoBackup(),
    };
  }

  void deleteBackupData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_backupDataKey);
    
    _notificationService.addNotification(
      'Backup Deleted',
      'Backup data has been deleted from device',
      NotificationType.info,
    );
  }
}
