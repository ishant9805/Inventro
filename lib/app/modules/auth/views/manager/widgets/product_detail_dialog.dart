import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/dashboard_controller.dart';

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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A00E0), Color(0xFF00C3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Product Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _safeString(product.partNumber),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Badge
                    _buildStatusBadge(),
                    const SizedBox(height: 20),

                    // Product Info Cards
                    _buildInfoCard(
                      'Basic Information',
                      Icons.info_outline,
                      [
                        _buildDetailItem('Product ID', _safeString(product.id ?? '-'), Icons.tag),
                        _buildDetailItem('Part Number', _safeString(product.partNumber), Icons.qr_code),
                        _buildDetailItem('Description', _safeString(product.description), Icons.description),
                        _buildDetailItem('Batch Number', _safeString(product.batchNumber), Icons.batch_prediction),
                      ],
                    ),

                    const SizedBox(height: 16),

                    _buildInfoCard(
                      'Inventory Details',
                      Icons.warehouse,
                      [
                        _buildDetailItem('Location', _safeString(product.location), Icons.location_on),
                        _buildDetailItem('Quantity', '${_safeString(product.quantity)} units', Icons.inventory),
                        _buildDetailItem('Expiry Date', _safeString(product.formattedExpiryDate ?? product.expiryDate), Icons.schedule),
                      ],
                    ),

                    if (product.createdAt != null || product.updatedAt != null) ...[
                      const SizedBox(height: 16),
                      _buildInfoCard(
                        'Timeline',
                        Icons.history,
                        [
                          if (product.createdAt != null)
                            _buildDetailItem('Date Added', product.formattedCreatedAt, Icons.add_circle_outline),
                          if (product.updatedAt != null)
                            _buildDetailItem('Last Updated', _formatDateTime(_safeString(product.updatedAt)), Icons.update),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C757D),
                        side: const BorderSide(color: Color(0xFF6C757D)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  if (product.id != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDeleteConfirmation(),
                        icon: const Icon(Icons.delete, color: Colors.white),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC3545),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor = _getStatusColor();
    IconData statusIcon = _getStatusIcon();
    String statusText = _getStatusText();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getQuantity() <= 10 ? 'LOW STOCK' : 'IN STOCK',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ));
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A00E0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF4A00E0),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF6C757D),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C757D),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.back(); // Close the detail dialog first
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text(
              'Confirm Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Are you sure you want to delete this product?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product: ${_safeString(product.partNumber)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Description: ${_safeString(product.description)}'),
                  Text('Quantity: ${_safeString(product.quantity)}'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF6C757D)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteProduct(product.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
    if (_isExpired()) return const Color(0xFFDC3545);
    if (_getDaysUntilExpiry() <= 30) return const Color(0xFFFFC107);
    return const Color(0xFF28A745);
  }

  IconData _getStatusIcon() {
    if (_isExpired()) return Icons.error;
    if (_getDaysUntilExpiry() <= 30) return Icons.warning;
    return Icons.check_circle;
  }

  String _getStatusText() {
    if (_isExpired()) return 'EXPIRED';
    int daysUntilExpiry = _getDaysUntilExpiry();
    if (daysUntilExpiry <= 30) return 'Expires in $daysUntilExpiry days';
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