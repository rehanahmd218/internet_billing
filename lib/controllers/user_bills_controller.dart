import 'package:get/get.dart';
import '../database/database_helper.dart';
import '../models/bill_model.dart';
import '../common/widgets/custom_snackbar.dart';

class UserBillsController extends GetxController {
  final db = DatabaseHelper.instance;

  // Reactive variables
  final RxString userUid = ''.obs;
  final RxString userName = ''.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxList<BillModel> bills = <BillModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble yearTotal = 0.0.obs;

  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is Map) {
      userUid.value = args['userUid'] as String? ?? '';
      userName.value = args['userName'] as String? ?? '';
    }
    loadBills();
  }

  Future<void> loadBills() async {
    if (userUid.value.isEmpty) return;

    isLoading.value = true;

    try {
      final loadedBills = await db.getUserBills(userUid.value, selectedYear.value);
      bills.value = loadedBills;

      // Calculate year total
      yearTotal.value = loadedBills.fold(0.0, (sum, bill) => sum + bill.amount);
    } catch (e) {
      CustomSnackbar.showError('Failed to load bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  BillModel? getBillForMonth(int month) {
    try {
      return bills.firstWhere((bill) => bill.month == month);
    } catch (e) {
      return null;
    }
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadBills();
  }
}
