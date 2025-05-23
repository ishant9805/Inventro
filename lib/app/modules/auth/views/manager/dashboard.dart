import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/auth_controller.dart';
//import '../../../../routes/app_routes.dart';

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
    
    // Gradient colors for background
    const List<Color> baseColors = [
      Color(0xFF4A00E0),
      Color(0xFF00C3FF),
      Color(0xFF8F00FF),
    ];
    final List<Color> lightColors = baseColors.map((c) => c.withValues(alpha: 0.3)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
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
                        authController.logout();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Header Card
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() => Text(
                      'Welcome, ${authController.user.value?.name ?? "Manager"}!',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dashboard Actions Row (Horizontal Layout)
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                
                // Center-aligned row of equally sized buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SmallDashboardButton(
                        icon: Icons.person_add_alt_1,
                        label: 'Add Employee',
                        color: Colors.deepPurple,
                        onTap: () => Get.snackbar('Coming Soon', 'Add Employee feature coming soon!'),
                      ),
                      const SizedBox(width: 12),
                      _SmallDashboardButton(
                        icon: Icons.people,
                        label: 'Employees',
                        color: Colors.blueAccent,
                        onTap: () => Get.snackbar('Coming Soon', 'Employee feature coming soon!'),
                      ),
                      const SizedBox(width: 12),
                      _SmallDashboardButton(
                        icon: Icons.add_box,
                        label: 'Add Product',
                        color: Colors.green,
                        onTap: () => Get.snackbar('Coming Soon', 'Add Product feature coming soon!'),
                      ),
                      const SizedBox(width: 12),
                      _SmallDashboardButton(
                        icon: Icons.assignment,
                        label: 'Assign Task',
                        color: Colors.orange,
                        onTap: () => Get.snackbar('Coming Soon', 'Assign Task feature coming soon!'),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Inventory/Product List Header
                const Text(
                  'Inventory List',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                
                // Inventory/Product List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mockProducts.length,
                  itemBuilder: (context, index) {
                    final product = mockProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: const Border(
                          bottom: BorderSide(
                            color: Colors.red,
                            width: 5.0,
                          ),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFECE6FF),
                          child: Icon(Icons.inventory_2, color: Colors.deepPurple),
                        ),
                        title: Text(
                          product['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Category: ${product['category']}\nLocation: ${product['location']}',
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Qty: ${product['quantity']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                        onTap: () => Get.snackbar('Product', 'Product details coming soon!'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Reusable small dashboard button widget
class _SmallDashboardButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SmallDashboardButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 78,
          height: 78,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
