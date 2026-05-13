import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/user_bills_controller.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/status_badge.dart';
import '../common/widgets/loading_indicator.dart';
import '../models/bill_model.dart';
import '../routes/app_routes.dart';



class UserBillsScreen extends StatelessWidget {
  const UserBillsScreen({super.key});

  UserBillsController get controller => Get.put(UserBillsController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Year Selector
            _buildYearSelector(context, isDark),
            // Bills List
            Expanded(
              child: Obx(() => controller.isLoading.value
                  ? const LoadingIndicator(message: 'Loading bills...')
                  : RefreshIndicator(
                      onRefresh: controller.loadBills,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Monthly Bills
                            ...List.generate(12, (index) {
                              final month = index + 1;
                              final bill = controller.getBillForMonth(month);
                              final isUpcoming = DateTime(
                                controller.selectedYear.value,
                                month,
                              ).isAfter(DateTime.now());

                              return _buildMonthCard(
                                context,
                                month: month,
                                bill: bill,
                                isUpcoming: isUpcoming,
                                isDark: isDark,
                              );
                            }),
                            const SizedBox(height: 24),
                            // Year Summary Card
                            _buildYearSummary(context, isDark),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
            .withOpacity(0.95),
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
          Expanded(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userName.value.isEmpty ? 'User Bills' : controller.userName.value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.textMain,
                  ),
                ),
                if (controller.userUid.value.isNotEmpty)
                  Text(
                    'UID: ${controller.userUid.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
              ],
            )),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Obx(() => DropdownButtonFormField<int>(
        initialValue: controller.selectedYear.value,
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : Colors.white,
          prefixIcon: const Icon(
            Icons.calendar_today,
            color: AppColors.textSecondary,
          ),
          suffixIcon: const Icon(
            Icons.arrow_drop_down,
            color: AppColors.textSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        items: List.generate(10, (index) {
          final year = DateTime.now().year - 5 + index;
          return DropdownMenuItem(value: year, child: Text(year.toString()));
        }),
        onChanged: (value) {
          if (value != null) {
            controller.changeYear(value);
          }
        },
      )),
    );
  }

  Widget _buildMonthCard(
    BuildContext context, {
    required int month,
    BillModel? bill,
    required bool isUpcoming,
    required bool isDark,
  }) {
    final monthName = controller.months[month - 1];
    final isPaid = bill?.isPaid ?? false;
    final amount = bill?.amount ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: InkWell(
        onTap: isUpcoming
            ? null
            : () => Get.toNamed(
                AppRoutes.addEditBill,
                arguments: {
                  'userUid': controller.userUid.value,
                  'year': controller.selectedYear.value,
                  'month': month,
                },
              ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isUpcoming
                    ? Colors.grey[200]!.withOpacity(0.5)
                    : (isPaid
                          ? Colors.green[100]!.withOpacity(0.3)
                          : Colors.red[100]!.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUpcoming
                      ? Colors.grey[400]!
                      : (isPaid ? Colors.green[600]! : Colors.red[600]!),
                  width: 1,
                ),
              ),
              child: Icon(
                isUpcoming
                    ? Icons.calendar_today
                    : (isPaid ? Icons.check_circle : Icons.schedule),
                color: isUpcoming
                    ? Colors.grey[400]
                    : (isPaid ? Colors.green[600] : Colors.red[600]),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Month Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.textMain,
                        ),
                      ),
                      if (!isUpcoming) ...[
                        const SizedBox(width: 8),
                        StatusBadge(
                          status: isPaid ? 'Paid' : 'Pending',
                          isPaid: isPaid,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        isUpcoming
                            ? 'Upcoming'
                            : (isPaid && bill?.billDate != null
                                  ? DateFormat(
                                      'MMM dd, yyyy',
                                    ).format(bill!.billDate!)
                                  : 'Due ${DateFormat('MMM').format(DateTime(controller.selectedYear.value, month))} 01'),
                        style: TextStyle(
                          fontSize: 14,
                          color: isUpcoming
                              ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        ),
                      ),
                      if (!isUpcoming) ...[
                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                        Text(
                          'Rs ${NumberFormat('#,##0.00').format(amount)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppColors.textMain,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Action Icon
            Icon(
              isUpcoming
                  ? Icons.chevron_right
                  : (isPaid ? Icons.chevron_right : Icons.edit),
              color: isUpcoming ? Colors.grey[400] : AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearSummary(BuildContext context, bool isDark) {
    return Obx(() {
      final paidBills = controller.bills.where((bill) => bill.isPaid).toList();
      final totalPaid = paidBills.fold(0.0, (sum, bill) => sum + bill.amount);
      final projectedTotal =
          totalPaid / (paidBills.isNotEmpty ? paidBills.length : 1) * 12;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yearly Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs ${NumberFormat('#,##0').format(totalPaid)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Collected',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${NumberFormat('#,##0').format(projectedTotal)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Projected Total',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
    });
  }
}
