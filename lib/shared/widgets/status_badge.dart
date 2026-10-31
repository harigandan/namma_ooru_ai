import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Reusable status chip rendering complaint state with contextual color themes
class StatusBadge extends StatelessWidget {
  final String status;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.status,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    String displayLabel;

    switch (status.toLowerCase()) {
      case 'submitted':
        bgColor = const Color(0xFFEFF6FF);
        fgColor = const Color(0xFF1D4ED8);
        displayLabel = 'Submitted';
        break;
      case 'under_review':
        bgColor = AppColors.warningLight;
        fgColor = const Color(0xFFB45309);
        displayLabel = 'Under Review';
        break;
      case 'assigned':
        bgColor = const Color(0xFFF3E8FF);
        fgColor = const Color(0xFF7E22CE);
        displayLabel = 'Assigned';
        break;
      case 'in_progress':
        bgColor = AppColors.accent;
        fgColor = AppColors.primaryDark;
        displayLabel = 'In Progress';
        break;
      case 'resolved':
        bgColor = AppColors.successLight;
        fgColor = AppColors.success;
        displayLabel = 'Resolved';
        break;
      case 'closed':
        bgColor = const Color(0xFFF1F5F9);
        fgColor = AppColors.textSecondary;
        displayLabel = 'Closed';
        break;
      case 'reopened':
        bgColor = AppColors.errorLight;
        fgColor = AppColors.error;
        displayLabel = 'Reopened';
        break;
      case 'rejected':
        bgColor = AppColors.errorLight;
        fgColor = AppColors.error;
        displayLabel = 'Rejected';
        break;
      default:
        bgColor = AppColors.surfaceSubtle;
        fgColor = AppColors.textSecondary;
        displayLabel = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? AppSpacing.xs : AppSpacing.sm,
        vertical: isSmall ? 2.0 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppSpacing.roundedPill,
        border: Border.all(color: fgColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: isSmall ? 11 : 12,
          fontWeight: FontWeight.w600,
          color: fgColor,
        ),
      ),
    );
  }
}
