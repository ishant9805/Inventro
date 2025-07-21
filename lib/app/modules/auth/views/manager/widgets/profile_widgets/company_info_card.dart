import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/auth_controller.dart';


/// Company information card component with visibility toggle
class CompanyInfoCard extends StatefulWidget {
  final AuthController authController;

  const CompanyInfoCard({
    super.key,
    required this.authController,
  });

  @override
  State<CompanyInfoCard> createState() => _CompanyInfoCardState();
}

class _CompanyInfoCardState extends State<CompanyInfoCard> {
  bool _isCompanyIdVisible = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.user.value;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Company Information', Icons.business_outlined),
          const SizedBox(height: 20),
          
          if (user?.company != null) ...[
            _buildInfoRowWithToggle(
              icon: Icons.fingerprint,
              label: 'Company ID',
              value: user!.company!.id.toString(),
              isVisible: _isCompanyIdVisible,
              onToggle: () {
                setState(() {
                  _isCompanyIdVisible = !_isCompanyIdVisible;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              icon: Icons.business,
              label: 'Company Name',
              value: user.company!.name,
            ),
            
            const SizedBox(height: 16),
            
            _buildInfoRow(
              icon: Icons.people,
              label: 'Company Size',
              value: '${user.company!.size} employees',
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Company information not available',
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
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
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade600,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRowWithToggle({
    required IconData icon,
    required String label,
    required String value,
    required bool isVisible,
    required VoidCallback onToggle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.grey.shade600,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isVisible ? value : '••••••••',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A202C),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onToggle,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4A00E0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isVisible ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF4A00E0),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}