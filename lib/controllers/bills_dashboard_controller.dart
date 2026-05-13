import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';
import 'settings_controller.dart';

class BillsDashboardController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final RxInt selectedYear = DateTime.now().year.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble yearEarnings = 0.0.obs;
  final RxInt payingUsers = 0.obs;
  final RxDouble pendingAmount = 0.0.obs;
  final RxList<Map<String, dynamic>> earningsByYear = <Map<String, dynamic>>[].obs;
  final RxList<double> monthlyEarnings = <double>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      totalEarnings.value = await _db.getTotalEarnings();
      yearEarnings.value = await _db.getYearEarnings(selectedYear.value);
      payingUsers.value = await _db.getPayingUsersCount(year: selectedYear.value);
      
      // Use global filter settings if available
      if (Get.isRegistered<SettingsController>()) {
        final settings = Get.find<SettingsController>();
        pendingAmount.value = await _db.getPendingAmount(
          year: settings.dashboardFilterYear.value ?? selectedYear.value,
          startDate: settings.dashboardFilterStartDate.value,
          endDate: settings.dashboardFilterEndDate.value,
        );
      } else {
        pendingAmount.value = await _db.getPendingAmount(year: selectedYear.value);
      }
      
      // Load earnings by year
      final yearData = await _db.getEarningsByYear();
      earningsByYear.value = yearData;
      
      // Load monthly earnings for selected year
      await loadMonthlyEarnings();
    } catch (e) {
      CustomSnackbar.showError('Failed to load bills dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMonthlyEarnings() async {
    try {
      final monthly = <double>[];
      for (int month = 1; month <= 12; month++) {
        final earnings = await _db.getMonthEarnings(selectedYear.value, month);
        monthly.add(earnings);
      }
      monthlyEarnings.value = monthly;
    } catch (e) {
      monthlyEarnings.value = List.filled(12, 0.0);
    }
  }

  void setSelectedYear(int year) {
    selectedYear.value = year;
    loadData();
  }

}

