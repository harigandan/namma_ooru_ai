import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Reusable priority visual indicator (dot / badge) for complaints
class PriorityIndicator extends StatelessWidget {
  final String priority;
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'critical':
        color = const Color(0xFFDC2626);
        label = 'Critical';
        break;
      case 'high':
        color = AppColors.error;
        label = 'High';
        break;
      case 'medium':
        color = AppColors.warning;
        label = 'Medium';
        break;
      case 'low':
      default:
        color = AppColors.success;
        label = 'Low';
        break;
    }

    if (!showLabel) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
