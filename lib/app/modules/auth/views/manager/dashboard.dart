import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';
//import '../../../../routes/app_routes.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Get access to the AuthController
    final AuthController authController = Get.find<AuthController>();
    // Initialize DashboardController
    final DashboardController dashboardController = Get.put(DashboardController());
    
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
            icon: const Icon(Icons.account_circle, color: Colors.deepPurple),
            onPressed: () => Get.toNamed('/manager-profile'),
            tooltip: "Profile",
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
                        onTap: () => Get.toNamed(AppRoutes.addEmployee),
                      ),
                      const SizedBox(width: 12),
                      _SmallDashboardButton(
                        icon: Icons.people,
                        label: 'Employees',
                        color: Colors.blueAccent,
                        onTap: () => Get.toNamed(AppRoutes.employeeList),
                        
                      ),
                      const SizedBox(width: 12),
                      _SmallDashboardButton(
                        icon: Icons.add_box,
                        label: 'Add Product',
                        color: Colors.green,
                        onTap: () => Get.toNamed(AppRoutes.addProduct),
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
                
                // Product Statistics Cards
                Obx(() => Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Products',
                        value: '${dashboardController.products.length}',
                        icon: Icons.inventory,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Low Stock',
                        value: '${dashboardController.lowStockProducts.length}',
                        icon: Icons.warning,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Expiring Soon',
                        value: '${dashboardController.expiringProducts.length}',
                        icon: Icons.schedule,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )),
                
                const SizedBox(height: 24),
                
                // Inventory/Product List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Inventory List',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Obx(() => dashboardController.isLoading.value 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Product List
                Obx(() {
                  if (dashboardController.isLoading.value && dashboardController.products.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  
                  if (dashboardController.products.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No products found',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Add your first product to get started',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: dashboardController.products.length,
                    itemBuilder: (context, index) {
                      final product = dashboardController.products[index];
                      final isExpired = product.isExpired;
                      final isLowStock = product.quantity <= 10;
                      final isExpiringSoon = product.daysUntilExpiry <= 30 && !isExpired;
                      
                      final now = DateTime.now();
                      final expiry = DateTime.tryParse(product.expiryDate);
                      Color borderColor;
                      if (expiry == null) {
                        borderColor = Colors.grey;
                      } else if (product.isExpired) {
                        borderColor = Colors.red;
                      } else if (expiry.difference(now).inDays <= 7) {
                        borderColor = Colors.yellow[700]!;
                      } else {
                        borderColor = Colors.green;
                      }
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border(
                            bottom: BorderSide(
                              color: borderColor,
                              width: 5.0,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFECE6FF),
                            child: Text(
                              product.partNumber.isNotEmpty 
                                ? product.partNumber.substring(0, 1).toUpperCase()
                                : 'P',
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            product.partNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${product.description}'),
                              Text('Location: ${product.location}'),
                              Text('Batch: ${product.batchNumber}'),
                              Text('Expires: ${product.formattedExpiryDate}'),
                              if (isExpired)
                                const Text(
                                  'EXPIRED',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else if (isExpiringSoon)
                                Text(
                                  'Expires in ${product.daysUntilExpiry} days',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLowStock 
                                    ? Colors.orange.withOpacity(0.1)
                                    : Colors.deepPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Qty: ${product.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLowStock ? Colors.orange[800] : Colors.deepPurple,
                                  ),
                                ),
                              ),
                              if (isLowStock)
                                const Text(
                                  'LOW STOCK',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          onTap: () {
                            // Show product details dialog
                            _showProductDetails(context, product, dashboardController);
                          },
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, product, DashboardController controller) {
    Get.dialog(
      AlertDialog(
        title: Text('Product Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product.id != null) Text('ID: ${product.id}'),
              Text('Part Number: ${product.partNumber}'),
              Text('Description: ${product.description}'),
              Text('Location: ${product.location}'),
              Text('Quantity: ${product.quantity}'),
              Text('Batch Number: ${product.batchNumber}'),
              Text('Expiry Date: ${product.formattedExpiryDate}'),
              if (product.createdAt != null) Text('Created At: ${product.createdAt}'),
              if (product.updatedAt != null) Text('Updated On: ' + _formatDateTime(product.updatedAt)),
              const SizedBox(height: 8),
              if (product.isExpired)
                const Text(
                  'Status: EXPIRED',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                )
              else if (product.daysUntilExpiry <= 30)
                Text(
                  'Status: Expires in ${product.daysUntilExpiry} days',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                )
              else
                const Text(
                  'Status: Good',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          if (product.id != null)
            TextButton(
              onPressed: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    title: const Text('Delete Product'),
                    content: Text('Are you sure you want to delete "${product.partNumber}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteProduct(product.id);
                        },
                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
        ],
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

// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper to format date/time for display
String _formatDateTime(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateTimeStr).toLocal(); // Convert to local (phone) time zone
    final date = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    final time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "$date at $time";
  } catch (e) {
    return dateTimeStr;
  }
}
