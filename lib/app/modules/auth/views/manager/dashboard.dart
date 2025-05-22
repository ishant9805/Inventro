import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  // Mock data for products/inventory
  List<Map<String, String>> get mockProducts => [
        {
          'name': 'Spare Part A',
          'category': 'Mechanical',
          'quantity': '12',
          'location': 'Hangar 1',
        },
        {
          'name': 'Tool Kit B',
          'category': 'Electrical',
          'quantity': '5',
          'location': 'Workshop',
        },
        {
          'name': 'Fire Extinguisher',
          'category': 'Safety',
          'quantity': '20',
          'location': 'Terminal',
        },
      ];

  @override
  Widget build(BuildContext context) {
    // Get access to the AuthController
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red,),
            onPressed: () {
              // Show confirmation dialog
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
                        // Call the logout method from AuthController
                        Get.find<AuthController>().logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Obx(() => Text(
              'Welcome, ${authController.user.value?.name ?? "Manager"}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            )),
            const SizedBox(height: 20),

            // Action Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Add Product', 'Add Product UI coming soon!');
                  },
                  icon: const Icon(Icons.add_box),
                  label: const Text('Add Product'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Employees', 'Manage Employees UI coming soon!');
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Employees'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Assign Task', 'Assign Task UI coming soon!');
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Assign Task'),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Inventory/Product List Header
            const Text(
              'Inventory List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Inventory/Product List
            Expanded(
              child: ListView.builder(
                itemCount: mockProducts.length,
                itemBuilder: (context, index) {
                  final product = mockProducts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(product['name'] ?? ''),
                      subtitle: Text(
                        'Category: ${product['category']}\n'
                        'Location: ${product['location']}',
                      ),
                      trailing: Text(
                        'Qty: ${product['quantity']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Get.snackbar('Product', 'Product details coming soon!');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
