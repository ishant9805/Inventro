import 'package:flutter/material.dart';
import 'package:inventro/app/modules/auth/controller/add_product_controller.dart';
import 'product_text_field.dart';
import 'expiry_date_picker.dart';
import 'submit_product_button.dart';

class AddProductForm extends StatelessWidget {
  final AddProductController controller;

  const AddProductForm({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionHeader('Basic Information', Icons.info_outline),
          const SizedBox(height: 16),
          ProductTextField(
            controller: controller.partNumberController,
            label: 'Part Number',
            hint: 'Enter unique part number',
            icon: Icons.qr_code,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          ProductTextField(
            controller: controller.descriptionController,
            label: 'Description',
            hint: 'Enter product description',
            icon: Icons.description,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Inventory Details', Icons.warehouse),
          const SizedBox(height: 16),
          ProductTextField(
            controller: controller.locationController,
            label: 'Location',
            hint: 'Enter storage location',
            icon: Icons.location_on,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ProductTextField(
                  controller: controller.quantityController,
                  label: 'Quantity',
                  hint: 'Enter quantity',
                  icon: Icons.inventory,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ProductTextField(
                  controller: controller.batchNumberController,
                  label: 'Batch Number',
                  hint: 'Enter batch number',
                  icon: Icons.batch_prediction,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExpiryDatePicker(controller: controller.expiryDateController),
          const SizedBox(height: 32),
          SubmitProductButton(controller: controller),
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A202C),
          ),
        ),
      ],
    );
  }
}