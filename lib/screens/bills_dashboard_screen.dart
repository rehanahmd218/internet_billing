import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/bills_dashboard_controller.dart';
import '../common/widgets/app_colors.dart';
import '../common/widgets/bottom_nav_bar.dart';
import '../common/widgets/loading_indicator.dart';
import '../routes/app_routes.dart';

class BillsDashboardScreen extends StatelessWidget {
  const BillsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BillsDashboardController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),
            // Year Selector
            _buildYearSelector(context, isDark, controller),
            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.totalEarnings.value == 0) {
                  return const LoadingIndicator(message: 'Loading bills dashboard...');
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadData(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Grid
                          _buildStatsGrid(context, controller, isDark),
                          const SizedBox(height: 24),
                          // Monthly Revenue Chart
                          _buildMonthlyChart(context, controller, isDark),
                          const SizedBox(height: 24),
                          // Earnings by Year
                          _buildEarningsByYear(context, controller, isDark),
                      const SizedBox(height: 80),
                    ],
                  ),
                )
                );
              }),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: const BottomNavBar(currentIndex: 2),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addEditBill),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              'Bills Dashboard',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {},
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context, bool isDark, BillsDashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      child: Obx(() => DropdownButtonFormField<int>(
            initialValue: controller.selectedYear.value,
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.surfaceDark : Colors.white,
              prefixIcon: const Icon(Icons.calendar_month, color: AppColors.textSecondary),
              suffixIcon: const Icon(Icons.expand_more, color: AppColors.textSecondary),
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
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
            items: List.generate(10, (index) {
              final year = DateTime.now().year - 5 + index;
              return DropdownMenuItem(
                value: year,
                child: Text('$year${year == DateTime.now().year ? ' (Current Year)' : ''}'),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                controller.setSelectedYear(value);
              }
            },
          )),
    );
  }

  Widget _buildStatsGrid(BuildContext context, BillsDashboardController controller, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15, // Adjusted to prevent overflow
      children: [
        _buildStatCard(
          context,
          title: 'Total Earnings',
          subtitle: 'All Time',
          value: controller.totalEarnings.value,
          icon: Icons.attach_money,
          iconColor: AppColors.primary,
          isDark: isDark,
        ),
        _buildStatCard(
          context,
          title: 'Earnings',
          subtitle: 'Selected Year',
          value: controller.yearEarnings.value,
          icon: Icons.bar_chart,
          iconColor: Colors.green,
          isDark: isDark,
        ),
        _buildStatCard(
          context,
          title: 'Paying Users',
          subtitle: 'Active Accounts',
          value: controller.payingUsers.value.toDouble(),
          icon: Icons.check_box,
          iconColor: Colors.indigo,
          isDark: isDark,
          isInteger: true,
        ),
        _buildStatCard(
          context,
          title: 'Pending',
          subtitle: 'Needs Attention',
          value: controller.pendingAmount.value,
          icon: Icons.priority_high,
          iconColor: Colors.red,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required double value,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    bool isInteger = false,
  }) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isInteger
                        ? value.toInt().toString()
                        : 'Rs ${NumberFormat('#,##0').format(value)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, BillsDashboardController controller, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Revenue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Overview for ${controller.selectedYear.value}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {},
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() {
            final monthly = controller.monthlyEarnings;
            if (monthly.isEmpty) {
              return const SizedBox(height: 192);
            }
            
            final maxEarnings = monthly.reduce((a, b) => a > b ? a : b);
            final maxHeight = 192.0;
            
            return SizedBox(
              height: maxHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(12, (index) {
                  final height = maxEarnings > 0
                      ? (monthly[index] / maxEarnings * maxHeight)
                      : 0.0;
                  final monthAbbr = DateFormat('MMM').format(DateTime(controller.selectedYear.value, index + 1));
                  
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: height > 0 ? height : 4,
                            decoration: BoxDecoration(
                              color: height > 0 ? AppColors.primary : Colors.grey[300],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            monthAbbr[0],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEarningsByYear(BuildContext context, BillsDashboardController controller, bool isDark) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Earnings by Year',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.textMain,
              ),
            ),
          ),
          Obx(() {
            final earnings = controller.earningsByYear;
            if (earnings.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No earnings data available'),
                ),
              );
            }
            
            return Column(
              children: earnings.map((yearData) {
                final year = yearData['year'] as int;
                final total = (yearData['total'] as num).toDouble();
                final isCurrentYear = year == DateTime.now().year;
                
                return InkWell(
                  onTap: () => controller.setSelectedYear(year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isCurrentYear
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.grey[200]!.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: isCurrentYear ? AppColors.primary : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                year.toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textMain,
                                ),
                              ),
                              Text(
                                isCurrentYear ? 'Current Year' : 'Previous Year',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rs ${NumberFormat('#,##0').format(total)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : AppColors.textMain,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Closed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

