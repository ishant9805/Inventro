import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:inventro/app/modules/auth/controller/add_employee_controller.dart';

/// Widget to show company-wide employee limit status and progress
class CompanyLimitBanner extends StatelessWidget {
  final AddEmployeeController controller;

  const CompanyLimitBanner({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.companyEmployeeCount.value;
      final limit = controller.companyEmployeeLimit.value;
      final progress = limit > 0 ? current / limit : 0.0;
      final remaining = limit - current;
      
      // Determine color based on usage
      Color progressColor;
      Color backgroundColor;
      IconData statusIcon;
      
      if (progress >= 1.0) {
        progressColor = Colors.red;
        backgroundColor = Colors.red.shade50;
        statusIcon = Icons.warning;
      } else if (progress >= 0.8) {
        progressColor = Colors.orange;
        backgroundColor = Colors.orange.shade50;
        statusIcon = Icons.info;
      } else {
        progressColor = Colors.green;
        backgroundColor = Colors.green.shade50;
        statusIcon = Icons.check_circle;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: progressColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusIcon,
                  color: progressColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Company Employee Capacity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: progressColor == Colors.red ? Colors.red[800] : 
                             progressColor == Colors.orange ? Colors.orange[800] : 
                             Colors.green[800],
                    ),
                  ),
                ),
                Text(
                  '$current/$limit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: progressColor == Colors.red ? Colors.red[800] : 
                           progressColor == Colors.orange ? Colors.orange[800] : 
                           Colors.green[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Status Text with data source indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    remaining > 0 
                      ? '$remaining employee slots remaining'
                      : 'Employee limit reached',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                if (current < 1 || (current > 0 && current < controller.currentEmployeeCount.value)) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Estimated',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    });
  }
}