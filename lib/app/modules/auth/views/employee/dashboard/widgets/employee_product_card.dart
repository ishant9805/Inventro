import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/employee_dashboard_controller.dart';
import 'package:inventro/app/data/models/product_model.dart';

/// Employee Product Card - Individual product card for the employee dashboard
/// Shows product information with expired products highlighted in red
class EmployeeProductCard extends StatelessWidget {
  final ProductModel product;
  final EmployeeDashboardController controller;

  const EmployeeProductCard({
    super.key,
    required this.product,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = product.isExpired;
    
    return GestureDetector(
      onTap: () => controller.showProductDetails(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpired 
                ? Colors.red.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: isExpired ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpired 
                  ? Colors.red.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with part number and status
              Row(
                children: [
                  // Product icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.red.withOpacity(0.1)
                          : const Color(0xFF4A00E0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Product part number
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.partNumber,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isExpired ? Colors.red : const Color(0xFF1A202C),
                          ),
                        ),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'EXPIRED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Quantity badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpired 
                          ? Colors.red.withOpacity(0.1)
                          : const Color(0xFF4A00E0).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                      ),
                    ),
                    child: Text(
                      'Qty: ${product.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Product description
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isExpired ? Colors.red.shade700 : const Color(0xFF6B7280),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Location and expiry information
              Row(
                children: [
                  // Location
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: isExpired ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      product.location,
                      style: TextStyle(
                        fontSize: 12,
                        color: isExpired ? Colors.red.shade700 : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Expiry date
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: isExpired ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    product.formattedExpiryDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: isExpired ? Colors.red.shade700 : Colors.grey[600],
                      fontWeight: isExpired ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Tap hint
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap for details',
                    style: TextStyle(
                      fontSize: 11,
                      color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isExpired ? Colors.red : const Color(0xFF4A00E0),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}