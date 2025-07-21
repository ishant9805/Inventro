import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/services/company_service.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

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
                      if (isNewCompany) ...[
                        // For new company - show company details and disable company ID field
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Company Created Successfully',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (companyData != null) ...[
                                Text('Company Name: ${companyData!['name'] ?? '-'}'),
                                Text('Company ID: ${companyData!['id'] ?? '-'}'),
                                Text('Company Size: ${companyData!['size'] ?? '-'} employees'),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ] else ...[
                        // For existing company - show company ID input and validation
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: companyIdController,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.business),
                                  labelText: 'Company ID',
                                  hintText: 'Enter company ID to join',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(16)),
                                  ),
                                ),
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Company ID is required';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: isLoadingCompany ? null : _validateCompanyId,
                                icon: isLoadingCompany
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.search, size: 18),
                                label: const Text('Validate'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A00E0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Company validation results
                        if (companyError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    companyError!,
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],

                        if (companyData != null && isCompanyValidated) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Company Validated',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Company Name: ${companyData!['name'] ?? '-'}'),
                                Text('Company Size: ${companyData!['size'] ?? '-'} employees'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ],

                      // Manager Details
                      TextFormField(
                        controller: authController.nameController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          labelText: 'Full Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: authController.emailController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email_outlined),
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: authController.passwordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      TextFormField(
                        controller: authController.confirmPasswordController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                          ),
                        ),
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value != authController.passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Register Button
                      Obx(() => ElevatedButton(
                        onPressed: authController.isLoading.value || (!isCompanyValidated && !isNewCompany)
                            ? null
                            : _registerManager,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: const Color(0xFF4A00E0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                        child: authController.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Register as Manager',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      )),
                      const SizedBox(height: 16),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? "),
                          GestureDetector(
                            onTap: () {
                              authController.clearTextControllers();
                              Get.offAllNamed(AppRoutes.login);
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Color(0xFF4A00E0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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