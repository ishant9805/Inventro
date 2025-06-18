import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/data/services/company_service.dart';
import '../../controller/auth_controller.dart';

class ManagerProfileScreen extends StatelessWidget {
  ManagerProfileScreen({super.key});

  final AuthController authController = Get.find<AuthController>();
  final CompanyService _companyService = CompanyService();

  Future<Widget> _buildCompanyInfo(int? companyId) async {
    if (companyId == null || companyId == 0) {
      return const Text('Company information not available.', style: TextStyle(fontSize: 16, color: Colors.red));
    }
    final company = await _companyService.getCompanyById(companyId.toString());
    if (company == null) {
      return const Text('Company information not available.', style: TextStyle(fontSize: 16, color: Colors.red));
    }
    return Column(
      children: [
        Text('Company ID: ${company['id']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text('Company Name: ${company['name']}', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, size: 48, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              user?.name ?? '-',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? '-',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            FutureBuilder<Widget>(
              future: user?.company != null
                  ? Future.value(Column(
                      children: [
                        Text('Company ID: ${user!.company!.id}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Company Name: ${user.company!.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ))
                  : Future.value(const Text('Company information not available.', style: TextStyle(fontSize: 16, color: Colors.red))),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return const Text('Error loading company info.', style: TextStyle(color: Colors.red));
                }
                return snapshot.data ?? const SizedBox();
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          authController.logout();
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
