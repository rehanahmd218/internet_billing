import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/add_edit_bill_controller.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/custom_text_field.dart';

class AddEditBillScreen extends StatelessWidget {
  const AddEditBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put with permanent: false to ensure it's cleaned up
    final controller = Get.put(AddEditBillController(), permanent: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isEditing = controller.editingBill.value != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Get.back(),
                color: isDark ? Colors.white : AppColors.textMain,
              ),
              title: Text(
                isEditing ? 'Edit Bill' : 'New Bill',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textMain,
                ),
              ),
              centerTitle: true,
              actions: [
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Help',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
              // Customer Selection
              CustomTextField(
                label: 'Customer',
                controller: TextEditingController(
                  text: controller.selectedUser.value != null
                      ? '${controller.selectedUser.value!.name} (ID: ${controller.selectedUser.value!.uid})'
                      : null,
                ),
                readOnly: true,
                hint: 'Select a customer',
                suffixIcon: const Icon(Icons.lock, size: 20),
                onChanged: (value) {},
              ),
              if (controller.selectedUser.value == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: controller.selectUser,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Select Customer'),
                  ),
                ),
              const SizedBox(height: 24),
              // Month and Year
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Month',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMainDark : AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: controller.selectedMonth.value,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: List.generate(12, (index) {
                          return DropdownMenuItem(
                            value: index + 1,
                            child: Text(controller.months[index]),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedMonth.value = value;
                          }
                        },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Year',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textMainDark : AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        initialValue: controller.selectedYear.value,
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          items: List.generate(10, (index) {
                            final year = DateTime.now().year - 5 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (value) {
                          if (value != null) {
                            controller.selectedYear.value = value;
                          }
                        },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Amount
              CustomTextField(
                label: 'Bill Amount',
                hint: '0.00',
                controller: controller.amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                prefixIcon: const Icon(Icons.attach_money),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Amount is required';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Invalid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Status and Date Card
              Container(
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
                    Text(
                      'PAYMENT STATUS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Segmented Control
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                          onTap: () => controller.togglePaidStatus(false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: controller.isPaid.value
                                  ? Colors.transparent
                                  : (isDark ? Colors.grey[700] : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: controller.isPaid.value
                                  ? null
                                  : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.05),
                                            blurRadius: 4,
                                          ),
                                        ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                              'Pending',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: controller.isPaid.value
                                    ? AppColors.textSecondary
                                    : (isDark ? Colors.white : AppColors.textMain),
                              ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                          onTap: () => controller.togglePaidStatus(true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: controller.isPaid.value
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: controller.isPaid.value
                                  ? [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                          ),
                                        ]
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                              'Paid',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: controller.isPaid.value ? Colors.white : AppColors.textSecondary,
                              ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date Picker (shown when Paid is selected)
                    if (controller.isPaid.value) ...[
                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      const SizedBox(height: 16),
                      Text(
                        'Date Received',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textMainDark : AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => controller.selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[900] : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.grey[600]! : Colors.grey[200]!,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                              child: Text(
                                controller.billDate.value != null
                                    ? DateFormat('yyyy-MM-dd').format(controller.billDate.value!)
                                    : 'Select date',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: controller.billDate.value != null
                                      ? (isDark ? Colors.white : AppColors.textMain)
                                      : AppColors.textSecondary,
                                ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_today,
                                color: AppColors.textSecondary,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Notes
              CustomTextField(
                label: 'Notes (Optional)',
                hint: 'Add internal notes about this transaction...',
                controller: controller.notesController,
                maxLines: 4,
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
          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(
                    color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Bill',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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

