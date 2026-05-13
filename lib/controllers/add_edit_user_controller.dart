import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../controllers/navigation_controller.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
class AddEditUserController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final addressController = TextEditingController();
  final uidController = TextEditingController();
  final noController = TextEditingController();
  final internetSpeedController = TextEditingController();
  
  final userController = Get.find<UserController>();
  
  final Rx<UserModel?> editingUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxInt? generatedNo = RxInt(0);

  @override
  void onInit() {
    super.onInit();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    final args = Get.arguments;
    if (args != null && args is UserModel) {
      editingUser.value = args;
      nameController.text = editingUser.value!.name;
      mobileController.text = editingUser.value!.mobileNumber;
      addressController.text = editingUser.value!.address;
      uidController.text = editingUser.value!.uid;
      noController.text = editingUser.value!.no.toString();
      internetSpeedController.text = editingUser.value!.internetSpeed.toString();
    } else {
      // Generate sequential number for new user
      final no = await userController.generateNo();
      generatedNo?.value = no;
      noController.text = no.toString();
      internetSpeedController.text = '0';
    }
  }

  String? validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    // Basic mobile validation
    if (value.length < 10 || value.length > 11 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Invalid mobile number';
    }
    return null;
  }

  Future<void> saveUser() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    final user = UserModel(
      id: editingUser.value?.id,
      no: editingUser.value?.no ?? generatedNo?.value ?? 1,
      uid: uidController.text.trim(),
      name: nameController.text.trim(),
      mobileNumber: mobileController.text.trim(),
      address: addressController.text.trim(),
      internetSpeed: int.tryParse(internetSpeedController.text.trim()) ?? 0,
      createdDate: editingUser.value?.createdDate ?? DateTime.now(),
      isActive: editingUser.value?.isActive ?? true,
    );

    final success = editingUser.value == null
        ? await userController.createUser(user)
        : await userController.updateUser(user);

    isLoading.value = false;

    if (success) {
      // if (editingUser.value == null) {
        // For new user, navigate to main screen with users tab (index 1)
        final navController = Get.isRegistered<NavigationController>() ? Get.find<NavigationController>() : Get.put(NavigationController());  
        navController.changeIndex(1); // Users tab
        Get.offAllNamed(AppRoutes.main);
    
      //  else {
      //   // For edit, go back to previous screen
      //   Get.back();
      // }
      // Snackbar is already shown in the controller
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    mobileController.dispose();
    addressController.dispose();
    uidController.dispose();
    noController.dispose();
    internetSpeedController.dispose();
    super.onClose();
  }
}
