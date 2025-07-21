import 'package:flutter/material.dart';
import 'package:inventro/app/utils/responsive_utils.dart';

/// Reusable section divider with consistent spacing for dashboard components
class DashboardSectionDivider extends StatelessWidget {
  final double? customHeight;
  final bool showDividerLine;
  final Color? dividerColor;

  const DashboardSectionDivider({
    super.key,
    this.customHeight,
    this.showDividerLine = false,
    this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final height = customHeight ?? ResponsiveUtils.getSpacing(context, 24);
    
    return Column(
      children: [
        SizedBox(height: height),
        if (showDividerLine)
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.getPadding(context),
            ),
            decoration: BoxDecoration(
              color: dividerColor ?? Colors.white.withOpacity(0.2),
            ),
          ),
        if (showDividerLine)
          SizedBox(height: height),
      ],
    );
  }
}