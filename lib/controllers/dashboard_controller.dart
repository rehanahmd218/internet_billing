import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';

class DashboardController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble currentMonthEarnings = 0.0.obs;
  final RxInt totalUsers = 0.obs;
  final RxInt pendingBillsCount = 0.obs;
  final RxList<Map<String, dynamic>> recentActivity = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      totalEarnings.value = await _db.getTotalEarnings();
      currentMonthEarnings.value = await _db.getCurrentMonthEarnings();
      totalUsers.value = await _db.getTotalUsers();
      pendingBillsCount.value = await _db.getPendingBillsCount();
      await loadRecentActivity();
    } catch (e) {
      CustomSnackbar.showError('Failed to load dashboard data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadRecentActivity() async {
    try {
      final bills = await _db.getAllBills();
      final recentBills = bills.take(4).toList();
      
      final activity = <Map<String, dynamic>>[];
      for (var bill in recentBills) {
        final user = await _db.getUserByUid(bill.userUid);
        if (user != null) {
          activity.add({
            'bill': bill,
            'user': user,
          });
        }
      }
      recentActivity.value = activity;
    } catch (e) {
      // Handle error silently for recent activity
    }
  }

}

