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
          // Replace grid/row layout with stacked list layout
          _buildStackedListLayout(context),
        ],
      ),
    );
  }

  /// Builds a vertical stacked list of cards, each taking full width
  Widget _buildStackedListLayout(BuildContext context) {
    return Obx(() => Column(
      children: [
        // Total Products Card
        _buildStatCard(
          context: context,
          title: 'Total Products',
          value: '${dashboardController.products.length}',
          icon: Icons.inventory,
          color: const Color(0xFF4A00E0),
          isFullWidth: true,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
        
        // Low Stock Card
        _buildStatCard(
          context: context,
          title: 'Low Stock',
          value: '${dashboardController.lowStockProducts.length}',
          icon: Icons.warning,
          color: const Color(0xFF800020),
          isFullWidth: true,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
        
        // Expiring Soon Card
        _buildStatCard(
          context: context,
          title: 'Expiring Soon',
          value: '${dashboardController.expiringProducts.length}',
          icon: Icons.schedule,
          color: const Color(0xFFFFC107), // Amber/Yellow for warning
          isFullWidth: true,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
        
        // Expired Card
        _buildStatCard(
          context: context,
          title: 'Expired',
          value: '${dashboardController.expiredProducts.length}',
          icon: Icons.error,
          color: const Color(0xFFDC3545), // Red for expired
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
        factor: isFullWidth ? 0.05 : (isCompact ? 0.04 : 0.05));
    
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
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 16)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          ),
          child: Icon(
            icon, 
            size: ResponsiveUtils.getIconSize(context, 28), 
            color: color,
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 20)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 16),
                  color: const Color(0xFF6C757D),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 6)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        // Optional: Add a subtle arrow or indicator for better list UI
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 8)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
          ),
          child: Icon(
            Icons.analytics_outlined,
            size: ResponsiveUtils.getIconSize(context, 20),
            color: color.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}