import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controller/auth_controller.dart';

/// Manager details form section with all registration fields
class ManagerDetailsForm extends StatelessWidget {
  final AuthController authController;

  const ManagerDetailsForm({
    super.key,
    required this.authController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: authController.nameController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline),
            labelText: 'Full Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        TextFormField(
          controller: authController.emailController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.email_outlined),
            labelText: 'Email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Email is required';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        TextFormField(
          controller: authController.passwordController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          obscureText: true,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),

        TextFormField(
          controller: authController.confirmPasswordController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.lock_outline),
            labelText: 'Confirm Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          obscureText: true,
          textInputAction: TextInputAction.done,
          validator: (value) {
            if (value != authController.passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}