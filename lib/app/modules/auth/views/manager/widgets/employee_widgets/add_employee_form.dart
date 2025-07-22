import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/add_employee_controller.dart';
import 'employee_text_field.dart';
import 'submit_employee_button.dart';
import 'company_limit_banner.dart';

class AddEmployeeForm extends StatelessWidget {
  final AddEmployeeController controller;

  const AddEmployeeForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Company Limit Banner
        CompanyLimitBanner(controller: controller),

        // Main Form Container
        Container(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionHeader('Personal Information', Icons.person_outline),
              const SizedBox(height: 16),
              EmployeeTextField(
                controller: controller.nameController,
                label: 'Full Name',
                hint: 'Enter employee full name',
                icon: Icons.person,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              EmployeeTextField(
                controller: controller.emailController,
                label: 'Email Address',
                hint: 'Enter employee email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Security & Access', Icons.security),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: EmployeeTextField(
                      controller: controller.pinController,
                      label: '4-Digit PIN',
                      hint: 'Enter PIN',
                      icon: Icons.lock,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      maxLength: 4,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: EmployeeTextField(
                      controller: controller.confirmPinController,
                      label: 'Confirm PIN',
                      hint: 'Confirm PIN',
                      icon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      maxLength: 4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              EmployeeTextField(
                controller: TextEditingController(text: controller.role),
                label: 'Role',
                hint: 'Employee role',
                icon: Icons.badge,
                enabled: false,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Work Information', Icons.work_outline),
              const SizedBox(height: 16),
              EmployeeTextField(
                controller: controller.departmentController,
                label: 'Department',
                hint: 'Enter department name',
                icon: Icons.business,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              EmployeeTextField(
                controller: controller.phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),
              SubmitEmployeeButton(controller: controller),
            ],
          ),
        ),
      ],
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}