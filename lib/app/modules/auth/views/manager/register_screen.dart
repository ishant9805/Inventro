import 'package:inventro/app/data/services/company_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();
  final CompanyService _companyService = CompanyService();
  final TextEditingController companyIdController = TextEditingController();
  Map<String, dynamic>? companyData;
  bool isLoadingCompany = false;
  String? companyError;
  bool isCompanyValidated = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final String? companyIdArg = args != null ? args['companyId'] as String? : null;
    final bool isExistingCompany = companyIdArg != null;
    if (!isExistingCompany) {
      // Add New Company: create company and set companyId
      _createNewCompany();
    }
  }

  Future<void> _createNewCompany() async {
    setState(() {
      isLoadingCompany = true;
      companyError = null;
      isCompanyValidated = false;
    });
    try {
      // You can prompt for name/size, or use placeholders for now
      final company = await _companyService.createCompany(name: 'New Company', size: 1);
      if (company != null && company['id'] != null) {
        setState(() {
          companyData = company;
          companyIdController.text = company['id'].toString();
          isCompanyValidated = true;
        });
      } else {
        setState(() {
          companyError = 'Failed to create company.';
        });
      }
    } catch (e) {
      setState(() {
        companyError = 'Error creating company: \\${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingCompany = false;
      });
    }
  }

  Future<void> _validateCompanyId() async {
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
        });
      } else {
        setState(() {
          companyError = 'Invalid company ID.';
        });
      }
    } catch (e) {
      setState(() {
        companyError = 'Error validating company: \\${e.toString()}';
      });
    } finally {
      setState(() {
        isLoadingCompany = false;
      });
    }
  }

  @override
  void dispose() {
    companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String? companyIdArg = args != null ? args['companyId'] as String? : null;
    final Map<String, dynamic>? companyDataArg = args != null ? args['companyData'] as Map<String, dynamic>? : null;
    final bool isExistingCompany = companyIdArg != null && (companyDataArg == null);
    if (isExistingCompany && companyIdController.text.isEmpty && companyIdArg != null) {
      companyIdController.text = companyIdArg;
    }
    // If companyDataArg is present, use it for display and set companyId
    if (companyDataArg != null && companyIdController.text.isEmpty) {
      companyIdController.text = companyDataArg['id'].toString();
      companyData = companyDataArg;
      isCompanyValidated = true;
    }

    return Scaffold(
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
        color: Colors.white,
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
              child: ManagerRegistrationForm(
                isExistingCompany: isExistingCompany,
                companyIdController: companyIdController,
                companyData: companyDataArg ?? companyData,
                companyError: companyError,
                authController: authController,
                isLoadingCompany: isLoadingCompany,
                isCompanyValidated: isExistingCompany ? isCompanyValidated : true,
                onValidateCompany: _validateCompanyId,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ManagerRegistrationForm extends StatelessWidget {
  final bool isExistingCompany;
  final TextEditingController companyIdController;
  final Map<String, dynamic>? companyData;
  final String? companyError;
  final AuthController authController;
  final bool isLoadingCompany;
  final bool isCompanyValidated;
  final VoidCallback? onValidateCompany;

  const ManagerRegistrationForm({
    Key? key,
    required this.isExistingCompany,
    required this.companyIdController,
    required this.companyData,
    required this.companyError,
    required this.authController,
    this.isLoadingCompany = false,
    this.isCompanyValidated = false,
    this.onValidateCompany,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Manager Registration',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 22),
        if (isExistingCompany) ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: companyIdController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.business),
                    labelText: 'Company ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: true,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: isLoadingCompany ? null : onValidateCompany,
                child: isLoadingCompany
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Validate'),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ] else if (companyData != null) ...[
          // For new company, show uneditable company ID
          TextField(
            controller: companyIdController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.business),
              labelText: 'Company ID',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            enabled: false,
          ),
          const SizedBox(height: 10),
        ],
        if (companyData != null) ...[
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Name:  ${companyData!['name'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text('Company Size:  ${companyData!['size'] ?? '-'}'),
                  Text('Company ID:  ${companyData!['id'] ?? '-'}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (companyError != null) ...[
          Text(companyError!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: authController.nameController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            labelText: 'Full Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        TextField(
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
        ),
        const SizedBox(height: 14),
        TextField(
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
        ),
        const SizedBox(height: 14),
        TextField(
          controller: authController.confirmPasswordController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            labelText: 'Confirm Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed: authController.isLoading.value || !isCompanyValidated
                  ? null
                  : () => authController.registerManager(companyId: companyIdController.text.trim()),
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
                  : const Text('Register',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )
                  ),
            )),
        const SizedBox(height: 16),
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
    );
  }
}
