import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/user_controller.dart';
import '../controllers/bill_controller.dart';
import '../controllers/navigation_controller.dart';
import '../database/database_helper.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/status_badge.dart';
import '../common/widgets/loading_indicator.dart';
import '../routes/app_routes.dart';
import '../models/user_model.dart';

class UserDetailsScreen extends StatelessWidget {
  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = Get.arguments as int;
    final userController = Get.find<UserController>();
    final billController = Get.put(BillController());
    final db = DatabaseHelper.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<UserModel?>(
      future: db.getUserById(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            appBar: AppBar(
              backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
              ),
            ),
            body: const LoadingIndicator(message: 'Loading user details...'),
          );
        }

        final user = snapshot.data!;
        return Scaffold(
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  _buildHeader(context, isDark),
                  // Profile Section
                  _buildProfileSection(context, user, isDark),
                  // Contact Details
                  _buildContactSection(context, user, isDark),
                  // Action Buttons
                  _buildActionButtons(context, user, isDark),
                  // Financial Overview
                  _buildFinancialOverview(context, user, isDark),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
            color: isDark ? Colors.white : AppColors.textMain,
          ),
          Expanded(
            child: Text(
              'Customer Details',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textMainDark : AppColors.textMain,
              ),
            ),
          ),
          // Get user from arguments to pass to edit screen
          FutureBuilder<UserModel?>(
            future: DatabaseHelper.instance.getUserById(Get.arguments as int),
            builder: (context, snapshot) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: snapshot.hasData
                        ? () => Get.toNamed(
                              AppRoutes.addEditUser,
                              arguments: snapshot.data,
                            )
                        : null,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: snapshot.hasData
                        ? () => _showDeleteConfirmation(context, snapshot.data!)
                        : null,
                    color: AppColors.danger,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, UserModel user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[300],
                child: Text(
                  user.name[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: user.isActive ? AppColors.success : Colors.grey[400],
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.backgroundDark : Colors.white,
                      width: 3,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          StatusBadge(
            status: 'UID: ${user.uid}',
            isPaid: false,
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, UserModel user, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          _buildContactItem(
            context,
            icon: Icons.call,
            label: 'Mobile Number',
            value: user.mobileNumber,
            isDark: isDark,
            onTap: () {},
          ),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
          _buildContactItem(
            context,
            icon: Icons.location_on,
            label: 'Address',
            value: user.address,
            isDark: isDark,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              icon == Icons.call ? Icons.chat : Icons.map,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserModel user, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(
                AppRoutes.addEditBill,
                arguments: {'userUid': user.uid},
              ),
              icon: const Icon(Icons.add_circle),
              label: const Text('Add Bill'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.toNamed(
                AppRoutes.userBills,
                arguments: {'userUid': user.uid, 'userName': user.name},
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('View History'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : AppColors.textMain,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(BuildContext context, UserModel user, bool isDark) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getFinancialData(user.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator(message: 'Loading financial data...');
        }

        final data = snapshot.data!;
        final totalPaid = data['totalPaid'] as double;
        final pending = data['pending'] as double;
        final lastPayment = data['lastPayment'] as DateTime?;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Financial Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFinancialCard(
                      context,
                      label: 'Total Paid',
                      value: totalPaid,
                      color: AppColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFinancialCard(
                      context,
                      label: 'Pending',
                      value: pending,
                      color: AppColors.danger,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              if (lastPayment != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Payment Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM dd, yyyy').format(lastPayment),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textMain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildFinancialCard(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Rs ${NumberFormat('#,##0').format(value)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserModel user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Delete User',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textMain,
          ),
        ),
        content: Text(
          'Are you sure you want to delete ${user.name}? This will also delete all associated bills and cannot be undone.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final userController = Get.find<UserController>();
              final success = await userController.deleteUser(user.id!);
              if (success) {
                // Navigate to main screen with users tab selected
                final navController = Get.isRegistered<NavigationController>() ? Get.find<NavigationController>() : Get.put(NavigationController());
                navController.changeIndex(1); // Users tab
                Get.offAllNamed(AppRoutes.main);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getFinancialData(String userUid) async {
    final db = DatabaseHelper.instance;
    final bills = await db.getUserBills(userUid,2025);
    
    double totalPaid = 0;
    double pending = 0;
    DateTime? lastPayment;

    for (var bill in bills) {
      if (bill.isPaid) {
        totalPaid += bill.amount;
        if (bill.billDate != null) {
          if (lastPayment == null || bill.billDate!.isAfter(lastPayment)) {
            lastPayment = bill.billDate;
          }
        }
      } else {
        pending += bill.amount;
      }
    }

    return {
      'totalPaid': totalPaid,
      'pending': pending,
      'lastPayment': lastPayment,
    };
  }
}

