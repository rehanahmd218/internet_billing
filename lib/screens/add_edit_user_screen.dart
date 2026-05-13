import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_edit_user_controller.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/custom_text_field.dart';

class AddEditUserScreen extends StatelessWidget {
  const AddEditUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put with permanent: false to ensure it's cleaned up
    final controller = Get.put(AddEditUserController(), permanent: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isEditing = controller.editingUser.value != null;

      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              // AppBar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => Get.back(),
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                  title: Text(
                    isEditing ? 'Edit Customer' : 'Add Customer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),
              // Form Content
              Expanded(
                child: Form(
                  key: controller.formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        CustomTextField(
                          label: 'Full Name',
                          hint: 'e.g. John Doe',
                          controller: controller.nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Sequential Number (Auto-generated)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Customer No',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textMainDark
                                        : AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Auto-generated',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: controller.noController,
                              readOnly: true,
                              suffixIcon: const Icon(Icons.lock, size: 20),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // UID (User-provided)
                        CustomTextField(
                          label: 'Customer UID',
                          hint: 'Enter unique customer identifier',
                          controller: controller.uidController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'UID is required';
                            }
                            if (value.trim().isEmpty) {
                              return 'UID cannot be empty';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Mobile Number
                        CustomTextField(
                          label: 'Mobile Number',
                          hint: '03001234567',
                          maxLength: 11,
                          controller: controller.mobileController,
                          keyboardType: TextInputType.phone,
                          validator: controller.validateMobile,
                        ),
                        const SizedBox(height: 24),
                        // Internet Speed
                        CustomTextField(
                          label: 'Internet Speed (Mbps)',
                          hint: 'e.g. 50',
                          controller: controller.internetSpeedController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Internet speed is required';
                            }
                            final speed = int.tryParse(value);
                            if (speed == null || speed < 0) {
                              return 'Please enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        // Address
                        CustomTextField(
                          label: 'Address',
                          hint: 'Street, Apt, City, State, Zip Code',
                          controller: controller.addressController,
                          maxLines: 4,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Address is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom Actions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.saveUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                isEditing ? 'Update Customer' : 'Save Customer',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
