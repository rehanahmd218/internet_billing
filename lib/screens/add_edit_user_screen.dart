import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_controller.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/custom_text_field.dart';
import '../models/user_model.dart';

class AddEditUserScreen extends StatefulWidget {
  const AddEditUserScreen({super.key});

  @override
  State<AddEditUserScreen> createState() => _AddEditUserScreenState();
}

class _AddEditUserScreenState extends State<AddEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _uidController = TextEditingController();
  final _noController = TextEditingController();
  
  final userController = Get.find<UserController>();
  UserModel? _editingUser;
  bool _isLoading = false;
  int? _generatedNo;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  Future<void> _initializeFields() async {
    final args = Get.arguments;
    if (args != null && args is UserModel) {
      _editingUser = args;
      _nameController.text = _editingUser!.name;
      _mobileController.text = _editingUser!.mobileNumber;
      _addressController.text = _editingUser!.address;
      _uidController.text = _editingUser!.uid;
      _noController.text = _editingUser!.no.toString();
    } else {
      // Generate sequential number for new user
      _generatedNo = await userController.generateNo();
      _noController.text = _generatedNo.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _uidController.dispose();
    _noController.dispose();
    super.dispose();
  }

  String? _validateMobile(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mobile number is required';
    }
    // Basic mobile validation
    if (value.length < 10) {
      return 'Invalid mobile number';
    }
    return null;
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final user = UserModel(
      id: _editingUser?.id,
      no: _editingUser?.no ?? _generatedNo ?? 1,
      uid: _uidController.text.trim(),
      name: _nameController.text.trim(),
      mobileNumber: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      createdDate: _editingUser?.createdDate ?? DateTime.now(),
      isActive: _editingUser?.isActive ?? true,
    );

    final success = _editingUser == null
        ? await userController.createUser(user)
        : await userController.updateUser(user);

    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      // Snackbar is already shown in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = _editingUser != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      CustomTextField(
                        label: 'Full Name',
                        hint: 'e.g. John Doe',
                        controller: _nameController,
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
                              const Text(
                                'Customer No',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMain,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Auto-generated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: _noController,
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
                        controller: _uidController,
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
                        hint: '0300-1234567',
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: _validateMobile,
                      ),
                      const SizedBox(height: 24),
                      // Address
                      CustomTextField(
                        label: 'Address',
                        hint: 'Street, Apt, City, State, Zip Code',
                        controller: _addressController,
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
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
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
                      onPressed: _isLoading ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
  }
}