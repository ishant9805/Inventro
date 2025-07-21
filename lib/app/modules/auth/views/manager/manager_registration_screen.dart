import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/services/company_service.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'widgets/shared_widgets/company_validation_status.dart';
import 'widgets/shared_widgets/company_id_input.dart';
import 'widgets/shared_widgets/manager_details_form.dart';
import 'widgets/shared_widgets/registration_actions.dart';

class ManagerRegistrationScreen extends StatefulWidget {
  const ManagerRegistrationScreen({super.key});

  @override
  State<ManagerRegistrationScreen> createState() => _ManagerRegistrationScreenState();
}

class _ManagerRegistrationScreenState extends State<ManagerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  final CompanyService _companyService = CompanyService();
  final TextEditingController companyIdController = TextEditingController();
  
  Map<String, dynamic>? companyData;
  bool isLoadingCompany = false;
  bool isCompanyValidated = false;
  String? companyError;
  bool isNewCompany = false;

  @override
  void initState() {
    super.initState();
    _handleArguments();
  }

  void _handleArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      // Check if this is from company creation flow
      if (args['isNewCompany'] == true) {
        isNewCompany = true;
        companyData = args['companyData'];
        companyIdController.text = args['companyId'] ?? '';
        isCompanyValidated = true;
      } else if (args['companyId'] != null) {
        // Existing company flow with pre-filled companyId
        companyIdController.text = args['companyId'];
      }
    }
  }

  Future<void> _validateCompanyId() async {
    if (companyIdController.text.trim().isEmpty) {
      setState(() {
        companyError = 'Please enter a company ID';
      });
      return;
    }

    setState(() {
      isLoadingCompany = true;
      companyError = null;
      companyData = null;
      isCompanyValidated = false;
    });

    try {
      final company = await _companyService.getCompanyById(companyIdController.text.trim());
      if (company != null && company['id'] != null) {
        setState(() {
          companyData = company;
          isCompanyValidated = true;
          companyError = null;
        });
        Get.snackbar(
          'Success', 
          'Company found: ${company['name']}',
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
        );
      } else {
        setState(() {
          companyError = 'Company not found. Please check the company ID.';
        });
      }
    } catch (e) {
      setState(() {
        companyError = 'Error validating company: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingCompany = false;
      });
    }
  }

  Future<void> _registerManager() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (!isCompanyValidated) {
      Get.snackbar('Error', 'Please validate the company ID first');
      return;
    }

    await authController.registerManager(companyId: companyIdController.text.trim());
  }

  @override
  void dispose() {
    companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> baseColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withAlpha(170)).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () {
              Get.offAllNamed(AppRoutes.roleSelection);
            },
            tooltip: "Back to Role Selection",
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: lightColors,
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(210),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(50),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isNewCompany ? 'Complete Registration' : 'Manager Registration',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Company ID Section
                      if (!isNewCompany) ...[
                        CompanyIdInput(
                          controller: companyIdController,
                          isLoading: isLoadingCompany,
                          onValidate: _validateCompanyId,
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Company Validation Status
                      CompanyValidationStatus(
                        isNewCompany: isNewCompany,
                        companyData: companyData,
                        companyError: companyError,
                        isCompanyValidated: isCompanyValidated,
                      ),
                      
                      if ((companyData != null && isCompanyValidated) || isNewCompany) ...[
                        const SizedBox(height: 20),
                      ],

                      // Manager Details Form
                      ManagerDetailsForm(authController: authController),
                      const SizedBox(height: 24),

                      // Registration Actions
                      RegistrationActions(
                        authController: authController,
                        isCompanyValidated: isCompanyValidated,
                        isNewCompany: isNewCompany,
                        onRegister: _registerManager,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}