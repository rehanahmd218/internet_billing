import 'package:get/get.dart';
import '../models/bill_model.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';

class BillController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final RxList<BillModel> bills = <BillModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  Future<void> loadBills({int? year}) async {
    isLoading.value = true;
    try {
      bills.value = await _db.getAllBills(year: year ?? selectedYear.value);
    } catch (e) {
      CustomSnackbar.showError('Failed to load bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<BillModel>> getUserBills(String userUid, {int? year}) async {
    try {
      return await _db.getUserBills(userUid, year ?? selectedYear.value);
    } catch (e) {
      CustomSnackbar.showError('Failed to load user bills: $e');
      return [];
    }
  }

  Future<bool> createOrUpdateBill(BillModel bill) async {
    try {
      await _db.insertBill(bill);
      await loadBills();
      CustomSnackbar.showSuccess('Bill saved successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to save bill: $e');
      return false;
    }
  }

  Future<bool> deleteBill(int id) async {
    try {
      await _db.deleteBill(id);
      await loadBills();
      CustomSnackbar.showSuccess('Bill deleted successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to delete bill: $e');
      return false;
    }
  }

  void setSelectedYear(int year) {
    selectedYear.value = year;
    loadBills();
  }
}

