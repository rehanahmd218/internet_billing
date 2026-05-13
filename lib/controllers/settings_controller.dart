import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../common/widgets/custom_snackbar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'dashboard_controller.dart';
import 'user_controller.dart';
import 'bill_controller.dart';
import 'bills_dashboard_controller.dart';
import '../services/google_drive_service.dart';

class SettingsController extends GetxController {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final GoogleDriveService _driveService = GoogleDriveService.instance;
  
  final RxBool isDarkMode = false.obs;
  final RxString currency = 'PKR'.obs;
  final RxBool isFirstLaunch = true.obs;
  
  // Google Drive states
  final RxBool isSignedInToGoogle = false.obs;
  final RxString googleUserEmail = ''.obs;
  final RxBool isBackupLoading = false.obs;
  final RxList<BackupFile> availableBackups = <BackupFile>[].obs;

  // Global Dashboard Filter Settings
  final Rxn<int> dashboardFilterYear = Rxn<int>();
  final Rxn<DateTime> dashboardFilterStartDate = Rxn<DateTime>();
  final Rxn<DateTime> dashboardFilterEndDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    loadDashboardFilters();
    _checkGoogleSignIn();
    loadFirstLaunch();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    currency.value = prefs.getString('currency') ?? 'PKR';
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }

  Future<void> setCurrency(String newCurrency) async {
    currency.value = newCurrency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', newCurrency);
  }

  /// Check if user is already signed in to Google
  Future<void> _checkGoogleSignIn() async {
    try {
      final signedIn = await _driveService.signInSilently();
      isSignedInToGoogle.value = signedIn;
      if (signedIn) {
        googleUserEmail.value = _driveService.userEmail ?? '';
        await loadBackupsList();
      }
    } catch (e) {
      print('Error checking Google sign-in: $e');
    }
  }

  /// Sign in to Google Drive
  Future<bool> signInToGoogle() async {
    try {
      isBackupLoading.value = true;
      final success = await _driveService.signIn();
      
      if (success) {
        isSignedInToGoogle.value = true;
        googleUserEmail.value = _driveService.userEmail ?? '';
        await loadBackupsList();
        CustomSnackbar.showSuccess('Connected to Google Drive');
        return true;
      } else {
        CustomSnackbar.showError('Failed to connect to Google Drive');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Error connecting to Google: $e');
      return false;
    } finally {
      isBackupLoading.value = false;
    }
  }

  /// Sign out from Google Drive
  Future<void> signOutFromGoogle() async {
    try {
      await _driveService.signOut();
      isSignedInToGoogle.value = false;
      googleUserEmail.value = '';
      availableBackups.clear();
      CustomSnackbar.showSuccess('Disconnected from Google Drive');
    } catch (e) {
      CustomSnackbar.showError('Error disconnecting: $e');
    }
  }

  /// Backup data to Google Drive
  Future<bool> backupToGoogleDrive() async {
    if (!isSignedInToGoogle.value) {
      CustomSnackbar.showError('Please connect to Google Drive first');
      return false;
    }

    try {
      isBackupLoading.value = true;
      CustomSnackbar.showInfo('Creating backup...');

      // Get database path
      final dbPath = await getDatabasesPath();
      final dbFile = path.join(dbPath, 'internet_billing.db');

      // Upload to Google Drive
      final fileId = await _driveService.uploadBackup(dbFile);
      
      if (fileId != null) {
        await loadBackupsList();
        CustomSnackbar.showSuccess('Backup uploaded to Google Drive successfully!');
        return true;
      } else {
        CustomSnackbar.showError('Failed to upload backup');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Backup failed: $e');
      return false;
    } finally {
      isBackupLoading.value = false;
    }
  }

  /// Load list of available backups from Google Drive
  Future<void> loadBackupsList() async {
    if (!isSignedInToGoogle.value) return;

    try {
      final backups = await _driveService.listBackups();
      availableBackups.value = backups;
    } catch (e) {
      print('Error loading backups list: $e');
      CustomSnackbar.showError('Failed to load backups: $e');
    }
  }

  /// Restore data from Google Drive backup
  Future<bool> restoreFromGoogleDrive(String fileId) async {
    if (!isSignedInToGoogle.value) {
      CustomSnackbar.showError('Please connect to Google Drive first');
      return false;
    }

    try {
      isBackupLoading.value = true;
      CustomSnackbar.showInfo('Restoring backup...');

      // Get database path
      final dbPath = await getDatabasesPath();
      final dbFile = path.join(dbPath, 'internet_billing.db');

      // Download and restore
      final success = await _driveService.downloadAndRestoreBackup(fileId, dbFile);
      
      if (success) {
        // Reinitialize database to fix "database_closed" error
        await _db.reinitializeDatabase();
        
        // Refresh all controllers
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().loadDashboardData();
        }
        if (Get.isRegistered<UserController>()) {
          Get.find<UserController>().loadUsers();
        }
        if (Get.isRegistered<BillController>()) {
          Get.find<BillController>().loadBills();
        }
        
        CustomSnackbar.showSuccess('Backup restored successfully!');
        return true;
      } else {
        CustomSnackbar.showError('Failed to restore backup');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Restore failed: $e');
      return false;
    } finally {
      isBackupLoading.value = false;
    }
  }

  /// Delete backup from Google Drive
  Future<bool> deleteBackup(String fileId) async {
    try {
      isBackupLoading.value = true;
      final success = await _driveService.deleteBackup(fileId);
      
      if (success) {
        await loadBackupsList();
        CustomSnackbar.showSuccess('Backup deleted');
        return true;
      } else {
        CustomSnackbar.showError('Failed to delete backup');
        return false;
      }
    } catch (e) {
      CustomSnackbar.showError('Delete failed: $e');
      return false;
    } finally {
      isBackupLoading.value = false;
    }
  }

  // Legacy JSON backup methods (kept for backward compatibility)
  Future<bool> backupDataLegacy() async {
    try {
      final data = await _db.exportData();
      final jsonString = jsonEncode(data);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/internet_billing_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);
      
      CustomSnackbar.showSuccess('Backup created successfully!\nLocation: ${file.path}');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to backup data: $e');
      return false;
    }
  }

  Future<bool> restoreDataLegacy(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        CustomSnackbar.showError('Backup file not found');
        return false;
      }

      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate backup structure
      if (!data.containsKey('users') || !data.containsKey('bills')) {
        CustomSnackbar.showError('Invalid backup file format');
        return false;
      }

      await _db.importData(data);
      
      // Refresh all controllers
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().loadDashboardData();
      }
      if (Get.isRegistered<UserController>()) {
        Get.find<UserController>().loadUsers();
      }
      if (Get.isRegistered<BillController>()) {
        Get.find<BillController>().loadBills();
      }
      
      CustomSnackbar.showSuccess('Data restored successfully');
      return true;
    } catch (e) {
      CustomSnackbar.showError('Failed to restore data: $e');
      return false;
    }
  }

  Future<void> loadFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    isFirstLaunch.value = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch.value) {
      await setFirstLaunchComplete();
    }
  }

  Future<void> setFirstLaunchComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
  }

  // Global Dashboard Filter Settings Methods
  
  /// Load dashboard filter settings from SharedPreferences
  Future<void> loadDashboardFilters() async {
    final prefs = await SharedPreferences.getInstance();
    
    final year = prefs.getInt('dashboardFilterYear');
    dashboardFilterYear.value = year;
    
    final startDateStr = prefs.getString('dashboardFilterStartDate');
    if (startDateStr != null) {
      dashboardFilterStartDate.value = DateTime.parse(startDateStr);
    }
    
    final endDateStr = prefs.getString('dashboardFilterEndDate');
    if (endDateStr != null) {
      dashboardFilterEndDate.value = DateTime.parse(endDateStr);
    }
  }

  /// Set dashboard filter year
  Future<void> setDashboardFilterYear(int? year) async {
    dashboardFilterYear.value = year;
    final prefs = await SharedPreferences.getInstance();
    if (year != null) {
      await prefs.setInt('dashboardFilterYear', year);
    } else {
      await prefs.remove('dashboardFilterYear');
    }
    _notifyDashboardControllersToRefresh();
  }

  /// Set dashboard filter date range
  Future<void> setDashboardFilterDateRange(DateTime? startDate, DateTime? endDate) async {
    dashboardFilterStartDate.value = startDate;
    dashboardFilterEndDate.value = endDate;
    
    final prefs = await SharedPreferences.getInstance();
    
    if (startDate != null) {
      await prefs.setString('dashboardFilterStartDate', startDate.toIso8601String());
    } else {
      await prefs.remove('dashboardFilterStartDate');
    }
    
    if (endDate != null) {
      await prefs.setString('dashboardFilterEndDate', endDate.toIso8601String());
    } else {
      await prefs.remove('dashboardFilterEndDate');
    }
    
    _notifyDashboardControllersToRefresh();
  }

  /// Clear all dashboard filters
  Future<void> clearDashboardFilters() async {
    dashboardFilterYear.value = null;
    dashboardFilterStartDate.value = null;
    dashboardFilterEndDate.value = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dashboardFilterYear');
    await prefs.remove('dashboardFilterStartDate');
    await prefs.remove('dashboardFilterEndDate');
    
    _notifyDashboardControllersToRefresh();
    CustomSnackbar.showSuccess('Dashboard filters cleared');
  }

  /// Check if any dashboard filters are active
  bool get hasDashboardFilters {
    return dashboardFilterYear.value != null ||
           dashboardFilterStartDate.value != null ||
           dashboardFilterEndDate.value != null;
  }

  /// Get active filter description
  String get dashboardFilterDescription {
    List<String> parts = [];
    
    if (dashboardFilterYear.value != null) {
      parts.add('Year: ${dashboardFilterYear.value}');
    }
    
    if (dashboardFilterStartDate.value != null || dashboardFilterEndDate.value != null) {
      final start = dashboardFilterStartDate.value;
      final end = dashboardFilterEndDate.value;
      
      if (start != null && end != null) {
        parts.add('${_formatDate(start)} - ${_formatDate(end)}');
      } else if (start != null) {
        parts.add('From ${_formatDate(start)}');
      } else if (end != null) {
        parts.add('Until ${_formatDate(end)}');
      }
    }
    
    return parts.isEmpty ? 'No filters' : parts.join(', ');
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Notify dashboard controllers to refresh with new filters
  void _notifyDashboardControllersToRefresh() {
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().loadDashboardData();
    }
    if (Get.isRegistered<BillsDashboardController>()) {
      Get.find<BillsDashboardController>().loadData();
    }
  }
}

