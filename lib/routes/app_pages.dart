import 'package:get/get.dart';
import 'app_routes.dart';
import '../screens/splash_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/users_list_screen.dart';
import '../screens/user_details_screen.dart';
import '../screens/add_edit_user_screen.dart';
import '../screens/add_edit_bill_screen.dart';
import '../screens/user_bills_screen.dart';
import '../screens/bills_dashboard_screen.dart';
import '../screens/settings_screen.dart';
import 'package:internet_billing/common/widgets/bottom_nav_bar.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.main,
      page: () => MainScreenGetX(),
    ),
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.usersList,
      page: () => const UsersListScreen(),
    ),
    GetPage(
      name: AppRoutes.userDetails,
      page: () => const UserDetailsScreen(),
    ),
    GetPage(
      name: AppRoutes.addEditUser,
      page: () => const AddEditUserScreen(),
    ),
    GetPage(
      name: AppRoutes.addEditBill,
      page: () => const AddEditBillScreen(),
    ),
    GetPage(
      name: AppRoutes.userBills,
      page: () => const UserBillsScreen(),
    ),
    GetPage(
      name: AppRoutes.billsDashboard,
      page: () => const BillsDashboardScreen(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
    ),
  ];
}

