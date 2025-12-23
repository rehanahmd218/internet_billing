import 'package:get/get.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/data/models/bill_model.dart';
import 'package:wifi_billing/app/data/models/user_model.dart';
import 'package:wifi_billing/app/data/repositories/bill_repository.dart';
import 'package:wifi_billing/app/data/repositories/user_repository.dart';

class DashboardController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final BillRepository _billRepository = BillRepository();

  final RxBool isLoading = false.obs;
  final RxInt totalUsers = 0.obs;
  final RxDouble totalEarnings = 0.0.obs;
  final RxDouble currentMonthEarnings = 0.0.obs;
  final RxInt pendingBillsCount = 0.obs;
  final RxList<BillModel> recentBills = <BillModel>[].obs;
  final RxMap<String, UserModel> usersMap = <String, UserModel>{}.obs;
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      AppLogger.info('Loading dashboard data');

      // Load statistics with automatic loader management
      await Future.wait([
        _loadUserStats(),
        _loadBillStats(),
        _loadRecentActivity(),
      ]);

      AppLogger.info('Dashboard data loaded successfully');
    } catch (e) {
      AppLogger.error('Error loading dashboard data', e);
      // Error snackbar shown automatically by runFirebaseSafely
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final count = await _userRepository.getUserCount(loader: isLoading);
      totalUsers.value = count;
    } catch (e) {
      AppLogger.error('Error loading user stats', e);
    }
  }

  Future<void> _loadBillStats() async {
    try {
      final earnings = await _billRepository.getTotalEarnings(loader: isLoading);
      final monthEarnings = await _billRepository.getCurrentMonthEarnings(loader: isLoading);
      final pendingCount = await _billRepository.getPendingBillCount(loader: isLoading);

      totalEarnings.value = earnings;
      currentMonthEarnings.value = monthEarnings;
      pendingBillsCount.value = pendingCount;
    } catch (e) {
      AppLogger.error('Error loading bill stats', e);
    }
  }

  Future<void> _loadRecentActivity() async {
    try {
      final allBills = await _billRepository.getAllBills(loader: isLoading);
      
      // Sort by created date and take recent 10
      allBills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      recentBills.value = allBills.take(10).toList();

      // Load user data for recent bills
      final userIds = recentBills.map((bill) => bill.userId).toSet();
      for (final userId in userIds) {
        final user = await _userRepository.getUserById(userId, loader: isLoading);
        if (user != null) {
          usersMap[userId] = user;
        }
      }
    } catch (e) {
      AppLogger.error('Error loading recent activity', e);
    }
  }

  void onBottomNavTap(int index) {
    selectedIndex.value = index;
  }

  Future<void> refreshData() async {
    await loadDashboardData();
  }
}
