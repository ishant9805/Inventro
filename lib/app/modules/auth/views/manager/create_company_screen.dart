import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/services/company_service.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/safe_navigation.dart';
import 'widgets/company_widgets/company_creation_app_bar.dart';
import 'widgets/company_widgets/company_creation_header.dart';
import 'widgets/company_widgets/company_creation_input_field.dart';
import 'widgets/company_widgets/company_creation_error_message.dart';
import 'widgets/company_widgets/company_creation_button.dart';

class CreateCompanyScreen extends StatefulWidget {
  const CreateCompanyScreen({super.key});

  @override
  State<CreateCompanyScreen> createState() => _CreateCompanyScreenState();
}

class _CreateCompanyScreenState extends State<CreateCompanyScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final CompanyService _companyService = CompanyService();
  bool isLoading = false;
  String? errorMessage;

  late AnimationController _buttonAnimationController;
  late Animation<double> _scaleAnimation;

  // Gradient colors matching app theme
  static const List<Color> gradientColors = [
    Color(0xFF4A00E0),
    Color(0xFF00C3FF),
    Color(0xFF8F00FF),
  ];

  @override
  void initState() {
    super.initState();
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    nameController.dispose();
    sizeController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) return;

    _buttonAnimationController.forward().then((_) {
      _buttonAnimationController.reverse();
    });

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final name = nameController.text.trim();
      final size = int.tryParse(sizeController.text.trim()) ?? 0;

      final result = await _companyService.createCompany(name: name, size: size);

      if (result != null && result['id'] != null) {
        // Success: Navigate to manager registration with companyId
        Get.offAllNamed(AppRoutes.managerRegistration, arguments: {
          'companyId': result['id'].toString(),
          'companyData': result,
          'isNewCompany': true,
        });
      } else {
        setState(() {
          errorMessage = 'Failed to create company. Please try again.';
        });
      }
    } catch (e) {
      // Handle backend 422 errors or other exceptions
      final msg = e.toString();
      setState(() {
        if (msg.contains('already exists')) {
          errorMessage = msg.replaceAll('Exception:', '').trim();
        } else {
          errorMessage = 'Error: $msg';
        }
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
                  title: 'Create Company',
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
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Header Section
                              CompanyCreationHeader(gradientColors: gradientColors),
                              const SizedBox(height: 40),

                              // Company Name Field
                              CompanyCreationInputField(
                                controller: nameController,
                                label: 'Company Name',
                                hint: 'Enter your unique company name',
                                icon: Icons.business_outlined,
                                gradientColors: gradientColors,
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Company name is required';
                                  }
                                  if (val.trim().toLowerCase() == 'new company') {
                                    return 'Please choose a unique name';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 24),

                              // Company Size Field
                              CompanyCreationInputField(
                                controller: sizeController,
                                label: 'Company Size',
                                hint: 'Number of employees (optional)',
                                icon: Icons.people_outline,
                                gradientColors: gradientColors,
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(height: 32),

                              // Error Message
                              if (errorMessage != null) ...[
                                CompanyCreationErrorMessage(errorMessage: errorMessage!),
                                const SizedBox(height: 24),
                              ],

                              // Create Button
                              CompanyCreationButton(
                                isLoading: isLoading,
                                onPressed: _createCompany,
                                text: 'Create Company',
                                gradientColors: gradientColors,
                                scaleAnimation: _scaleAnimation,
                              ),

                              const SizedBox(height: 32),

                              // Footer
                              Center(
                                child: Text(
                                  'By creating a company, you agree to our Terms of Service',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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