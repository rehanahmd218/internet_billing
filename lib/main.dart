import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'controllers/dashboard_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/bill_controller.dart';
import 'controllers/settings_controller.dart';
import 'common/widgets/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _statusUrl = 'https://pastebin.com/raw/JdabH4Lt';
const String _statusKey = 'EasyNet Billing';

Future<bool> _checkStartupStatus() async {
  try {
    final response = await http
        .get(Uri.parse(_statusUrl))
        .timeout(const Duration(seconds: 5));

    if (response.statusCode != 200) return false;

    final body = response.body;
    final decoded = jsonDecode(body);
    if (decoded is Map && decoded.containsKey(_statusKey)) {
      return decoded[_statusKey] == true;
    }
    return false;
  } catch (_) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final isAllowed = await _checkStartupStatus();
  // if (!isAllowed) {
  //   runApp(const BlockedApp(message: 'Service unavailable. Please try again later.'));
  //   return;
  // }

  // Preload first-launch flag from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final firstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  // Initialize controllers
  final settingsController = Get.put(SettingsController());
  // Ensure initialRoute reads the correct value
  settingsController.isFirstLaunch.value = firstLaunch;
  Get.put(DashboardController());
  Get.put(UserController());
  Get.put(BillController());

  // Check if first launch

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    print('Is First Launch: ${settingsController.isFirstLaunch.value}');
    return Obx(
      () => GetMaterialApp(
        title: 'NetManager',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: AppColors.backgroundLight,
          fontFamily: 'Inter',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: AppColors.backgroundDark,
          fontFamily: 'Inter',
        ),
        themeMode: settingsController.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        // Show splash only on first launch
        initialRoute: settingsController.isFirstLaunch.value 
            ? AppRoutes.splash 
            : AppRoutes.main,
        getPages: AppPages.routes,
      ),
    );
  }
}

class BlockedApp extends StatelessWidget {
  final String message;

  const BlockedApp({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock, size: 56, color: Colors.redAccent),
                const SizedBox(height: 16),
                const Text(
                  'Access Blocked',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
