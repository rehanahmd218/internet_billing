import 'package:get/get.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    AppLogger.info('SplashController initialized');
    super.onInit();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    AppLogger.info('Splash screen initialized');
    
    // Simulate loading time
    await Future.delayed(const Duration(seconds: 2));
    
    AppLogger.info('Navigating to dashboard');
    Get.offAllNamed(AppRoutes.dashboard);
  }
}
