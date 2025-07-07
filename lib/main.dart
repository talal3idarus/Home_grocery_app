import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

// Data layer imports
import 'Data/ThemeProvider.dart';
import 'Data/SettingsProvider.dart';
import 'Data/HistoryProvider.dart';
import 'Data/NotificationService.dart';
import 'Data/BackupService.dart';

// Screen imports
import 'Screens/Home.dart';
import 'Screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      child: const MyApp(),
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
          title: 'Home Grocery App',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const AuthCheck(),
        );
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;
          if (user != null) {
            // User is logged in, show HomePage
            return const HomePage();
          } else {
            // User is NOT logged in, show LoginPage
            return LoginPage();
          }
        } else {
          // While checking the auth state, show a loading spinner
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }
}