import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wifi_billing/app/core/constants/app_constants.dart';
import 'package:wifi_billing/app/core/utils/validators.dart';
import 'package:wifi_billing/app/data/models/user_model.dart';
import 'package:wifi_billing/app/modules/users/controllers/user_controller.dart';
import 'package:wifi_billing/app/widgets/loading_overlay.dart';

class AddEditUserScreen extends GetView<UserController> {
  const AddEditUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final user = args?['user'] as UserModel?;
    final isEdit = user != null;

    if (isEdit) {
      controller.selectUser(user);
    }

    final formKey = GlobalKey<FormState>();

    return Obx(() => LoadingOverlay(
          isLoading: controller.isLoading.value,
          child: Scaffold(
            appBar: AppBar(
              title: Text(isEdit ? 'Edit User' : 'Add User'),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: Validators.validateName,
                    ),
                    const SizedBox(height: 16),

                    // UID Field
                    TextFormField(
                      controller: controller.uidController,
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        prefixIcon: Icon(Icons.fingerprint),
                        helperText: 'Unique ID cannot be changed later',
                      ),
                      enabled: !isEdit,
                      validator: Validators.validateUid,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: controller.phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: Validators.validatePhone,
                    ),
                    const SizedBox(height: 16),

                    // Address Field
                    TextFormField(
                      controller: controller.addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                      validator: Validators.validateAddress,
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
                              value: AppConstants.statusActive,
                              child: Text('Active'),
                            ),
                            DropdownMenuItem(
                              value: AppConstants.statusInactive,
                              child: Text('Inactive'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedStatus.value = value;
                            }
                          },
                        )),
                    const SizedBox(height: 32),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          bool success;
                          if (isEdit) {
                            success = await controller.updateUser();
                          } else {
                            success = await controller.createUser();
                          }
                          if (success) {
                            Get.back();
                          }
                        }
                      },
                      child: Text(isEdit ? 'Update User' : 'Save User'),
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
