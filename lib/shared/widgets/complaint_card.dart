import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'status_badge.dart';
import 'priority_indicator.dart';

/// Reusable complaint list item card with category icon, status badge, title, location, and SLA date
class ComplaintCard extends StatelessWidget {
  final String complaintNumber;
  final String title;
  final String category;
  final String status;
  final String priority;
  final String address;
  final String timeAgo;
  final VoidCallback? onTap;

  const ComplaintCard({
    super.key,
    required this.complaintNumber,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.address,
    required this.timeAgo,
    this.onTap,
  });

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'garbage_collection':
      case 'garbage':
        return Icons.delete_outline;
      case 'road_damage':
      case 'roads':
        return Icons.add_road;
      case 'water_supply':
      case 'water':
        return Icons.water_drop_outlined;
      case 'drainage':
        return Icons.waves_outlined;
      case 'streetlights':
        return Icons.lightbulb_outline;
      case 'electricity':
        return Icons.bolt_outlined;
      case 'public_sanitation':
        return Icons.cleaning_services_outlined;
      case 'public_safety':
        return Icons.shield_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.roundedMd,
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.roundedMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Number + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: AppSpacing.roundedSm,
                        ),
                        child: Icon(
                          _getCategoryIcon(category),
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        complaintNumber,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(status: status, isSmall: true),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Address & Location
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: AppSpacing.xxs),
                  Expanded(
                    child: Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              const Divider(),
              const SizedBox(height: AppSpacing.xs),

              // Footer: Priority + Timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PriorityIndicator(priority: priority),
                  Text(
                    timeAgo,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
