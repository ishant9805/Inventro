import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/utils/responsive_utils.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';
import 'widgets/unified_dashboard_card.dart';
import 'widgets/dashboard_actions.dart';
import 'widgets/dashboard_stat_cards.dart';
import 'widgets/product_grid.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.put(DashboardController());
    
    // Modern gradient matching other screens
    const List<Color> gradientColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getPadding(context),
                    vertical: ResponsiveUtils.getSpacing(context, 24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Unified Header and Welcome Card
                      UnifiedDashboardCard(authController: authController),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                      
                      // Quick Actions
                      const DashboardActions(),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                      
                      // Statistics Cards
                      DashboardStatCards(dashboardController: dashboardController),
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 24)),
                      
                      // Inventory Section
                      ProductGrid(dashboardController: dashboardController),
                      
                      SizedBox(height: ResponsiveUtils.getSpacing(context, 32)),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}