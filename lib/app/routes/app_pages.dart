import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/views/manager/dashboard.dart';
import '../modules/auth/views/manager/login_screen.dart';
import '../modules/auth/views/manager/register_screen.dart';
// later we will import dashboard_view.dart too

import 'app_routes.dart';

class AppPages {
  static final pages = [
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
  ];
}
