import 'package:get/get.dart';
import 'package:wifi_billing/app/modules/bills/bindings/bill_binding.dart';
import 'package:wifi_billing/app/modules/bills/views/add_edit_bill_screen.dart';
import 'package:wifi_billing/app/modules/bills/views/bills_year_screen.dart';
import 'package:wifi_billing/app/modules/bills/views/monthly_bills_screen.dart';
import 'package:wifi_billing/app/modules/dashboard/bindings/dashboard_binding.dart';
import 'package:wifi_billing/app/modules/dashboard/views/dashboard_screen.dart';
import 'package:wifi_billing/app/modules/settings/bindings/settings_binding.dart';
import 'package:wifi_billing/app/modules/settings/views/settings_screen.dart';
import 'package:wifi_billing/app/modules/splash/bindings/splash_binding.dart';
import 'package:wifi_billing/app/modules/splash/views/splash_screen.dart';
import 'package:wifi_billing/app/modules/users/bindings/user_binding.dart';
import 'package:wifi_billing/app/modules/users/views/add_edit_user_screen.dart';
import 'package:wifi_billing/app/modules/users/views/user_details_screen.dart';
import 'package:wifi_billing/app/modules/users/views/users_list_screen.dart';
import 'package:wifi_billing/app/routes/app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.usersList,
      page: () => const UsersListScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.userDetails,
      page: () => const UserDetailsScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditUser,
      page: () => const AddEditUserScreen(),
      binding: UserBinding(),
    ),
    GetPage(
      name: AppRoutes.billsYear,
      page: () => const BillsYearScreen(),
      binding: BillBinding(),
    ),
    GetPage(
      name: AppRoutes.monthlyBills,
      page: () => const MonthlyBillsScreen(),
      binding: BillBinding(),
    ),
    GetPage(
      name: AppRoutes.addEditBill,
      page: () => const AddEditBillScreen(),
      binding: BillBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
  ];
}
