import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_billing/controllers/navigation_controller.dart';
import '../controllers/bill_controller.dart';
import '../controllers/user_controller.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';
import '../models/bill_model.dart';
import '../models/user_model.dart';

class AddEditBillController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final notesController = TextEditingController();
  
  final billController = Get.put(BillController());
  final userController = Get.find<UserController>();
  
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);
  final RxInt selectedMonth = DateTime.now().month.obs;
  final RxInt selectedYear = DateTime.now().year.obs;
  final RxBool isPaid = true.obs;
  final Rx<DateTime?> billDate = Rx<DateTime?>(null);
  final RxBool isLoading = false.obs;
  final Rx<BillModel?> editingBill = Rx<BillModel?>(null);

  final List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final args = Get.arguments;
    if (args != null && args is Map) {
      final userUid = args['userUid'] as String?;
      if (userUid != null) {
        selectedUser.value = await DatabaseHelper.instance.getUserByUid(userUid);
      }
      
      final year = args['year'] as int?;
      final month = args['month'] as int?;
      if (year != null && month != null) {
        selectedYear.value = year;
        selectedMonth.value = month;
        
        if (selectedUser.value != null) {
          final bill = await DatabaseHelper.instance.getBill(
            selectedUser.value!.uid,
            year,
            month,
          );
          if (bill != null) {
            editingBill.value = bill;
            amountController.text = bill.amount.toString();
            notesController.text = bill.notes ?? '';
            isPaid.value = bill.isPaid;
            billDate.value = bill.billDate;
          }
        }
      }
    }
  }

  Future<void> selectUser() async {
    final result = await Get.toNamed(AppRoutes.usersList, arguments: {'selectMode': true});
    if (result != null && result is UserModel) {
      selectedUser.value = result;
    }
  }

  Future<void> selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: billDate.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      billDate.value = picked;
    }
  }

  Future<void> saveBill() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedUser.value == null) {
      CustomSnackbar.showError('Please select a user');
      return;
    }

    isLoading.value = true;

    final amount = double.tryParse(amountController.text) ?? 0.0;
    
    // Use the isPaid toggle value, not the amount
    if (isPaid.value && billDate.value == null) {
      CustomSnackbar.showError('Please select payment date');
      isLoading.value = false;
      return;
    }

    final bill = BillModel(
      id: editingBill.value?.id,
      userUid: selectedUser.value!.uid,
      year: selectedYear.value,
      month: selectedMonth.value,
      amount: amount,
      billDate: isPaid.value ? billDate.value : null,
      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      createdAt: editingBill.value?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await billController.createOrUpdateBill(bill);

    isLoading.value = false;

    if (success) {
      // Go back - if we came from user details, it will refresh automatically
      // Get.back();

      final navController = Get.isRegistered<NavigationController>() ? Get.find<NavigationController>() : Get.put(NavigationController());
        navController.changeIndex(2); // Bills tab
        Get.offAllNamed(AppRoutes.main);
      // Snackbar is already shown in the controller
    }
  }

  void togglePaidStatus(bool paid) {
    isPaid.value = paid;
    if (paid) {
      billDate.value ??= DateTime.now();
    } else {
      billDate.value = null;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
