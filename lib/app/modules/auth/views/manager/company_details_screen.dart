import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';

class CompanyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> companyData;
  final int employeeCount;

  const CompanyDetailsScreen({
    super.key,
    required this.companyData,
    required this.employeeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Company Name: ${companyData['name'] ?? '-'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Company ID: ${companyData['id'] ?? '-'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Company Size: ${companyData['size'] ?? '-'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.dashboard);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A00E0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('OK', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
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
