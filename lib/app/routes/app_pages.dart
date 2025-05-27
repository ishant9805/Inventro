import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/manager/add_employee_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/add_product_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/dashboard.dart';
import 'package:inventro/app/modules/auth/views/manager/profile_screen.dart';
import 'package:inventro/app/modules/auth/views/role_selection_screen.dart';
import 'package:inventro/app/modules/auth/views/splash_screen.dart';
import '../modules/auth/views/manager/login_screen.dart';
import '../modules/auth/views/manager/register_screen.dart';
// later we will import dashboard_view.dart too

import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.roleSelection, 
      page: () => const RoleSelectionScreen()
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterScreen(),
    ),
    GetPage(
     name: AppRoutes.dashboard,
     page: () => ManagerDashboard(),   // will create later after login
   ),
    GetPage(
      name: AppRoutes.addEmployee,
      page: () => AddEmployeeScreen(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductScreen(),
    ),
    GetPage(
      name: AppRoutes.managerProfile,
      page: () => ManagerProfileScreen(),
    ),
  ];
}
