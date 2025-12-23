import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/core/utils/snackbar_utils.dart';
import 'package:wifi_billing/app/data/models/bill_model.dart';
import 'package:wifi_billing/app/data/repositories/bill_repository.dart';

class BillController extends GetxController {
  final BillRepository _billRepository = BillRepository();

  final RxBool isLoading = false.obs;
  final RxList<BillModel> bills = <BillModel>[].obs;
  final RxList<BillModel> filteredBills = <BillModel>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxInt selectedMonth = DateTime.now().month.obs;
  final Rx<BillModel?> selectedBill = Rx<BillModel?>(null);

  // Form controllers
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  final RxString selectedStatus = AppConstants.billStatusPending.obs;
  final Rx<DateTime?> paidDate = Rx<DateTime?>(null);
  final RxString selectedUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBills();
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadBills() async {
    try {
      AppLogger.info('Loading bills');
      
      final allBills = await _billRepository.getAllBills(loader: isLoading);
      bills.value = allBills;
      filterBillsByYear(selectedYear.value);
      
      AppLogger.info('Loaded ${bills.length} bills');
    } catch (e) {
      AppLogger.error('Error loading bills', e);
      // Error snackbar shown automatically by runFirebaseSafely
    }
  }

  Future<void> loadBillsByUser(String userId) async {
    try {
      AppLogger.info('Loading bills for user: $userId');
      
      final userBills = await _billRepository.getBillsByUserId(userId, loader: isLoading);
      bills.value = userBills;
      filteredBills.value = userBills;
      
      AppLogger.info('Loaded ${bills.length} bills for user');
    } catch (e) {
      AppLogger.error('Error loading user bills', e);
      // Error snackbar shown automatically by runFirebaseSafely
    }
  }

  void filterBillsByYear(int year) {
    selectedYear.value = year;
    filteredBills.value = bills.where((bill) => bill.year == year).toList();
  }

  void filterBillsByMonth(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    filteredBills.value = bills
        .where((bill) => bill.month == month && bill.year == year)
        .toList();
  }

  void selectBill(BillModel bill) {
    selectedBill.value = bill;
    amountController.text = bill.amount.toString();
    notesController.text = bill.notes ?? '';
    selectedStatus.value = bill.status;
    paidDate.value = bill.paidDate;
    selectedUserId.value = bill.userId;
    selectedMonth.value = bill.month;
    selectedYear.value = bill.year;
  }

  void clearForm() {
    selectedBill.value = null;
    amountController.clear();
    notesController.clear();
    selectedStatus.value = AppConstants.billStatusPending;
    paidDate.value = null;
    selectedUserId.value = '';
  }

  Future<bool> createBill({required String userId}) async {
    try {
      AppLogger.info('Creating bill');

      // Check if bill already exists for this month/year
      final existingBill = await _billRepository.getBillByUserMonthYear(
        userId,
        selectedMonth.value,
        selectedYear.value,
        loader: isLoading,
      );

      if (existingBill != null) {
        SnackbarUtils.showWarning('Bill already exists for this month');
        return false;
      }

      final bill = BillModel(
        userId: userId,
        amount: double.parse(amountController.text.trim()),
        month: selectedMonth.value,
        year: selectedYear.value,
        status: selectedStatus.value,
        paidDate: selectedStatus.value == AppConstants.billStatusPaid
            ? (paidDate.value ?? DateTime.now())
            : null,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _billRepository.createBill(bill, loader: isLoading);
      
      AppLogger.info('Bill created successfully');
      SnackbarUtils.showSuccess('Bill created successfully');
      
      await loadBills();
      clearForm();
      return true;
    } catch (e) {
      AppLogger.error('Error creating bill', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<bool> updateBill() async {
    try {
      if (selectedBill.value == null) return false;

      AppLogger.info('Updating bill');

      final updatedBill = selectedBill.value!.copyWith(
        amount: double.parse(amountController.text.trim()),
        status: selectedStatus.value,
        paidDate: selectedStatus.value == AppConstants.billStatusPaid
            ? (paidDate.value ?? DateTime.now())
            : null,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await _billRepository.updateBill(selectedBill.value!.id!, updatedBill, loader: isLoading);
      
      AppLogger.info('Bill updated successfully');
      SnackbarUtils.showSuccess('Bill updated successfully');
      
      await loadBills();
      clearForm();
      return true;
    } catch (e) {
      AppLogger.error('Error updating bill', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<bool> deleteBill(String billId) async {
    try {
      AppLogger.info('Deleting bill: $billId');

      await _billRepository.deleteBill(billId, loader: isLoading);
      
      AppLogger.info('Bill deleted successfully');
      SnackbarUtils.showSuccess('Bill deleted successfully');
      
      await loadBills();
      return true;
    } catch (e) {
      AppLogger.error('Error deleting bill', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<void> refreshBills() async {
    await loadBills();
  }

  // Statistics methods
  Future<double> getTotalPaidForUser(String userId) async {
    try {
      return await _billRepository.getUserTotalPaid(userId);
    } catch (e) {
      AppLogger.error('Error getting user total paid', e);
      return 0.0;
    }
  }

  Future<double> getPendingAmountForUser(String userId) async {
    try {
      return await _billRepository.getUserPendingAmount(userId);
    } catch (e) {
      AppLogger.error('Error getting user pending amount', e);
      return 0.0;
    }
  }
}
