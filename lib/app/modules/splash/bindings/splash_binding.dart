import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  
  @override
  void dependencies() {
    // Get.lazyPut<SplashController>(() => SplashController());

    Get.put<SplashController>(SplashController());

  }
}
