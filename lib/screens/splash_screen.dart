import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../routes/app_routes.dart';
import '../common/widgets/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkFirstLaunch() async {
    final settingsController = Get.put(SettingsController());
    final isFirstLaunch = settingsController.isFirstLaunch;
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (isFirstLaunch.value) {
      await settingsController.setFirstLaunchComplete();
    }
    
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    // Call initialization once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunch();
    });

    return Scaffold(
    
      body: SafeArea(
        
        child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[300]!,
              AppColors.primary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Icon
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hub,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              // App Name
              const Text(
                'EasyNet Billing',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'ISP Management & Billing',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[50],
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }
}

