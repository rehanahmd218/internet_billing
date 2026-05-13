import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/settings_controller.dart';
import '../common/widgets/app_colors.dart';
import '../utils/seed_users_helper.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backup & Restore Section
                    _buildSectionHeader('Backup & Restore'),
                    const SizedBox(height: 12),
                    _buildBackupRestoreCard(context, controller, isDark),
                    const SizedBox(height: 24),

                    // Dashboard Filters Section
                    _buildSectionHeader('Dashboard Filters'),
                    const SizedBox(height: 12),
                    _buildDashboardFiltersCard(context, controller, isDark),
                    const SizedBox(height: 24),

                    // Preferences Section
                    _buildSectionHeader('Preferences'),
                    const SizedBox(height: 12),
                    _buildPreferencesCard(context, controller, isDark),
                    const SizedBox(height: 24),

                    // Developer Section (Seeding)
                    _buildSectionHeader('Developer Tools'),
                    const SizedBox(height: 12),

                    // About Section
                    _buildSectionHeader('About'),
                    const SizedBox(height: 12),
                    _buildInfoCard(context, isDark),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            // Version Footer
            // _buildVersionFooter(),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
            color: isDark ? Colors.white : AppColors.textMain,
          ),
          const Expanded(
            child: Text(
              'Settings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildBackupRestoreCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Column(
      children: [
        // Google Drive Connection Card
        Obx(() => Container(
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: controller.isSignedInToGoogle.value
                              ? Colors.green.withOpacity(0.1)
                              : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          controller.isSignedInToGoogle.value
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: controller.isSignedInToGoogle.value
                              ? Colors.green
                              : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Google Drive',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              controller.isSignedInToGoogle.value
                                  ? controller.googleUserEmail.value
                                  : 'Connect to enable cloud backup',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (controller.isSignedInToGoogle.value)
                        OutlinedButton(
                          onPressed: () => controller.signOutFromGoogle(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                                isDark ? Colors.white : AppColors.textMain,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            side: BorderSide(
                              color: isDark
                                  ? Colors.grey[600]!
                                  : Colors.grey[300]!,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Disconnect'),
                        )
                      else
                        ElevatedButton(
                          onPressed: () => controller.signInToGoogle(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Connect'),
                        ),
                    ],
                  ),
                ],
              ),
            )),
        const SizedBox(height: 12),
        // Backup to Drive Card
        Obx(() => Container(
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
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_upload,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Backup to Drive',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Upload database to Google Drive',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: controller.isSignedInToGoogle.value &&
                            !controller.isBackupLoading.value
                        ? () => controller.backupToGoogleDrive()
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isBackupLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Backup'),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 12),
        // Restore from Drive Card
        Obx(() {
          if (!controller.isSignedInToGoogle.value) {
            return const SizedBox.shrink();
          }

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
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restore,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available Backups',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Restore from Google Drive',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 20),
                      onPressed: () => controller.loadBackupsList(),
                      color: AppColors.primary,
                    ),
                  ],
                ),
                if (controller.availableBackups.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...controller.availableBackups.take(5).map((backup) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.backup,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatBackupDate(backup.createdTime),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                Text(
                                  backup.formattedSize,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => _showRestoreConfirmation(
                                context, controller, backup.id, isDark),
                            child: const Text('Restore',
                                style: TextStyle(fontSize: 12)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            onPressed: () => _showDeleteConfirmation(
                                context, controller, backup.id, isDark),
                            color: Colors.red,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }),
                ] else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No backups found',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatBackupDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showRestoreConfirmation(
    BuildContext context,
    SettingsController controller,
    String fileId,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Restore Backup?'),
        content: const Text(
          'This will replace all current data with the backup. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.restoreFromGoogleDrive(fileId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SettingsController controller,
    String fileId,
    bool isDark,
  ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Backup?'),
        content: const Text(
          'This will permanently delete this backup from Google Drive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteBackup(fileId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Column(
        children: [
          // Currency
          ListTile(
            leading: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.currency_rupee,
                color: Colors.green,
                size: 20,
              ),
            ),
            title: const Text(
              'Currency',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() => Text(
                      controller.currency.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    )),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
          Divider(color: isDark ? Colors.grey[800] : Colors.grey[200], height: 1),
          // Dark Mode Toggle
          Obx(() => SwitchListTile(
                secondary: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.dark_mode,
                    color: Colors.indigo,
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMain,
                  ),
                ),
                value: controller.isDarkMode.value,
                onChanged: (value) => controller.toggleDarkMode(),
              )),
        ],
      ),
    );
  }


  Widget _buildInfoCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.info,
            color: Colors.orange,
            size: 20,
          ),
        ),
        title: const Text(
          'About App',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMain,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
          size: 20,
        ),
        onTap: () {
          Get.dialog(
            AlertDialog(
              title: const Text('About EasyNet Billing'),
              content: const Text('Internet Billing Management System\nVersion 1.0.0'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  
  Widget _buildDashboardFiltersCard(
    BuildContext context,
    SettingsController controller,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.filter_alt,
                  color: Colors.purple[600],
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Global Dashboard Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Apply filters to pending bills on dashboards',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Active Filters Indicator
          Obx(() {
            if (controller.hasDashboardFilters) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Active: ${controller.dashboardFilterDescription}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Year Filter
          Text(
            'Filter Year',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<int?>(
                initialValue: controller.dashboardFilterYear.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.backgroundDark : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text('All Years', style: TextStyle(color: AppColors.textSecondary)),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('All Years', style: TextStyle(color: isDark ? Colors.white : AppColors.textMain)),
                  ),
                  ...List.generate(10, (index) {
                    final year = DateTime.now().year - 5 + index;
                    return DropdownMenuItem<int?>(
                      value: year,
                      child: Text('$year', style: TextStyle(color: isDark ? Colors.white : AppColors.textMain)),
                    );
                  }),
                ],
                onChanged: (value) {
                  controller.setDashboardFilterYear(value);
                },
              )),
          const SizedBox(height: 16),

          // Date Range
          Text(
            'Date Range',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textMainDark : AppColors.textMain,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Obx(() => _buildDateField(
                      context,
                      label: 'From',
                      date: controller.dashboardFilterStartDate.value,
                      onTap: () => _selectDashboardStartDate(context, controller),
                      onClear: () => controller.setDashboardFilterDateRange(null, controller.dashboardFilterEndDate.value),
                      isDark: isDark,
                    )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => _buildDateField(
                      context,
                      label: 'To',
                      date: controller.dashboardFilterEndDate.value,
                      onTap: () => _selectDashboardEndDate(context, controller),
                      onClear: () => controller.setDashboardFilterDateRange(controller.dashboardFilterStartDate.value, null),
                      isDark: isDark,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Clear Filters Button
          Obx(() {
            if (controller.hasDashboardFilters) {
              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.clearDashboardFilters(),
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All Filters'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildDateField(
    BuildContext context, {
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : label,
                style: TextStyle(
                  color: date != null
                      ? (isDark ? Colors.white : AppColors.textMain)
                      : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(
                  Icons.clear,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDashboardStartDate(BuildContext context, SettingsController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.dashboardFilterStartDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: controller.dashboardFilterEndDate.value ?? DateTime(2100),
    );
    if (picked != null) {
      controller.setDashboardFilterDateRange(picked, controller.dashboardFilterEndDate.value);
    }
  }

  Future<void> _selectDashboardEndDate(BuildContext context, SettingsController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.dashboardFilterEndDate.value ?? DateTime.now(),
      firstDate: controller.dashboardFilterStartDate.value ?? DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.setDashboardFilterDateRange(controller.dashboardFilterStartDate.value, picked);
    }
  }
}
