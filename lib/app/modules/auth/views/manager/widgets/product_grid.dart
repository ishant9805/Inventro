import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'product_detail_dialog.dart';

class ProductGrid extends StatelessWidget {
  final DashboardController dashboardController;

  const ProductGrid({
    super.key,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(210),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your Products',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              Obx(() => dashboardController.isLoading.value 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF4A00E0)),
                      tooltip: 'Refresh Inventories',
                      onPressed: dashboardController.refreshProducts,
                    ),
                  ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          Obx(() {
            // Show loading spinner for initial load
            if (dashboardController.isLoading.value && dashboardController.products.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A00E0)),
                  ),
                ),
              );
            }
            
            // Show error state with retry option
            if (dashboardController.hasError.value && dashboardController.products.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to Load Products',
                      style: TextStyle(fontSize: 18, color: Colors.red[600], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dashboardController.errorMessage.value.isNotEmpty 
                        ? dashboardController.errorMessage.value
                        : 'Unable to connect to server. Please check your internet connection.',
                      style: TextStyle(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: dashboardController.retryFetch,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A00E0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          onPressed: dashboardController.testBackendConnection,
                          icon: const Icon(Icons.network_check),
                          label: const Text('Test Connection'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF4A00E0),
                            side: const BorderSide(color: Color(0xFF4A00E0)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }
            
            // Show empty state when no products but no error
            if (dashboardController.products.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first product to get started',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: dashboardController.refreshProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A00E0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Show products list
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
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(30),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () => _showProductDetails(context, product),
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
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
                                      fontSize: 18,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: const TextStyle(color: Color(0xFF6C757D), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              decoration: BoxDecoration(
                                color: isLowStock 
                                  ? const Color(0xFFFFC107).withOpacity(0.2)
                                  : const Color(0xFF4A00E0).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isLowStock 
                                    ? const Color(0xFFFFC107)
                                    : const Color(0xFF4A00E0),
                                ),
                              ),
                              child: Text(
                                'Qty: ${product.quantity}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isLowStock 
                                    ? const Color(0xFFFFC107)
                                    : const Color(0xFF4A00E0),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Location: ${product.location}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                              const Spacer(),
                              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                'Expires: ${product.formattedExpiryDate}',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        if (isExpired || isExpiringSoon) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isExpired ? Icons.error : Icons.warning,
                                  color: statusColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isExpired 
                                    ? 'EXPIRED'
                                    : 'Expires in ${product.daysUntilExpiry} days',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showProductDetails(BuildContext context, product) {
    Get.dialog(
      ProductDetailDialog(
        product: product,
        controller: dashboardController,
      ),
    );
  }
}