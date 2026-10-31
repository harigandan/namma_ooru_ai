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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOfficerTasks();
  }

  Future<void> _loadOfficerTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tasks = await ApiService().getOfficerAssignments();
      if (mounted) {
        setState(() {
          _assignedTasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _showWorkUpdateDialog(ComplaintModel complaint) {
    final notesController = TextEditingController();
    bool hasBeforePhoto = false;
    bool hasAfterPhoto = false;
    bool isSubmitting = false;

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
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ApiService().updateOfficerProgress(
                                      complaintId: complaint.id,
                                      status: 'in_progress',
                                      resolutionNotes: notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : 'Field crew inspecting and initiating repair work.',
                                    );
                                    await _loadOfficerTasks();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${complaint.complaintNumber} updated to In-Progress'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Update failed: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppButton(
                          label: 'Mark Resolved',
                          variant: AppButtonVariant.primary,
                          leadingIcon: Icons.check,
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  setSheetState(() => isSubmitting = true);
                                  try {
                                    await ApiService().completeOfficerAssignment(
                                      complaintId: complaint.id,
                                      resolutionNotes: notesController.text.trim().isNotEmpty
                                          ? notesController.text.trim()
                                          : 'Work completed and verified by field crew.',
                                    );
                                    await _loadOfficerTasks();
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            '${complaint.complaintNumber} marked resolved successfully.'),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    setSheetState(() => isSubmitting = false);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Resolution update failed: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
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
                    : _errorMessage != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.xxl),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.cloud_off_outlined,
                                      size: 48, color: AppColors.error),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Could not load assignments: $_errorMessage',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  ElevatedButton.icon(
                                    onPressed: _loadOfficerTasks,
                                    icon: const Icon(Icons.refresh),
                                    label:
                                        const Text('Retry / மீண்டும் முயற்சி'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : currentList.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xxl),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.task_alt,
                                          size: 48,
                                          color: AppColors.textSecondary),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        _selectedFilterTab == 0
                                            ? 'No active tasks assigned to your zone / பணிகள் எதுவும் இல்லை'
                                            : 'No resolved tasks for today / முடிவுற்ற பணிகள் இல்லை',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              )
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
