import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/bill_controller.dart';
import '../controllers/user_controller.dart';
import '../database/database_helper.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/custom_text_field.dart';
import '../common/widgets/custom_snackbar.dart';
import '../routes/app_routes.dart';
import '../models/bill_model.dart';
import '../models/user_model.dart';

class AddEditBillScreen extends StatefulWidget {
  const AddEditBillScreen({super.key});

  @override
  State<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends State<AddEditBillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  final billController = Get.put(BillController());
  final userController = Get.find<UserController>();
  
  UserModel? _selectedUser;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  bool _isPaid = false;
  DateTime? _billDate;
  bool _isLoading = false;
  BillModel? _editingBill;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final args = Get.arguments;
    if (args != null && args is Map) {
      final userUid = args['userUid'] as String?;
      if (userUid != null) {
        _selectedUser = await DatabaseHelper.instance.getUserByUid(userUid);
      }
      
      final year = args['year'] as int?;
      final month = args['month'] as int?;
      if (year != null && month != null) {
        _selectedYear = year;
        _selectedMonth = month;
        
        if (_selectedUser != null) {
          final bill = await DatabaseHelper.instance.getBill(
            _selectedUser!.uid,
            year,
            month,
          );
          if (bill != null) {
            _editingBill = bill;
            _amountController.text = bill.amount.toString();
            _notesController.text = bill.notes ?? '';
            _isPaid = bill.isPaid;
            _billDate = bill.billDate;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectUser() async {
    final result = await Get.toNamed(AppRoutes.usersList, arguments: {'selectMode': true});
    if (result != null && result is UserModel) {
      setState(() {
        _selectedUser = result;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _billDate = picked;
      });
    }
  }

  Future<void> _saveBill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUser == null) {
      CustomSnackbar.showError('Please select a user');
      return;
    }

    setState(() => _isLoading = true);

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final isPaid = amount > 0;
    
    // If paid, bill date is required
    if (isPaid && _billDate == null) {
      CustomSnackbar.showError('Please select payment date');
      setState(() => _isLoading = false);
      return;
    }

    final bill = BillModel(
      id: _editingBill?.id,
      userUid: _selectedUser!.uid,
      year: _selectedYear,
      month: _selectedMonth,
      amount: amount,
      billDate: isPaid ? _billDate : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: _editingBill?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await billController.createOrUpdateBill(bill);

    setState(() => _isLoading = false);

    if (success) {
      Get.back();
      // Snackbar is already shown in the controller
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                _editingBill == null ? 'New Bill' : 'Edit Bill',
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
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer Selection
              CustomTextField(
                label: 'Customer',
                controller: TextEditingController(
                  text: _selectedUser != null
                      ? '${_selectedUser!.name} (ID: ${_selectedUser!.uid})'
                      : null,
                ),
                readOnly: true,
                hint: 'Select a customer',
                suffixIcon: const Icon(Icons.lock, size: 20),
                onChanged: (value) {},
              ),
              if (_selectedUser == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton.icon(
                    onPressed: _selectUser,
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
                        const Text(
                          'Month',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedMonth,
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
                              child: Text(_months[index]),
                            );
                          }),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedMonth = value);
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
                        const Text(
                          'Year',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedYear,
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
                              setState(() => _selectedYear = value);
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
                controller: _amountController,
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
                        color: AppColors.textSecondary,
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
                              onTap: () => setState(() {
                                _isPaid = false;
                                _billDate = null;
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isPaid
                                      ? Colors.transparent
                                      : (isDark ? Colors.grey[700] : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isPaid
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
                                    color: _isPaid
                                        ? AppColors.textSecondary
                                        : (isDark ? Colors.white : AppColors.textMain),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isPaid = true;
                                _billDate ??= DateTime.now();
                              }),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _isPaid
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: _isPaid
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
                                    color: _isPaid ? Colors.white : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Date Picker (shown when Paid is selected)
                    if (_isPaid) ...[
                      const SizedBox(height: 16),
                      Divider(color: isDark ? Colors.grey[800] : Colors.grey[200]),
                      const SizedBox(height: 16),
                      const Text(
                        'Date Received',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
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
                                  _billDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_billDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _billDate != null
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
                controller: _notesController,
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
                onPressed: _isLoading ? null : _saveBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
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
  }
}

