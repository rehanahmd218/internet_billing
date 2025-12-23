import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/validators.dart';
import 'package:wifi_billing/app/modules/bills/controllers/bill_controller.dart';
import 'package:wifi_billing/app/widgets/loading_overlay.dart';

class AddEditBillScreen extends GetView<BillController> {
  const AddEditBillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final userId = args?['userId'] as String?;
    
    final formKey = GlobalKey<FormState>();

    return Obx(() => LoadingOverlay(
          isLoading: controller.isLoading.value,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Bill'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Month Dropdown
                    Obx(() => DropdownButtonFormField<int>(
                          initialValue: controller.selectedMonth.value,
                          decoration: const InputDecoration(
                            labelText: 'Month',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(AppConstants.months[index]),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedMonth.value = value;
                            }
                          },
                        )),
                    const SizedBox(height: 16),

                    // Year Dropdown
                    Obx(() => DropdownButtonFormField<int>(
                          initialValue: controller.selectedYear.value,
                          decoration: const InputDecoration(
                            labelText: 'Year',
                            prefixIcon: Icon(Icons.calendar_month),
                          ),
                          items: List.generate(5, (index) {
                            final year = DateTime.now().year - 2 + index;
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
                        )),
                    const SizedBox(height: 16),

                    // Amount Field
                    TextFormField(
                      controller: controller.amountController,
                      decoration: const InputDecoration(
                        labelText: 'Bill Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: Validators.validateAmount,
                    ),
                    const SizedBox(height: 16),

                    // Status Dropdown
                    Obx(() => DropdownButtonFormField<String>(
                          initialValue: controller.selectedStatus.value,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            prefixIcon: Icon(Icons.toggle_on),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: AppConstants.billStatusPending,
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.billStatusPaid,
                              child: Text('Paid'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                        )),
                    const SizedBox(height: 16),

                    // Notes Field
                    TextFormField(
                      controller: controller.notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate() && userId != null) {
                          final success = await controller.createBill(userId: userId);
                          if (success) {
                            Get.back();
                          }
                        }
                      },
                      child: const Text('Save Bill'),
                    ),
                    const SizedBox(height: 8),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
