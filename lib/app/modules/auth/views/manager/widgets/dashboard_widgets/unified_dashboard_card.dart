import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/responsive_utils.dart';

class UnifiedDashboardCard extends StatelessWidget {
  final AuthController authController;

  const UnifiedDashboardCard({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: ResponsiveUtils.getSpacing(context, 16),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content with padding
          Padding(
            padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Logo and app name (without action buttons)
                _buildHeaderContent(context),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),
                
                // Middle row: Dashboard title
                _buildDashboardTitle(context),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                
                // Bottom row: Welcome message and company info
                _buildWelcomeSection(context),
              ],
            ),
          ),
          
          // Profile button positioned to align with header content
          Positioned(
            top: ResponsiveUtils.getPadding(context, factor: 0.06), // Same as main content padding
            right: ResponsiveUtils.getSpacing(context, 12),
            child: _buildProfileButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderContent(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    
    return Row(
      children: [
        // App Logo/Icon
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.03)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF00C3FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4A00E0).withAlpha(76),
                blurRadius: ResponsiveUtils.getSpacing(context, 8),
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.inventory_2,
            color: Colors.white,
            size: ResponsiveUtils.getIconSize(context, 24),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
        
        // App Name - Flexible to prevent overflow, but leave space for profile button
        Expanded(
          child: Padding(
            // Add right padding to ensure text doesn't overlap with profile button
            padding: EdgeInsets.only(
              right: ResponsiveUtils.getSpacing(context, isSmallScreen ? 60 : 50),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Inventro',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: isSmallScreen ? 0.8 : 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileButton(BuildContext context) {
    // Always show just the profile button, no logout on dashboard
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: ResponsiveUtils.getSpacing(context, 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => Get.toNamed(AppRoutes.managerProfile),
        icon: Icon(
          Icons.person,
          color: const Color(0xFF4A00E0),
          size: ResponsiveUtils.getIconSize(context, 24),
        ),
        tooltip: "Profile",
        constraints: BoxConstraints(
          minWidth: ResponsiveUtils.getSpacing(context, 36),
          minHeight: ResponsiveUtils.getSpacing(context, 36),
        ),
      ),
    );
  }

  Widget _buildDashboardTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.025)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A00E0), Color(0xFF8F00FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
          ),
          child: Icon(
            Icons.dashboard_outlined,
            color: Colors.white,
            size: ResponsiveUtils.getIconSize(context, 20),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Manager Dashboard',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 20),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A202C),
                letterSpacing: ResponsiveUtils.isSmallScreen(context) ? 0.3 : 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome message
        Obx(() => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Welcome, ${authController.user.value?.name ?? "Manager"}!',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, 18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF374151),
            ),
          ),
        )),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
        
        // Company information
        Obx(() => _buildCompanyInfo(context)),
      ],
    );
  }

  Widget _buildCompanyInfo(BuildContext context) {
    final hasCompany = authController.user.value?.company != null;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getPadding(context, factor: 0.04),
        vertical: ResponsiveUtils.getSpacing(context, 12),
      ),
      decoration: BoxDecoration(
        color: hasCompany 
          ? const Color(0xFF4A00E0).withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
        border: Border.all(
          color: hasCompany 
            ? const Color(0xFF4A00E0).withOpacity(0.3)
            : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasCompany ? Icons.business : Icons.warning_amber,
            color: hasCompany ? const Color(0xFF4A00E0) : Colors.orange.shade600,
            size: ResponsiveUtils.getIconSize(context, 18),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
          Flexible(
            child: Text(
              hasCompany 
                ? 'Company: ${authController.user.value!.company!.name}'
                : 'Company information not available',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, 15),
                color: hasCompany ? const Color(0xFF4A00E0) : Colors.orange,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}