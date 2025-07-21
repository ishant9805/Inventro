import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import '../../controller/auth_controller.dart';
import 'widgets/company_widgets/company_creation_app_bar.dart';
import 'widgets/profile_widgets/profile_header.dart';
import 'widgets/profile_widgets/personal_info_card.dart';
import 'widgets/profile_widgets/company_info_card.dart';
import 'widgets/profile_widgets/account_actions_card.dart';

class ManagerProfileScreen extends StatefulWidget {
  const ManagerProfileScreen({super.key});

  @override
  State<ManagerProfileScreen> createState() => _ManagerProfileScreenState();
}

class _ManagerProfileScreenState extends State<ManagerProfileScreen> {
  final AuthController authController = Get.find<AuthController>();

  // Modern gradient colors matching other screens
  static const List<Color> gradientColors = [
    Color(0xFF4A00E0),
    Color(0xFF00C3FF),
    Color(0xFF8F00FF),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                CompanyCreationAppBar(
                  title: 'Profile',
                  onBackPressed: () => SafeNavigation.safeBack(),
                ),
                
                // Main Content
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          // Profile Header
                          ProfileHeader(gradientColors: gradientColors),
                          const SizedBox(height: 32),
                          
                          // Personal Information Card
                          PersonalInfoCard(authController: authController),
                          const SizedBox(height: 24),
                          
                          // Company Information Card
                          CompanyInfoCard(authController: authController),
                          const SizedBox(height: 24),
                          
                          // Account Actions Card
                          AccountActionsCard(authController: authController),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}