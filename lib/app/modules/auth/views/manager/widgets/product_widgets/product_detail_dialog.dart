import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';
import 'package:inventro/app/routes/app_routes.dart';
import 'package:inventro/app/utils/responsive_utils.dart';
import 'package:inventro/app/utils/safe_navigation.dart';

class ProductDetailDialog extends StatelessWidget {
  final dynamic product;
  final DashboardController controller;

  const ProductDetailDialog({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 20)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = ResponsiveUtils.isSmallScreen(context) 
            ? ResponsiveUtils.screenWidth(context) * 0.95 
            : 400.0;
          final maxHeight = ResponsiveUtils.screenHeight(context) * 0.85;
          
          return Container(
            constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 20)),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFAFAFA),
                  Color(0xFFF5F5F5),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(context),
                
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status Badge
                        _buildStatusBadge(context),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, 20)),

                        // Product Info Cards
                        _buildInfoCard(
                          context,
                          'Basic Information',
                          Icons.info_outline,
                          [
                            _buildDetailItem(context, 'Product ID', _safeString(product.id ?? '-'), Icons.tag),
                            _buildDetailItem(context, 'Part Number', _safeString(product.partNumber), Icons.qr_code),
                            _buildDetailItem(context, 'Description', _safeString(product.description), Icons.description),
                            _buildDetailItem(context, 'Batch Number', _safeString(product.batchNumber), Icons.batch_prediction),
                          ],
                        ),

                        SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),

                        _buildInfoCard(
                          context,
                          'Inventory Details',
                          Icons.warehouse,
                          [
                            _buildDetailItem(context, 'Location', _safeString(product.location), Icons.location_on),
                            _buildDetailItem(context, 'Quantity', '${_safeString(product.quantity)} units', Icons.inventory),
                            _buildDetailItem(context, 'Expiry Date', _safeString(product.formattedExpiryDate ?? product.expiryDate), Icons.schedule),
                          ],
                        ),

                        if (product.createdAt != null || product.updatedAt != null) ...[
                          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
                          _buildInfoCard(
                            context,
                            'Timeline',
                            Icons.history,
                            [
                              if (product.createdAt != null)
                                _buildDetailItem(context, 'Date Added', product.formattedCreatedAt, Icons.add_circle_outline),
                              if (product.updatedAt != null)
                                _buildDetailItem(context, 'Last Updated', _formatDateTime(_safeString(product.updatedAt)), Icons.update),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Actions
                _buildActions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF00C3FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUtils.getSpacing(context, 20)),
          topRight: Radius.circular(ResponsiveUtils.getSpacing(context, 20)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
            ),
            child: Icon(
              Icons.inventory_2,
              color: Colors.white,
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Product Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ResponsiveUtils.getFontSize(context, 20),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _safeString(product.partNumber),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => SafeNavigation.safeBack(),
            icon: Icon(
              Icons.close, 
              color: Colors.white,
              size: ResponsiveUtils.getIconSize(context, 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color statusColor = _getStatusColor();
    IconData statusIcon = _getStatusIcon();
    String statusText = _getStatusText();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getPadding(context, factor: 0.04),
        vertical: ResponsiveUtils.getSpacing(context, 12),
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon, 
            color: statusColor, 
            size: ResponsiveUtils.getIconSize(context, 20),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
          Expanded(
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, 14),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getSpacing(context, 8),
              vertical: ResponsiveUtils.getSpacing(context, 4),
            ),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
            ),
            child: Text(
              _getQuantity() <= 10 ? 'LOW STOCK' : 'IN STOCK',
              style: TextStyle(
                color: Colors.white,
                fontSize: ResponsiveUtils.getFontSize(context, 10),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ));
  }

  Widget _buildInfoCard(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.04)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUtils.getSpacing(context, 8),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 8)),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4A00E0),
                  size: ResponsiveUtils.getIconSize(context, 16),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 16)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUtils.getSpacing(context, 12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: ResponsiveUtils.getIconSize(context, 16),
            color: const Color(0xFF6C757D),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 12),
                    color: const Color(0xFF6C757D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.getSpacing(context, 2)),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, 14),
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.getPadding(context, factor: 0.06)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (ResponsiveUtils.isSmallScreen(context)) {
            // Stack buttons vertically on small screens
            return _buildVerticalActions(context);
          } else {
            // Keep horizontal layout for larger screens
            return _buildHorizontalActions(context);
          }
        },
      ),
    );
  }

  Widget _buildHorizontalActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => SafeNavigation.safeBack(),
            icon: Icon(Icons.close, size: ResponsiveUtils.getIconSize(context, 18)),
            label: Text('Close', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C757D),
              side: const BorderSide(color: Color(0xFF6C757D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
              ),
              padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 12)),
            ),
          ),
        ),
        if (product.id != null) ...[
          SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _navigateToEdit(),
              icon: Icon(Icons.edit, color: Colors.white, size: ResponsiveUtils.getIconSize(context, 18)),
              label: Text(
                'Edit',
                style: TextStyle(color: Colors.white, fontSize: ResponsiveUtils.getFontSize(context, 14)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A00E0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                ),
                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 12)),
              ),
            ),
          ),
          SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showDeleteConfirmation(context),
              icon: Icon(Icons.delete, color: Colors.white, size: ResponsiveUtils.getIconSize(context, 18)),
              label: Text(
                'Delete',
                style: TextStyle(color: Colors.white, fontSize: ResponsiveUtils.getFontSize(context, 14)),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                ),
                padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 12)),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerticalActions(BuildContext context) {
    return Column(
      children: [
        if (product.id != null) ...[
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToEdit(),
                  icon: Icon(Icons.edit, color: Colors.white, size: ResponsiveUtils.getIconSize(context, 18)),
                  label: Text(
                    'Edit Product',
                    style: TextStyle(color: Colors.white, fontSize: ResponsiveUtils.getFontSize(context, 14)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A00E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 14)),
                  ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 12)),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmation(context),
                  icon: Icon(Icons.delete, color: Colors.white, size: ResponsiveUtils.getIconSize(context, 18)),
                  label: Text(
                    'Delete',
                    style: TextStyle(color: Colors.white, fontSize: ResponsiveUtils.getFontSize(context, 14)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 14)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => SafeNavigation.safeBack(),
            icon: Icon(Icons.close, size: ResponsiveUtils.getIconSize(context, 18)),
            label: Text('Close', style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14))),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C757D),
              side: const BorderSide(color: Color(0xFF6C757D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 12)),
              ),
              padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.getSpacing(context, 14)),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Store product data before closing dialog
    final productData = product;
    final productId = product.id;
    
    // Close the detail dialog first
    Get.back();
    
    // Use a delay to ensure the dialog is fully closed before showing confirmation
    Future.delayed(const Duration(milliseconds: 200), () {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 16)),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange[600], size: ResponsiveUtils.getIconSize(context, 24)),
              SizedBox(width: ResponsiveUtils.getSpacing(context, 8)),
              Expanded(
                child: Text(
                  'Confirm Delete',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: ResponsiveUtils.getFontSize(context, 18),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete this product?',
                style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 14)),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 12)),
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, 12)),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product: ${_safeString(productData.partNumber)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveUtils.getFontSize(context, 14),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Description: ${_safeString(productData.description)}',
                      style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 12)),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Quantity: ${_safeString(productData.quantity)}',
                      style: TextStyle(fontSize: ResponsiveUtils.getFontSize(context, 12)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, 8)),
              Text(
                'This action cannot be undone.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: ResponsiveUtils.getFontSize(context, 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF6C757D),
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back(); // Close confirmation dialog
                controller.deleteProduct(productId); // Perform deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getSpacing(context, 8)),
                ),
              ),
              child: Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.getFontSize(context, 14),
                ),
              ),
            ),
          ],
        ),
        barrierDismissible: false, // Prevent accidental dismissal
      );
    });
  }

  void _navigateToEdit() {
    // Check if context is still valid before navigation
    if (!Get.isDialogOpen!) return;
    
    // Store the product data before closing dialog
    final productData = product;
    
    // Close the dialog first with a longer delay to ensure cleanup
    Get.back();
    
    // Use a longer delay to ensure the dialog is fully closed and navigation stack is stable
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        // Navigate to the edit page with product data using proper route
        Get.toNamed(AppRoutes.editProduct, arguments: productData);
        print('✅ Navigating to edit product with data: ${productData.partNumber}');
      } catch (e) {
        print('❌ Error navigating to edit product: $e');
        SafeNavigation.safeSnackbar(
          title: 'Navigation Error',
          message: 'Failed to open edit screen. Please try again.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red[800],
        );
      }
    });
  }

  // Helper method to safely convert any value to string
  static String _safeString(dynamic value) {
    if (value == null) return '-';
    return value.toString();
  }

  // Helper method to safely get quantity as int
  int _getQuantity() {
    try {
      if (product.quantity is int) return product.quantity;
      if (product.quantity is String) return int.tryParse(product.quantity) ?? 0;
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Helper method to safely get days until expiry
  int _getDaysUntilExpiry() {
    try {
      if (product.daysUntilExpiry != null) {
        if (product.daysUntilExpiry is int) return product.daysUntilExpiry;
        if (product.daysUntilExpiry is String) return int.tryParse(product.daysUntilExpiry) ?? 999;
      }
      
      // Fallback: calculate from expiry date
      String? expiryDate = product.expiryDate ?? product.formattedExpiryDate;
      if (expiryDate != null && expiryDate != '-') {
        try {
          DateTime expiry = DateTime.parse(expiryDate);
          return expiry.difference(DateTime.now()).inDays;
        } catch (e) {
          return 999;
        }
      }
      return 999;
    } catch (e) {
      return 999;
    }
  }

  // Helper method to safely check if expired
  bool _isExpired() {
    try {
      if (product.isExpired != null) return product.isExpired;
      return _getDaysUntilExpiry() < 0;
    } catch (e) {
      return false;
    }
  }

  Color _getStatusColor() {
    if (_isExpired()) return const Color(0xFFDC3545); // Red for expired
    if (_getDaysUntilExpiry() <= 7 && _getDaysUntilExpiry() >= 0) return const Color(0xFFFFC107); // Amber for expiring within 7 days
    if (_getQuantity() <= 1) return const Color(0xFF800020); // Dark red for low stock (≤1)
    return const Color(0xFF28A745); // Green for good condition
  }

  IconData _getStatusIcon() {
    if (_isExpired()) return Icons.error;
    if (_getDaysUntilExpiry() <= 7 && _getDaysUntilExpiry() >= 0) return Icons.warning;
    if (_getQuantity() <= 1) return Icons.warning;
    return Icons.check_circle;
  }

  String _getStatusText() {
    if (_isExpired()) return 'EXPIRED';
    int daysUntilExpiry = _getDaysUntilExpiry();
    if (daysUntilExpiry <= 7 && daysUntilExpiry >= 0) return 'Expires in $daysUntilExpiry days';
    if (_getQuantity() <= 1) return 'Low Stock';
    return 'Good Condition';
  }

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty || dateTimeStr == '-') return '-';
    try {
      final dt = DateTime.parse(dateTimeStr).toLocal();
      final date = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
      final time = "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      return "$date at $time";
    } catch (e) {
      return dateTimeStr;
    }
  }
}