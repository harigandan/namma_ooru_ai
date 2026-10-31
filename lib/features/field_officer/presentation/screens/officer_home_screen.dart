import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/priority_indicator.dart';
import '../../../complaints/domain/models/complaint_model.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class OfficerHomeScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const OfficerHomeScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<OfficerHomeScreen> createState() => _OfficerHomeScreenState();
}

class _OfficerHomeScreenState extends State<OfficerHomeScreen> {
  int _selectedFilterTab = 0; // 0: Active, 1: Completed
  List<ComplaintModel> _assignedTasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOfficerTasks();
  }

  Future<void> _loadOfficerTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await ApiService().getComplaints();
      if (mounted) {
        setState(() {
          _assignedTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWorkUpdateDialog(ComplaintModel complaint) {
    final notesController = TextEditingController();
    bool hasBeforePhoto = false;
    bool hasAfterPhoto = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: AppSpacing.md,
                bottom:
                    MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Work Progress: ${complaint.complaintNumber}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(),
                  const Text('Field Evidence (Before & After Photos):',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                              hasBeforePhoto ? Icons.check : Icons.camera_alt,
                              color: hasBeforePhoto
                                  ? AppColors.success
                                  : AppColors.primary),
                          label: Text(hasBeforePhoto
                              ? 'Before (Attached)'
                              : 'Take Before Photo'),
                          onPressed: () =>
                              setSheetState(() => hasBeforePhoto = true),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                              hasAfterPhoto ? Icons.check : Icons.camera_alt,
                              color: hasAfterPhoto
                                  ? AppColors.success
                                  : AppColors.primary),
                          label: Text(hasAfterPhoto
                              ? 'After (Attached)'
                              : 'Take After Photo'),
                          onPressed: () =>
                              setSheetState(() => hasAfterPhoto = true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Resolution Notes / பணி விவரம்:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter maintenance details, materials used...',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Update In-Progress',
                          variant: AppButtonVariant.secondary,
                          onPressed: () async {
                            await ApiService().updateComplaintStatus(
                              complaintId: complaint.id,
                              newStatus: 'in_progress',
                              resolutionNotes: notesController.text,
                            );
                            setState(() {
                              final idx = _assignedTasks
                                  .indexWhere((c) => c.id == complaint.id);
                              if (idx != -1) {
                                _assignedTasks[idx] = ComplaintModel(
                                  id: complaint.id,
                                  complaintNumber: complaint.complaintNumber,
                                  title: complaint.title,
                                  description: complaint.description,
                                  descriptionTa: complaint.descriptionTa,
                                  category: complaint.category,
                                  categoryLabel: complaint.categoryLabel,
                                  categoryLabelTa: complaint.categoryLabelTa,
                                  priority: complaint.priority,
                                  status: ComplaintStatus.inProgress,
                                  departmentId: complaint.departmentId,
                                  departmentName: complaint.departmentName,
                                  departmentNameTa: complaint.departmentNameTa,
                                  citizenName: complaint.citizenName,
                                  citizenPhone: complaint.citizenPhone,
                                  address: complaint.address,
                                  wardNumber: complaint.wardNumber,
                                  zone: complaint.zone,
                                  latitude: complaint.latitude,
                                  longitude: complaint.longitude,
                                  createdAt: complaint.createdAt,
                                  aiConfidence: complaint.aiConfidence,
                                  aiSummary: complaint.aiSummary,
                                );
                              }
                            });
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Mark Resolved',
                          variant: AppButtonVariant.primary,
                          leadingIcon: Icons.check,
                          onPressed: () async {
                            await ApiService().updateComplaintStatus(
                              complaintId: complaint.id,
                              newStatus: 'resolved',
                              resolutionNotes: notesController.text.isNotEmpty
                                  ? notesController.text
                                  : 'Work completed by field crew.',
                            );
                            setState(() {
                              final idx = _assignedTasks
                                  .indexWhere((c) => c.id == complaint.id);
                              if (idx != -1) {
                                _assignedTasks[idx] = ComplaintModel(
                                  id: complaint.id,
                                  complaintNumber: complaint.complaintNumber,
                                  title: complaint.title,
                                  description: complaint.description,
                                  descriptionTa: complaint.descriptionTa,
                                  category: complaint.category,
                                  categoryLabel: complaint.categoryLabel,
                                  categoryLabelTa: complaint.categoryLabelTa,
                                  priority: complaint.priority,
                                  status: ComplaintStatus.resolved,
                                  departmentId: complaint.departmentId,
                                  departmentName: complaint.departmentName,
                                  departmentNameTa: complaint.departmentNameTa,
                                  citizenName: complaint.citizenName,
                                  citizenPhone: complaint.citizenPhone,
                                  address: complaint.address,
                                  wardNumber: complaint.wardNumber,
                                  zone: complaint.zone,
                                  latitude: complaint.latitude,
                                  longitude: complaint.longitude,
                                  createdAt: complaint.createdAt,
                                  aiConfidence: complaint.aiConfidence,
                                  aiSummary: complaint.aiSummary,
                                  resolutionNotes:
                                      notesController.text.isNotEmpty
                                          ? notesController.text
                                          : "Work completed by field crew.",
                                );
                              }
                            });
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${complaint.complaintNumber} marked resolved with before/after photos.')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _assignedTasks
        .where((c) => c.status != ComplaintStatus.resolved)
        .toList();
    final completedTasks = _assignedTasks
        .where((c) => c.status == ComplaintStatus.resolved)
        .toList();
    final currentList = _selectedFilterTab == 0 ? activeTasks : completedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Field Officer Workstation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('Er. K. Sivakumar • Zone 5 Chennai',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          // Role Badge
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: AppSpacing.roundedPill,
              border: Border.all(color: AppColors.primary),
            ),
            child: const Row(
              children: [
                Icon(Icons.engineering, size: 16, color: AppColors.primary),
                SizedBox(width: 4),
                Text('Field Officer (களப்பணி)',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 22),
            tooltip: 'Officer Profile / சுயவிவரம்',
            onPressed: () => setState(() => _selectedFilterTab = 2),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            tooltip: 'Sign Out / வெளியேறு',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Sign Out / வெளியேறு'),
                  content: const Text(
                      'Are you sure you want to end your field officer session?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign Out',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await ApiService().logout();
                widget.onLogout();
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          // Quick Stats Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Active Tasks',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                        Text('${activeTasks.length}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.warning)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSubtle,
                      borderRadius: AppSpacing.roundedSm,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Completed Today',
                            style: TextStyle(
                                fontSize: 11, color: AppColors.textSecondary)),
                        Text('${completedTasks.length}',
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Tab Selector
          Container(
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilterTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedFilterTab == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Assigned (${activeTasks.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedFilterTab == 0
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedFilterTab == 0
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilterTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedFilterTab == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Completed (${completedTasks.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedFilterTab == 1
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedFilterTab == 1
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedFilterTab = 2),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: _selectedFilterTab == 2
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Officer Profile',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: _selectedFilterTab == 2
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: _selectedFilterTab == 2
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content: Tasks List or Officer Profile
          Expanded(
            child: _selectedFilterTab == 2
                ? ProfileScreen(onLogout: widget.onLogout)
                : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final c = currentList[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.complaintNumber,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary),
                                  ),
                                  PriorityIndicator(priority: c.priorityString),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                c.title,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined,
                                      size: 14, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      c.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  StatusBadge(
                                      status: c.statusString, isSmall: true),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.navigation_outlined,
                                        size: 16),
                                    label: const Text('Navigate'),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Opening GPS route to ${c.address}...')),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  ElevatedButton(
                                    onPressed: () => _showWorkUpdateDialog(c),
                                    child: const Text('Update Work'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
