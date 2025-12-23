import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';

class SettingsController extends GetxController {
  final RxBool isDarkMode = false.obs;
  final RxString selectedCurrency = 'Rs'.obs;
  final RxBool notificationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    AppLogger.info('Loading settings');
    // Load from local storage in future
  }

  void toggleDarkMode() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    AppLogger.info('Dark mode: ${isDarkMode.value}');
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    AppLogger.info('Notifications: ${notificationsEnabled.value}');
  }

  void changeCurrency(String currency) {
    selectedCurrency.value = currency;
    AppLogger.info('Currency changed to: $currency');
  }
}
