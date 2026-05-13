import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dashboard_controller.dart';
import 'user_controller.dart';
import 'bill_controller.dart';

class SettingsController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final RxBool isDarkMode = false.obs;
  final RxString currency = 'PKR'.obs;
  final RxBool isFirstLaunch = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    currency.value = prefs.getString('currency') ?? 'PKR';
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  Future<void> setCurrency(String newCurrency) async {
    currency.value = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
  }

  Future<bool> backupData() async {
    try {
      final data = await _db.exportData();
      final jsonString = jsonEncode(data);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/internet_billing_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      CustomSnackbar.showSuccess('Backup created successfully!\nLocation: ${file.path}');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to backup data: $e');
      return false;
    }
  }

  Future<bool> restoreData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        CustomSnackbar.showError('Backup file not found');
        return false;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup structure
      if (!data.containsKey('users') || !data.containsKey('bills')) {
        CustomSnackbar.showError('Invalid backup file format');
        return false;
      }

      await _db.importData(data);
      
      // Refresh all controllers
      Get.find<DashboardController>().loadDashboardData();
      Get.find<UserController>().loadUsers();
      Get.find<BillController>().loadBills();
      
      CustomSnackbar.showSuccess('Data restored successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to restore data: $e');
      return false;
    }
  }

  Future<void> loadFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch.value = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch.value) {
      // Perform any first-launch specific initialization here
      await setFirstLaunchComplete();
    }
    
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }
}

