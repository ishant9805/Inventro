import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/employee/employee_login_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/add_employee_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/add_product_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/edit_product_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/dashboard.dart';
import 'package:inventro/app/modules/auth/views/manager/employee_list_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/login_screen.dart';
import 'package:inventro/app/modules/auth/views/manager/profile_screen.dart';
import 'package:inventro/app/modules/auth/views/role_selection_screen.dart';
import 'package:inventro/app/modules/auth/views/splash_screen.dart';
import '../modules/auth/views/manager/company_creation_page.dart';
import '../modules/auth/views/manager/create_company_screen.dart';
import '../modules/auth/views/manager/manager_registration_screen.dart';
import '../modules/auth/bindings/edit_product_binding.dart';

import 'app_routes.dart';

class AppPages {
  static const INITIAL = '/';

  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => ManagerDashboard(),
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
      name: AppRoutes.editProduct,
      page: () => EditProductScreen(),
      binding: EditProductBinding(), // Add proper binding for controller management
    ),
    GetPage(
      name: AppRoutes.managerProfile,
      page: () => ManagerProfileScreen(),
    ),
    GetPage(
      name: AppRoutes.employeeList,
      page: () => EmployeeListScreen(),
    ),
    GetPage(
      name: AppRoutes.employeeLogin,
      page: () => EmployeeLoginScreen(),
    ),
    GetPage(
      name: AppRoutes.companyCreation,
      page: () => CompanyCreationPage(),
    ),
    GetPage(
      name: AppRoutes.createCompanyScreen,
      page: () => const CreateCompanyScreen(),
    ),
    GetPage(
      name: AppRoutes.managerRegistration,
      page: () => const ManagerRegistrationScreen(),
    ),
  ];
}
