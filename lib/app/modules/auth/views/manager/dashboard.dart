import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/routes/app_routes.dart';
import '../../controller/auth_controller.dart';
import '../../controller/dashboard_controller.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final DashboardController dashboardController = Get.put(DashboardController());
    
    // More subtle gradient colors
    const List<Color> gradientColors = [
      Color(0xFFF8F9FA),
      Color(0xFFE9ECEF),
      Color(0xFFF1F3F4),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with logo and profile
                _buildHeader(authController),
                const SizedBox(height: 32),
                
                // Welcome Card
                _buildWelcomeCard(authController),
                const SizedBox(height: 32),
                
                // Quick Actions
                _buildQuickActions(),
                const SizedBox(height: 32),
                
                // Statistics Cards
                _buildStatisticsCards(dashboardController),
                const SizedBox(height: 32),
                
                // Inventory Section
                _buildInventorySection(dashboardController),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ));
  }

  Widget _buildWelcomeCard(AuthController authController) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF495057),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dashboard, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manager Dashboard',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6C757D),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Obx(() => Text(
                      'Welcome, ${authController.user.value?.name ?? "Manager"}!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.person_add_alt_1,
                label: 'Add Employee',
                color: const Color(0xFF495057),
                onTap: () => Get.toNamed(AppRoutes.addEmployee),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.people,
                label: 'Employees',
                color: const Color(0xFF6C757D),
                onTap: () => Get.toNamed(AppRoutes.employeeList),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.add_box,
                label: 'Add Product',
                color: const Color(0xFF28A745),
                onTap: () => Get.toNamed(AppRoutes.addProduct),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.assignment,
                label: 'Assign Task',
                color: const Color(0xFF17A2B8),
                onTap: () => Get.snackbar('Coming Soon', 'Assign Task feature coming soon!'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total Products',
                value: '${dashboardController.products.length}',
                icon: Icons.inventory,
                color: const Color(0xFF495057),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Low Stock',
                value: '${dashboardController.lowStockProducts.length}',
                icon: Icons.warning,
                color: const Color(0xFFFFC107),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Expiring Soon',
                value: '${dashboardController.expiringProducts.length}',
                icon: Icons.schedule,
                color: const Color(0xFFDC3545),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Inventory List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            const Spacer(),
            Obx(() => dashboardController.isLoading.value 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF495057)),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF495057)),
                    tooltip: 'Refresh Inventories',
                    onPressed: dashboardController.refreshProducts,
                  ),
                ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        Obx(() {
          if (dashboardController.isLoading.value && dashboardController.products.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF495057)),
                ),
              ),
            );
          }
          
          if (dashboardController.products.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
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
              Color statusColor;
              if (expiry == null) {
                statusColor = const Color(0xFF6C757D);
              } else if (product.isExpired) {
                statusColor = const Color(0xFFDC3545);
              } else if (expiry.difference(now).inDays <= 7) {
                statusColor = const Color(0xFFFFC107);
              } else {
                statusColor = const Color(0xFF28A745);
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showProductDetails(context, product, dashboardController),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                product.partNumber.isNotEmpty 
                                  ? product.partNumber.substring(0, 1).toUpperCase()
                                  : 'P',
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.partNumber,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${product.description}',
                                  style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
                                ),
                                Text(
                                  'Location: ${product.location}',
                                  style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
                                ),
                                Text(
                                  'Expires: ${product.formattedExpiryDate}',
                                  style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13),
                                ),
                                if (isExpired)
                                  const Text(
                                    'EXPIRED',
                                    style: TextStyle(
                                      color: Color(0xFFDC3545),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                else if (isExpiringSoon)
                                  Text(
                                    'Expires in ${product.daysUntilExpiry} days',
                                    style: const TextStyle(
                                      color: Color(0xFFFFC107),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isLowStock 
                                    ? const Color(0xFFFFC107).withValues(alpha: 0.2)
                                    : const Color(0xFF495057).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isLowStock 
                                      ? const Color(0xFFFFC107)
                                      : const Color(0xFF495057),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Qty: ${product.quantity}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isLowStock 
                                      ? const Color(0xFFFFC107)
                                      : const Color(0xFF495057),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              if (isLowStock)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text(
                                    'LOW STOCK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFFFFC107),
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
              );
            },
          );
        }),
      ],
    );
  }

  void _showProductDetails(BuildContext context, product, DashboardController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Color(0xFF2C3E50)),
        ),
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
              if (product.updatedAt != null) Text('Updated On: ${_formatDateTime(product.updatedAt)}'),
              const SizedBox(height: 8),
              if (product.isExpired)
                const Text(
                  'Status: EXPIRED',
                  style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.bold),
                )
              else if (product.daysUntilExpiry <= 30)
                Text(
                  'Status: Expires in ${product.daysUntilExpiry} days',
                  style: const TextStyle(color: Color(0xFFFFC107), fontWeight: FontWeight.bold),
                )
              else
                const Text(
                  'Status: Good',
                  style: TextStyle(color: Color(0xFF28A745), fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6C757D))),
          ),
          if (product.id != null)
            TextButton(
              onPressed: () {
                Get.back();
                Get.dialog(
                  AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    title: const Text('Delete Product'),
                    content: Text('Are you sure you want to delete "${product.partNumber}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel', style: TextStyle(color: Color(0xFF6C757D))),
                      ),
                      TextButton(
                        onPressed: () {
                          Get.back();
                          controller.deleteProduct(product.id);
                        },
                        child: const Text('Delete', style: TextStyle(color: Color(0xFFDC3545))),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Color(0xFFDC3545))),
            ),
        ],
      ),
    );
  }
}

String _formatDateTime(String? dateTimeStr) {
  if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
  try {
    final dt = DateTime.parse(dateTimeStr).toLocal();
    final date = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    final time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    return "$date at $time";
  } catch (e) {
    return dateTimeStr;
  }
}
