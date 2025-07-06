import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Feature imports using the new structure
import 'features/auth/auth.dart';
import 'features/grocery/grocery.dart';
import 'features/settings/settings.dart';
import 'features/notifications/notifications.dart';
import 'core/core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => SettingsProvider()),
        ChangeNotifierProvider(create: (context) => HistoryProvider()..loadHistory()),
        ChangeNotifierProvider(create: (context) => NotificationService()..loadNotifications()),
        ChangeNotifierProxyProvider<NotificationService, BackupService>(
          create: (context) => BackupService(context.read<NotificationService>())..loadBackupSettings(),
          update: (context, notificationService, previous) => 
            previous ?? BackupService(notificationService)..loadBackupSettings(),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: AuthCheck(), // Redirect based on authentication state
        );
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            // User is logged in, show HomePage
            return HomePage();
          } else {
            // User is NOT logged in, show LoginPage
            return LoginPage();
          }
        } else {
          // While checking the auth state, show a loading spinner
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}