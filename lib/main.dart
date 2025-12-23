import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/theme/app_theme.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/routes/app_pages.dart';
import 'package:wifi_billing/app/routes/app_routes.dart';
import 'package:wifi_billing/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Error initializing Firebase', e, stackTrace);
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'NetManager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.routes,
    
    );
  }
}