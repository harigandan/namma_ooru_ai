import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/priority_indicator.dart';
import '../../domain/models/complaint_model.dart';

class ComplaintDetailScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailScreen({super.key, required this.complaint});

  @override
  State<ComplaintDetailScreen> createState() => _ComplaintDetailScreenState();
}

class _ComplaintDetailScreenState extends State<ComplaintDetailScreen> {
  int _userRating = 5;
  final TextEditingController _feedbackController = TextEditingController();
  bool _feedbackSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          c.complaintNumber,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Priority Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusBadge(status: c.statusString),
                      PriorityIndicator(priority: c.priorityString),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    c.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  if (c.descriptionTa != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      c.descriptionTa!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    c.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // AI Classification Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: AppSpacing.roundedMd,
                side: const BorderSide(color: AppColors.primaryLight),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome,
                                color: AppColors.primary, size: 18),
                            SizedBox(width: AppSpacing.xs),
                            Text(
                              'AI Analysis & Department Routing',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary),
                            ),
                          ],
                        ),
                        Text(
                          '${(c.aiConfidence * 100).toInt()}% Conf.',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Department: ${c.departmentName} (${c.departmentNameTa})',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      c.aiSummary,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Location & Officer In Charge
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 18, color: AppColors.primary),
                        SizedBox(width: AppSpacing.xs),
                        Text('Location / இடம்',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(c.address,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.textPrimary)),
                    Text('${c.wardNumber} • ${c.zone} • ${c.city}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                    if (c.assignedOfficerName != null) ...[
                      const Divider(height: 24),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.accent,
                            child: Icon(Icons.person,
                                size: 18, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Assigned Officer / பொறுப்பாளர்',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                                Text(c.assignedOfficerName!,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600)),
                                if (c.assignedOfficerPhone != null)
                                  Text(c.assignedOfficerPhone!,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Resolution Photographs (Before & After)
            if (c.initialPhotoUrls.isNotEmpty ||
                c.resolutionPhotoUrls.isNotEmpty) ...[
              const Text(
                'Photographic Evidence / புகைப்பட சான்று',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (c.initialPhotoUrls.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Initial Report (Before)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: AppSpacing.roundedSm,
                            child: Image.network(
                              c.initialPhotoUrls.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (c.initialPhotoUrls.isNotEmpty &&
                      c.resolutionPhotoUrls.isNotEmpty)
                    const SizedBox(width: AppSpacing.sm),
                  if (c.resolutionPhotoUrls.isNotEmpty)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Resolved (After Work)',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: AppSpacing.roundedSm,
                            child: Image.network(
                              c.resolutionPhotoUrls.first,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // Status Timeline
            const Text(
              'Activity History & Timeline / நிகழ்வுகள்',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...c.timeline.map((event) => _buildTimelineTile(event)),

            const SizedBox(height: AppSpacing.md),

            // Citizen Feedback Section if Resolved
            if (c.status == ComplaintStatus.resolved)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withValues(alpha: 0.4),
                  borderRadius: AppSpacing.roundedMd,
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resolution Feedback / தீர்வு கருத்து',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Are you satisfied with this municipal work resolution?',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (_feedbackSubmitted)
                      const Text(
                        'நன்றி! உங்கள் மதிப்பீடு பதிவு செய்யப்பட்டது. (Thank you for your feedback!)',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success),
                      )
                    else ...[
                      Row(
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < _userRating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.amber,
                              size: 28,
                            ),
                            onPressed: () =>
                                setState(() => _userRating = index + 1),
                          );
                        }),
                      ),
                      TextField(
                        controller: _feedbackController,
                        decoration: const InputDecoration(
                          hintText: 'Add comments (optional)...',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      AppButton(
                        label: 'Submit Feedback / சமர்ப்பி',
                        height: 38,
                        onPressed: () =>
                            setState(() => _feedbackSubmitted = true),
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(ComplaintTimelineEvent event) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: Icon(event.icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      '${event.timestamp.hour}:${event.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.3),
                ),
                Text(
                  '${event.actorName} (${event.actorRole})',
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
