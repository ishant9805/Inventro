import 'package:flutter/material.dart';

/// Company validation status display component
class CompanyValidationStatus extends StatelessWidget {
  final bool isNewCompany;
  final Map<String, dynamic>? companyData;
  final String? companyError;
  final bool isCompanyValidated;

  const CompanyValidationStatus({
    super.key,
    required this.isNewCompany,
    this.companyData,
    this.companyError,
    required this.isCompanyValidated,
  });

  @override
  Widget build(BuildContext context) {
    if (isNewCompany) {
      return _buildNewCompanyStatus();
    } else if (companyError != null) {
      return _buildErrorStatus();
    } else if (companyData != null && isCompanyValidated) {
      return _buildValidatedStatus();
    }
    return const SizedBox.shrink();
  }

  Widget _buildNewCompanyStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Company Created Successfully',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (companyData != null) ...[
            Text('Company Name: ${companyData!['name'] ?? '-'}'),
            Text('Company ID: ${companyData!['id'] ?? '-'}'),
            Text('Company Size: ${companyData!['size'] ?? '-'} employees'),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              companyError!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidatedStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Company Validated',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Company Name: ${companyData!['name'] ?? '-'}'),
          Text('Company Size: ${companyData!['size'] ?? '-'} employees'),
        ],
      ),
    );
  }
}