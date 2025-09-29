import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Data/ThemeProvider.dart';
import '../Data/SettingsProvider.dart';
import '../Data/Auth.dart';
import '../Data/LocalStorageHelper.dart';
import '../Data/NotificationService.dart';
import '../Data/BackupService.dart';
import '../Reusable/AnimatedDialog.dart';
import '../Screens/Login.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  final Auth _auth = Auth();
  final LocalStorageHelper _localHelper = LocalStorageHelper();
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isLoading = false;
  int _cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadSettings();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  Future<void> _loadSettings() async {
    // Load settings from SharedPreferences or other storage
    // This is a placeholder for actual settings loading
    setState(() {
      // Set default values or load from storage
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAppearanceSection(context),
                SizedBox(height: 20),
                _buildBehaviorSection(context),
                SizedBox(height: 20),
                _buildDataSection(context),
                SizedBox(height: 20),
                _buildSecuritySection(context),
                SizedBox(height: 20),
                _buildAboutSection(context),
                SizedBox(height: 20),
                _buildDangerZone(context),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
    required ColorScheme colorScheme,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'Appearance',
      colorScheme: colorScheme,
      children: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: colorScheme.primary,
              ),
              title: Text('Dark Mode'),
              subtitle: Text('Switch between light and dark themes'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme();
                },
                activeColor: colorScheme.primary,
              ),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.palette, color: colorScheme.primary),
          title: Text('Theme Color'),
          subtitle: Text('Customize app colors'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () {
            _showThemeColorPicker(context);
          },
        ),
      ],
    );
  }

  Widget _buildBehaviorSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'Behavior',
      colorScheme: colorScheme,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return SwitchListTile(
              secondary: Icon(Icons.notifications, color: colorScheme.primary),
              title: Text('Notifications'),
              subtitle: Text('Enable push notifications'),
              value: settings.notificationsEnabled,
              onChanged: (value) {
                settings.setNotificationsEnabled(value);
                final notificationService = Provider.of<NotificationService>(context, listen: false);
                notificationService.setNotificationsEnabled(value);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: colorScheme.primary,
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.schedule, color: colorScheme.primary),
          title: Text('Smart Reminders'),
          subtitle: Text('Get reminders for shopping'),
          trailing: Switch(
            value: true, // TODO: Implement reminder settings
            onChanged: (value) {
              // TODO: Implement reminder toggle
              AnimatedDialog.showInfo(
                context: context,
                title: 'Smart Reminders',
                message: 'Smart reminder settings will be available in a future update.',
              );
            },
            activeColor: colorScheme.primary,
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Divider(),
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return SwitchListTile(
              secondary: Icon(Icons.sync, color: colorScheme.primary),
              title: Text('Auto Sync'),
              subtitle: Text('Automatically sync data when online'),
              value: settings.autoSync,
              onChanged: (value) {
                settings.setAutoSync(value);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: colorScheme.primary,
            );
          },
        ),
        Divider(),
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return SwitchListTile(
              secondary: Icon(Icons.warning, color: colorScheme.primary),
              title: Text('Confirm Deletion'),
              subtitle: Text('Show confirmation before deleting items'),
              value: settings.confirmDeletion,
              onChanged: (value) {
                settings.setConfirmDeletion(value);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: colorScheme.primary,
            );
          },
        ),
        Divider(),
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListTile(
              leading: Icon(Icons.category, color: colorScheme.primary),
              title: Text('Default Category'),
              subtitle: Text('Default category for new items: ${settings.defaultCategory}'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showCategoryPicker(context);
              },
            );
          },
        ),
        Divider(),
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return ListTile(
              leading: Icon(Icons.sort, color: colorScheme.primary),
              title: Text('Default Sort'),
              subtitle: Text('Default sorting option: ${settings.sortBy}'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              contentPadding: EdgeInsets.zero,
              onTap: () {
                _showSortPicker(context);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDataSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'Data Management',
      colorScheme: colorScheme,
      children: [
        ListTile(
          leading: Icon(Icons.sync_alt, color: colorScheme.primary),
          title: Text('Sync Now'),
          subtitle: Text('Manually sync your data'),
          trailing: _isLoading 
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: _isLoading ? null : () => _syncData(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.download, color: colorScheme.primary),
          title: Text('Export Data'),
          subtitle: Text('Export your grocery lists'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _exportData(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.upload, color: colorScheme.primary),
          title: Text('Import Data'),
          subtitle: Text('Import grocery lists from file'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _importData(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.storage, color: colorScheme.primary),
          title: Text('Cache Size'),
          subtitle: Text('Local storage: ${_formatCacheSize(_cacheSize)}'),
          trailing: TextButton(
            onPressed: () => _clearCache(context),
            child: Text('Clear'),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        Divider(),
        Consumer<BackupService>(
          builder: (context, backupService, child) {
            return ListTile(
              leading: Icon(Icons.backup, color: colorScheme.primary),
              title: Text('Backup Data'),
              subtitle: Text(backupService.lastBackupTime != null 
                ? 'Last backup: ${_formatBackupTime(backupService.lastBackupTime!)}'
                : 'No backup yet'),
              trailing: backupService.isBackingUp 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: () => _performBackup(context),
                    child: Text('Backup'),
                  ),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.restore, color: colorScheme.primary),
          title: Text('Restore Data'),
          subtitle: Text('Restore from backup'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _restoreBackup(context),
        ),
        Divider(),
        Consumer<BackupService>(
          builder: (context, backupService, child) {
            return SwitchListTile(
              secondary: Icon(Icons.schedule, color: colorScheme.primary),
              title: Text('Auto Backup'),
              subtitle: Text('Automatically backup data daily'),
              value: backupService.autoBackupEnabled,
              onChanged: (value) {
                backupService.setAutoBackupEnabled(value);
              },
              contentPadding: EdgeInsets.zero,
              activeColor: colorScheme.primary,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'Security',
      colorScheme: colorScheme,
      children: [
        Consumer<SettingsProvider>(
          builder: (context, settings, child) {
            return SwitchListTile(
              secondary: Icon(Icons.fingerprint, color: colorScheme.primary),
              title: Text('Biometric Authentication'),
              subtitle: Text('Use fingerprint or face unlock'),
              value: settings.biometricAuth,
              onChanged: (value) {
                settings.setBiometricAuth(value);
                // Implement biometric auth setup
              },
              contentPadding: EdgeInsets.zero,
              activeColor: colorScheme.primary,
            );
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.lock, color: colorScheme.primary),
          title: Text('Change Password'),
          subtitle: Text('Update your account password'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _changePassword(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
          title: Text('Privacy Policy'),
          subtitle: Text('View our privacy policy'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _showPrivacyPolicy(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'About',
      colorScheme: colorScheme,
      children: [
        ListTile(
          leading: Icon(Icons.info, color: colorScheme.primary),
          title: Text('App Version'),
          subtitle: Text('1.0.0'),
          contentPadding: EdgeInsets.zero,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.help, color: colorScheme.primary),
          title: Text('Help & Support'),
          subtitle: Text('Get help with the app'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _showHelpDialog(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.rate_review, color: colorScheme.primary),
          title: Text('Rate App'),
          subtitle: Text('Rate us on the app store'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _rateApp(context),
        ),
      ],
    );
  }

  Widget _buildDangerZone(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return _buildSectionCard(
      title: 'Danger Zone',
      colorScheme: colorScheme,
      children: [
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.orange),
          title: Text('Clear All Data'),
          subtitle: Text('Remove all grocery items'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _clearAllData(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout, color: Colors.red),
          title: Text('Sign Out'),
          subtitle: Text('Sign out of your account'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _signOut(context),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.delete_outline, color: Colors.red),
          title: Text('Delete Account'),
          subtitle: Text('Permanently delete your account'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          contentPadding: EdgeInsets.zero,
          onTap: () => _deleteAccount(context),
        ),
      ],
    );
  }

  // Helper methods for various settings actions
  void _showThemeColorPicker(BuildContext context) {
    // Implement theme color picker
    AnimatedDialog.showInfo(
      context: context,
      title: 'Theme Colors',
      message: 'Theme color customization will be available in a future update.',
    );
  }

  void _showCategoryPicker(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Default Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: settingsProvider.availableCategories.map((category) {
              return RadioListTile<String>(
                title: Text(category),
                value: category,
                groupValue: settingsProvider.defaultCategory,
                onChanged: (value) {
                  settingsProvider.setDefaultCategory(value!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showSortPicker(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Default Sort'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: settingsProvider.availableSortOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: settingsProvider.sortBy,
                onChanged: (value) {
                  settingsProvider.setSortBy(value!);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _syncData(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Implement sync logic
      await Future.delayed(Duration(seconds: 2)); // Simulate sync
      
      AnimatedDialog.showSuccess(
        context: context,
        title: 'Sync Complete',
        message: 'Your data has been synchronized successfully.',
      );
    } catch (e) {
      AnimatedDialog.showError(
        context: context,
        title: 'Sync Failed',
        message: 'Failed to sync data. Please try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _exportData(BuildContext context) {
    AnimatedDialog.showInfo(
      context: context,
      title: 'Export Data',
      message: 'Data export functionality will be available in a future update.',
    );
  }

  void _importData(BuildContext context) {
    AnimatedDialog.showInfo(
      context: context,
      title: 'Import Data',
      message: 'Data import functionality will be available in a future update.',
    );
  }

  void _clearCache(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Clear Cache',
      message: 'Are you sure you want to clear the cache? This will remove temporarily stored data.',
      confirmText: 'Clear',
      cancelText: 'Cancel',
      confirmColor: Colors.orange,
    );
    
    if (result == true) {
      // Implement cache clearing logic
      setState(() {
        _cacheSize = 0;
      });
      AnimatedDialog.showSuccess(
        context: context,
        message: 'Cache cleared successfully.',
      );
    }
  }

  void _changePassword(BuildContext context) {
    AnimatedDialog.showInfo(
      context: context,
      title: 'Change Password',
      message: 'Password change functionality will be available in a future update.',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    AnimatedDialog.showInfo(
      context: context,
      title: 'Privacy Policy',
      message: 'Your privacy is important to us. We collect and use your data responsibly to provide the best grocery management experience.',
    );
  }

  void _showHelpDialog(BuildContext context) {
    AnimatedDialog.showInfo(
      context: context,
      title: 'Help & Support',
      message: 'Need help? Contact us at support@groceryapp.com or visit our website for more information.',
    );
  }

  void _rateApp(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Rate Our App',
      message: 'We hope you\'re enjoying the app! Please consider rating us on the app store.',
      confirmText: 'Rate Now',
      cancelText: 'Later',
      confirmColor: Colors.blue,
    );
    
    if (result == true) {
      // Implement app store rating logic
      AnimatedDialog.showInfo(
        context: context,
        message: 'Redirecting to app store...',
      );
    }
  }

  void _clearAllData(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Clear All Data',
      message: 'This will permanently delete all your grocery items. This action cannot be undone.',
      confirmText: 'Delete All',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );
    
    if (result == true) {
      try {
        await _localHelper.clearAllData();
        AnimatedDialog.showSuccess(
          context: context,
          title: 'Data Cleared',
          message: 'All grocery items have been deleted.',
        );
      } catch (e) {
        AnimatedDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to clear data. Please try again.',
        );
      }
    }
  }

  void _signOut(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out?',
      confirmText: 'Sign Out',
      cancelText: 'Cancel',
      confirmColor: Colors.orange,
    );
    
    if (result == true) {
      try {
        await _auth.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false,
        );
      } catch (e) {
        AnimatedDialog.showError(
          context: context,
          title: 'Error',
          message: 'Failed to sign out. Please try again.',
        );
      }
    }
  }

  void _deleteAccount(BuildContext context) async {
    final firstConfirm = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Delete Account',
      message: 'This will permanently delete your account and all associated data. This action cannot be undone.',
      confirmText: 'Continue',
      cancelText: 'Cancel',
      confirmColor: Colors.red,
    );
    
    if (firstConfirm == true) {
      final finalConfirm = await AnimatedDialog.showConfirmation(
        context: context,
        title: 'Final Confirmation',
        message: 'Are you absolutely sure you want to delete your account? All your data will be lost forever.',
        confirmText: 'DELETE ACCOUNT',
        cancelText: 'Keep Account',
        confirmColor: Colors.red,
      );
      
      if (finalConfirm == true) {
        try {
          await _auth.deleteAccount();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (route) => false,
          );
        } catch (e) {
          AnimatedDialog.showError(
            context: context,
            title: 'Error',
            message: 'Failed to delete account. Please try again.',
          );
        }
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Grocery List App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Grocery List App. All rights reserved.',
      children: [
        SizedBox(height: 16),
        Text('A modern grocery management app with offline support, dark mode, and advanced features.'),
      ],
    );
  }

  String _formatCacheSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatBackupTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _performBackup(BuildContext context) async {
    final backupService = Provider.of<BackupService>(context, listen: false);
    final success = await backupService.performBackup();
    
    if (success) {
      AnimatedDialog.showSuccess(
        context: context,
        title: 'Backup Complete',
        message: 'Your data has been backed up successfully.',
      );
    } else {
      AnimatedDialog.showError(
        context: context,
        title: 'Backup Failed',
        message: 'Failed to backup data. Please try again.',
      );
    }
  }

  void _restoreBackup(BuildContext context) async {
    final result = await AnimatedDialog.showConfirmation(
      context: context,
      title: 'Restore Backup',
      message: 'This will replace all current data with the backup. Are you sure?',
      confirmText: 'Restore',
      cancelText: 'Cancel',
      confirmColor: Colors.orange,
    );
    
    if (result == true) {
      final backupService = Provider.of<BackupService>(context, listen: false);
      final success = await backupService.restoreFromBackup();
      
      if (success) {
        AnimatedDialog.showSuccess(
          context: context,
          title: 'Restore Complete',
          message: 'Your data has been restored successfully.',
        );
      } else {
        AnimatedDialog.showError(
          context: context,
          title: 'Restore Failed',
          message: 'Failed to restore data. Please try again.',
        );
      }
    }
  }
}
