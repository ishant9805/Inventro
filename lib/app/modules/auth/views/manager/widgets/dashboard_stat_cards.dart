import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/utils/responsive_utils.dart';

class DashboardStatCards extends StatelessWidget {
  final DashboardController dashboardController;

  const DashboardStatCards({
    super.key,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: ResponsiveUtils.getSpacing(context, 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Overview',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 20),
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: ResponsiveUtils.isSmallScreen(context) ? 0.8 : 1.2,
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
          LayoutBuilder(
            builder: (context, constraints) {
              if (ResponsiveUtils.isSmallScreen(context)) {
                // Stack cards vertically on small screens
                return _buildVerticalLayout(context);
              } else {
                // Keep horizontal layout for larger screens
                return _buildHorizontalLayout(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(BuildContext context) {
    return Obx(() => Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'Total Products',
            value: '${dashboardController.products.length}',
            icon: Icons.inventory,
            color: const Color(0xFF4A00E0),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'Low Stock',
            value: '${dashboardController.lowStockProducts.length}',
            icon: Icons.warning,
            color: const Color(0xFF800020),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
        Expanded(
          child: _buildStatCard(
            context: context,
            title: 'Expiring Soon',
            value: '${dashboardController.expiringProducts.length}',
            icon: Icons.schedule,
            color: Colors.yellow,
          ),
        ),
      ],
    ));
  }

  Widget _buildVerticalLayout(BuildContext context) {
    return Obx(() => Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Total Products',
                value: '${dashboardController.products.length}',
                icon: Icons.inventory,
                color: const Color(0xFF4A00E0),
                isCompact: true,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
            Expanded(
              child: _buildStatCard(
                context: context,
                title: 'Low Stock',
                value: '${dashboardController.lowStockProducts.length}',
                icon: Icons.warning,
                color: const Color(0xFF800020),
                isCompact: true,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
        _buildStatCard(
          context: context,
          title: 'Expiring Soon',
          value: '${dashboardController.expiringProducts.length}',
          icon: Icons.schedule,
          color: Colors.orange,
          isFullWidth: true,
        ),
      ],
    ));
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    bool isCompact = false,
    bool isFullWidth = false,
  }) {
    final cardPadding = ResponsiveUtils.getPadding(context, 
        factor: isCompact ? 0.04 : 0.05);
    
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: ResponsiveUtils.getSpacing(context, 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: isFullWidth 
        ? _buildFullWidthContent(context, title, value, icon, color)
        : _buildCompactContent(context, title, value, icon, color, isCompact),
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isCompact,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, isCompact ? 8 : 12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          ),
          child: Icon(
            icon, 
            size: ResponsiveUtils.getIconSize(context, isCompact ? 20 : 28), 
            color: color,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, isCompact ? 18 : 24),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, isCompact ? 10 : 12),
              color: const Color(0xFF6C757D),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFullWidthContent(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          ),
          child: Icon(
            icon, 
            size: ResponsiveUtils.getIconSize(context, 24), 
            color: color,
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                  color: const Color(0xFF6C757D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 20),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}