import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/employee_dashboard_controller.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final EmployeeDashboardController controller = Get.put(EmployeeDashboardController());
    const List<Color> baseColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withAlpha(170)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: 'Logout',
            onPressed: controller.logout,
          ),
        ],
      ),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Product List',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: controller.products.length,
                      itemBuilder: (context, index) {
                        final product = controller.products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(product.partNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Description: ${product.description}'),
                                Text('Location: ${product.location}'),
                                Text('Batch: ${product.batchNumber}'),
                                Text('Expires: ${product.formattedExpiryDate}'),
                              ],
                            ),
                            trailing: Text('Qty: ${product.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
