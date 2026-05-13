import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:internet_billing/controllers/navigation_controller.dart';
import 'app_colors.dart';
import 'package:internet_billing/screens/dashboard_screen.dart';
import 'package:internet_billing/screens/users_list_screen.dart';
import 'package:internet_billing/screens/bills_dashboard_screen.dart';
import 'package:internet_billing/screens/settings_screen.dart';



class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.dashboard,
              label: 'Home',
              isActive: currentIndex == 0,
              onTap: () => onTabTapped(0),
            ),
            _NavItem(
              icon: Icons.group,
              label: 'Users',
              isActive: currentIndex == 1,
              onTap: () => onTabTapped(1),
            ),
            _NavItem(
              icon: Icons.receipt_long,
              label: 'Bills',
              isActive: currentIndex == 2,
              onTap: () => onTabTapped(2),
            ),
            _NavItem(
              icon: Icons.settings,
              label: 'Settings',
              isActive: currentIndex == 3,
              onTap: () => onTabTapped(3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : Colors.grey[500],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.primary : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// main_screen_getx.dart - GetX version
class MainScreenGetX extends StatelessWidget {
  MainScreenGetX({super.key});

  final NavigationController navController = Get.isRegistered<NavigationController>()
      ? Get.find<NavigationController>()
      : Get.put(NavigationController());

  final List<Widget> _screens = [
    const DashboardScreen(),
    const UsersListScreen(),
    const BillsDashboardScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: navController.currentIndex,
        children: _screens,
      )),
      bottomNavigationBar: Obx(() => BottomNavBar(
        currentIndex: navController.currentIndex,
        onTabTapped: navController.changeIndex,
      )),
    );
  }
}