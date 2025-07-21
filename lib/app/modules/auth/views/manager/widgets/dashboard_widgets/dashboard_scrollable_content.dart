import 'package:flutter/material.dart';
import 'package:inventro/app/utils/responsive_utils.dart';

/// Reusable scrollable content wrapper for dashboard sections
class DashboardScrollableContent extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? customPadding;
  final CrossAxisAlignment crossAxisAlignment;

  const DashboardScrollableContent({
    super.key,
    required this.children,
    this.customPadding,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: customPadding ?? EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getPadding(context),
              vertical: ResponsiveUtils.getSpacing(context, 24),
            ),
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              children: children,
            ),
          );
        },
      ),
    );
  }
}