import 'package:get/get.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';

class UserController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      if (searchQuery.value.isEmpty) {
        users.value = await _db.getAllUsers();
      } else {
        users.value = await _db.searchUsers(searchQuery.value);
      }
    } catch (e) {
      CustomSnackbar.showError('Failed to load users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    await loadUsers();
  }

  Future<bool> createUser(UserModel user) async {
    try {
      // Check if UID already exists
      final existing = await _db.getUserByUid(user.uid);
      if (existing != null) {
        CustomSnackbar.showError('UID already exists. Please try again.');
        return false;
      }

      final userId = await _db.insertUser(user);
      // await loadUsers();
      // users.insert(0, user);
      CustomSnackbar.showSuccess('User created successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to create user: $e');
      return false;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _db.updateUser(user);
      await loadUsers();
      CustomSnackbar.showSuccess('User updated successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to update user: $e');
      return false;
    }
  }

  Future<bool> deleteUser(int id) async {
    try {
      await _db.deleteUser(id);
      await loadUsers();
      CustomSnackbar.showSuccess('User deleted successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to delete user: $e');
      return false;
    }
  }

  Future<int> generateNo() async {
    // Get the highest 'no' value and increment by 1
    try {
      final allUsers = await _db.getAllUsers();
      if (allUsers.isEmpty) {
        return 1;
      }
      final maxNo = allUsers.map((u) => u.no).reduce((a, b) => a > b ? a : b);
      return maxNo + 1;
    } catch (e) {
      // If error, return 1 as default
      return 1;
    }
  }
}

