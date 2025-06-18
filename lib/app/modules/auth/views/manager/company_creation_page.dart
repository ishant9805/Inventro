import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/services/company_service.dart';
import 'package:inventro/app/routes/app_routes.dart';

class CompanyCreationPage extends StatefulWidget {
  const CompanyCreationPage({super.key});

  @override
  State<CompanyCreationPage> createState() => _CompanyCreationPageState();
}

class _CompanyCreationPageState extends State<CompanyCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final CompanyService _companyService = CompanyService();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    nameController.dispose();
    sizeController.dispose();
    super.dispose();
  }

  Future<void> _createCompany() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final name = nameController.text.trim();
      final size = int.tryParse(sizeController.text.trim()) ?? 0;
      final result = await _companyService.createCompany(name: name, size: size);
      if (result != null && result['id'] != null) {
        // Success: Go to manager registration with companyId
        Get.offAllNamed(AppRoutes.register, arguments: {'companyId': result['id'].toString(), 'companyData': result});
      } else {
        setState(() {
          errorMessage = 'Unknown error. Please try again.';
        });
      }
    } catch (e) {
      // Try to parse backend 422 error
      final msg = e.toString();
      if (msg.contains('already exists')) {
        setState(() {
          errorMessage = msg.replaceAll('Exception:', '').trim();
        });
      } else {
        setState(() {
          errorMessage = 'Error: $msg';
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Company'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Company Name', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter unique company name',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Company name is required';
                      if (val.trim().toLowerCase() == 'new company') return 'Please choose a unique name';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Company Size'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: sizeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Number of employees',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null) ...[
                    Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                  ],
                  ElevatedButton(
                    onPressed: isLoading ? null : _createCompany,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: const Color(0xFF4A00E0),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Company', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
