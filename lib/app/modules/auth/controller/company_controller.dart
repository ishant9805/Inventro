import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:inventro/app/data/services/company_service.dart';
import 'package:inventro/app/routes/app_routes.dart';

class CompanyController extends GetxController {
  final CompanyService _companyService = CompanyService();

  final TextEditingController companyIdController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();

  final Rxn<Map<String, dynamic>> companyData = Rxn<Map<String, dynamic>>();
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Fetch company by ID
  Future<void> fetchCompanyById() async {
    isLoading.value = true;
    error.value = '';
    companyData.value = null;
    final id = companyIdController.text.trim();
    final result = await _companyService.getCompanyById(id);
    if (result != null) {
      companyData.value = result;
    } else {
      error.value = 'Company not found.';
    }
    isLoading.value = false;
  }

  // Create new company
  Future<void> createCompany() async {
    isLoading.value = true;
    error.value = '';
    final name = nameController.text.trim();
    final size = int.tryParse(sizeController.text.trim()) ?? 0;
    final result = await _companyService.createCompany(name: name, size: size);
    if (result != null && result['id'] != null) {
      companyData.value = result;
      // Use WidgetsBinding to ensure navigation after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.isRegistered<CompanyController>()) {
          Get.toNamed(AppRoutes.register, arguments: {
            'companyId': result['id'].toString(),
            'companyData': result,
          });
        }
      });
    } else {
      error.value = 'Failed to create company.';
    }
    isLoading.value = false;
  }

  void clearFields() {
    companyIdController.clear();
    nameController.clear();
    sizeController.clear();
    companyData.value = null;
    error.value = '';
  }

  @override
  void onClose() {
    companyIdController.dispose();
    nameController.dispose();
    sizeController.dispose();
    super.onClose();
  }
}
