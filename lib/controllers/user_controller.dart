import 'package:get/get.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';

class UserController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  // Filter state variables
  final Rxn<String> filterStatus = Rxn<String>(); // 'pending', 'paid', or null
  final Rxn<int> filterYear = Rxn<int>();
  final Rxn<DateTime> filterStartDate = Rxn<DateTime>();
  final Rxn<DateTime> filterEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> loadUsers() async {
    isLoading.value = true;
    try {
      // Check if filters are active
      if (hasActiveFilters && filterStatus.value != null) {
        // Use filtered query
        users.value = await _db.getUsersByBillStatus(
          status: filterStatus.value,
          year: filterYear.value,
          startDate: filterStartDate.value,
          endDate: filterEndDate.value,
        );
        
        // Apply search query if present
        if (searchQuery.value.isNotEmpty) {
          users.value = users.where((user) {
            final query = searchQuery.value.toLowerCase();
            return user.name.toLowerCase().contains(query) ||
                   user.uid.toLowerCase().contains(query) ||
                   user.mobileNumber.contains(query);
          }).toList();
        }
      } else {
        // Use normal query
        if (searchQuery.value.isEmpty) {
          users.value = await _db.getAllUsers();
        } else {
          users.value = await _db.searchUsers(searchQuery.value);
        }
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
      user.id = userId;
      users.insert(0, user);
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

  // Filter methods

  /// Apply filters to user list
  Future<void> applyFilters({
    String? status,
    int? year,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    filterStatus.value = status;
    filterYear.value = year;
    filterStartDate.value = startDate;
    filterEndDate.value = endDate;
    await loadUsers();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    filterStatus.value = null;
    filterYear.value = null;
    filterStartDate.value = null;
    filterEndDate.value = null;
    await loadUsers();
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return filterStatus.value != null ||
           filterYear.value != null ||
           filterStartDate.value != null ||
           filterEndDate.value != null;
  }

  /// Get filter description
  String get filterDescription {
    List<String> parts = [];
    
    if (filterStatus.value != null) {
      parts.add(filterStatus.value == 'pending' ? 'Pending Bills' : 'Paid Bills');
    }
    
    if (filterYear.value != null) {
      parts.add('Year: ${filterYear.value}');
    }
    
    if (filterStartDate.value != null || filterEndDate.value != null) {
      final start = filterStartDate.value;
      final end = filterEndDate.value;
      
      if (start != null && end != null) {
        parts.add('${_formatDate(start)} - ${_formatDate(end)}');
      } else if (start != null) {
        parts.add('From ${_formatDate(start)}');
      } else if (end != null) {
        parts.add('Until ${_formatDate(end)}');
      }
    }
    
    return parts.isEmpty ? 'All Users' : parts.join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

