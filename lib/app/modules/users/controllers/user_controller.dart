import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/logger_utils.dart';
import 'package:wifi_billing/app/core/utils/snackbar_utils.dart';
import 'package:wifi_billing/app/data/models/user_model.dart';
import 'package:wifi_billing/app/data/repositories/user_repository.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = UserRepository();

  final RxBool isLoading = false.obs;
  final RxBool hasLoadedUsers = false.obs;
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);

  // Form controllers
  final nameController = TextEditingController();
  final uidController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final RxString selectedStatus = AppConstants.statusActive.obs;

  @override
  void onInit() {
    super.onInit();
    // Only load users if not already loaded (caching)
    if (!hasLoadedUsers.value) {
      loadUsers();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    uidController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.onClose();
  }

  Future<void> loadUsers() async {
    try {
      AppLogger.info('Loading users');
      
      final allUsers = await _userRepository.getAllUsers(loader: isLoading);
      users.value = allUsers;
      filteredUsers.value = allUsers;
      hasLoadedUsers.value = true;
      
      AppLogger.info('Loaded ${users.length} users');
    } catch (e) {
      AppLogger.error('Error loading users', e);
      // Error snackbar shown automatically by runFirebaseSafely
    }
  }

  void searchUsers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users.where((user) {
        final lowerQuery = query.toLowerCase();
        return user.name.toLowerCase().contains(lowerQuery) ||
            user.phone.contains(query) ||
            user.uid.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
    nameController.text = user.name;
    uidController.text = user.uid;
    phoneController.text = user.phone;
    addressController.text = user.address;
    selectedStatus.value = user.status;
  }

  void clearForm() {
    selectedUser.value = null;
    nameController.clear();
    uidController.clear();
    phoneController.clear();
    addressController.clear();
    selectedStatus.value = AppConstants.statusActive;
  }

  Future<bool> createUser() async {
    try {
      AppLogger.info('Creating user');

      // Check if UID already exists
      final uidExists = await _userRepository.isUidExists(
        uidController.text.trim(),
        loader: isLoading,
      );
      if (uidExists) {
        SnackbarUtils.showError('User ID already exists');
        return false;
      }

      final user = UserModel(
        uid: uidController.text.trim(),
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        status: selectedStatus.value,
        createdAt: DateTime.now(),
      );

      await _userRepository.createUser(user, loader: isLoading);
      
      AppLogger.info('User created successfully');
      SnackbarUtils.showSuccess('User created successfully');
      
      // Invalidate cache to trigger refetch on next screen visit
      hasLoadedUsers.value = false;
      await loadUsers();
      clearForm();
      return true;
    } catch (e) {
      AppLogger.error('Error creating user', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<bool> updateUser() async {
    try {
      if (selectedUser.value == null) return false;

      AppLogger.info('Updating user');

      final updatedUser = selectedUser.value!.copyWith(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        status: selectedStatus.value,
        updatedAt: DateTime.now(),
      );

      await _userRepository.updateUser(
        selectedUser.value!.id!,
        updatedUser,
        loader: isLoading,
      );
      
      AppLogger.info('User updated successfully');
      SnackbarUtils.showSuccess('User updated successfully');
      
      // Invalidate cache to trigger refetch on next screen visit
      hasLoadedUsers.value = false;
      await loadUsers();
      clearForm();
      return true;
    } catch (e) {
      AppLogger.error('Error updating user', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      AppLogger.info('Deleting user: $userId');

      await _userRepository.deleteUser(userId, loader: isLoading);
      
      AppLogger.info('User deleted successfully');
      SnackbarUtils.showSuccess('User deleted successfully');
      
      // Invalidate cache to trigger refetch on next screen visit
      hasLoadedUsers.value = false;
      await loadUsers();
      return true;
    } catch (e) {
      AppLogger.error('Error deleting user', e);
      // Error snackbar shown automatically by runFirebaseSafely
      return false;
    }
  }

  Future<void> refreshUsers() async {
    await loadUsers();
  }
}
