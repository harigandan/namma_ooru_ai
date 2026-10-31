import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../shared/widgets/metric_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/priority_indicator.dart';
import '../../../complaints/domain/models/complaint_model.dart';
import '../../../complaints/presentation/screens/complaint_detail_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const AdminDashboardScreen({
    super.key,
    required this.onLogout,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedSidebarIndex = 0;
  String _selectedStatusFilter = 'all';
  String _selectedCategoryFilter = 'all';
  String _searchQuery = '';
  List<ComplaintModel> _complaints = [];
  Map<String, dynamic> _metrics = {};
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final fetchedComplaints = await ApiService().getComplaints();
      final fetchedMetrics = await ApiService().getAdminMetrics();
      List<Map<String, dynamic>> fetchedDepts = [];
      try {
        fetchedDepts = await ApiService().getDepartments();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _complaints = fetchedComplaints;
          _metrics = fetchedMetrics;
          _departments = fetchedDepts;
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

  final List<Map<String, dynamic>> _sidebarItems = const [
    {
      "icon": Icons.dashboard_outlined,
      "activeIcon": Icons.dashboard,
      "label": "Overview"
    },
    {
      "icon": Icons.assignment_outlined,
      "activeIcon": Icons.assignment,
      "label": "All Complaints"
    },
    {
      "icon": Icons.pending_actions_outlined,
      "activeIcon": Icons.pending_actions,
      "label": "Pending SLA"
    },
    {
      "icon": Icons.apartment_outlined,
      "activeIcon": Icons.apartment,
      "label": "Departments"
    },
    {
      "icon": Icons.badge_outlined,
      "activeIcon": Icons.badge,
      "label": "Field Officers"
    },
    {
      "icon": Icons.map_outlined,
      "activeIcon": Icons.map,
      "label": "Live Map & Hotspots"
    },
    {
      "icon": Icons.auto_awesome_outlined,
      "activeIcon": Icons.auto_awesome,
      "label": "AI Insights"
    },
    {
      "icon": Icons.bar_chart_outlined,
      "activeIcon": Icons.bar_chart,
      "label": "Analytics & Reports"
    },
    {
      "icon": Icons.campaign_outlined,
      "activeIcon": Icons.campaign,
      "label": "Announcements"
    },
    {
      "icon": Icons.people_outline,
      "activeIcon": Icons.people,
      "label": "User Management"
    },
    {
      "icon": Icons.history_edu_outlined,
      "activeIcon": Icons.history_edu,
      "label": "Audit Logs"
    },
    {
      "icon": Icons.settings_outlined,
      "activeIcon": Icons.settings,
      "label": "Settings"
    },
    {
      "icon": Icons.person_outline,
      "activeIcon": Icons.person,
      "label": "My Profile"
    },
  ];

  List<ComplaintModel> get _filteredComplaints {
    return _complaints.where((c) {
      if (_selectedStatusFilter != 'all' &&
          c.statusString != _selectedStatusFilter) {
        return false;
      }
      if (_selectedCategoryFilter != 'all' &&
          c.category != _selectedCategoryFilter) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchNumber = c.complaintNumber.toLowerCase().contains(query);
        final matchTitle = c.title.toLowerCase().contains(query);
        final matchCitizen = c.citizenName.toLowerCase().contains(query);
        final matchAddress = c.address.toLowerCase().contains(query);
        if (!matchNumber && !matchTitle && !matchCitizen && !matchAddress) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _handleAssignDialog(ComplaintModel complaint) {
    String selectedDeptId = complaint.departmentId.isNotEmpty
        ? complaint.departmentId
        : (_departments.isNotEmpty ? _departments.first['id'].toString() : '');
    String selectedDeptName = complaint.departmentName;
    String selectedOfficer =
        complaint.assignedOfficerName ?? "Er. K. Sivakumar (AE-Water)";
    bool isAssigning = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
              title: Text('Assign Complaint: ${complaint.complaintNumber}',
                  style: const TextStyle(fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Select Municipal Department:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  if (_departments.isNotEmpty)
                    DropdownButtonFormField<String>(
                      initialValue: _departments.any((d) => d['id'].toString() == selectedDeptId)
                          ? selectedDeptId
                          : _departments.first['id'].toString(),
                      items: _departments.map((d) {
                        return DropdownMenuItem<String>(
                          value: d['id'].toString(),
                          child: Text(d['name'].toString()),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedDeptId = val;
                            final match = _departments.firstWhere(
                              (d) => d['id'].toString() == val,
                              orElse: () => {'name': selectedDeptName},
                            );
                            selectedDeptName = match['name']?.toString() ?? selectedDeptName;
                          });
                        }
                      },
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: selectedDeptName,
                      items: const [
                        DropdownMenuItem(
                            value: "Metro Water & Supply Board",
                            child: Text("Metro Water & Supply Board")),
                        DropdownMenuItem(
                            value: "Solid Waste Management",
                            child: Text("Solid Waste Management")),
                        DropdownMenuItem(
                            value: "Highways & Roads Engineering",
                            child: Text("Highways & Roads Engineering")),
                        DropdownMenuItem(
                            value: "Public Lighting & Electrical",
                            child: Text("Public Lighting & Electrical")),
                        DropdownMenuItem(
                            value: "Stormwater & Drainage",
                            child: Text("Stormwater & Drainage")),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedDeptName = val);
                      },
                    ),
                  const SizedBox(height: AppSpacing.md),
                  const Text('Assign Field Officer:',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedOfficer,
                    items: const [
                      DropdownMenuItem(
                          value: "Er. K. Sivakumar (AE-Water)",
                          child: Text("Er. K. Sivakumar (AE-Water)")),
                      DropdownMenuItem(
                          value: "Thiru M. Arumugam (Sanitary Inspector)",
                          child:
                              Text("Thiru M. Arumugam (Sanitary Inspector)")),
                      DropdownMenuItem(
                          value: "Er. N. Murugan (Road Inspector)",
                          child: Text("Er. N. Murugan (Road Inspector)")),
                      DropdownMenuItem(
                          value: "Thiru S. Balaji (Electrician Inspector)",
                          child:
                              Text("Thiru S. Balaji (Electrician Inspector)")),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedOfficer = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isAssigning
                      ? null
                      : () async {
                          setDialogState(() => isAssigning = true);
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await ApiService().assignComplaint(
                              complaintId: complaint.id,
                              departmentId: selectedDeptId.isNotEmpty
                                  ? selectedDeptId
                                  : complaint.departmentId,
                            );
                            setState(() {
                              final idx = _complaints
                                  .indexWhere((item) => item.id == complaint.id);
                              if (idx != -1) {
                                _complaints[idx] = ComplaintModel(
                                  id: complaint.id,
                                  complaintNumber: complaint.complaintNumber,
                                  title: complaint.title,
                                  description: complaint.description,
                                  descriptionTa: complaint.descriptionTa,
                                  category: complaint.category,
                                  categoryLabel: complaint.categoryLabel,
                                  categoryLabelTa: complaint.categoryLabelTa,
                                  priority: complaint.priority,
                                  status: ComplaintStatus.assigned,
                                  departmentId: selectedDeptId.isNotEmpty
                                      ? selectedDeptId
                                      : complaint.departmentId,
                                  departmentName: selectedDeptName,
                                  departmentNameTa: complaint.departmentNameTa,
                                  assignedOfficerName: selectedOfficer,
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
                            nav.pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${complaint.complaintNumber} assigned to $selectedDeptName'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isAssigning = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Assignment failed: $e'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  child: Text(isAssigning ? 'Assigning...' : 'Confirm Assignment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppSpacing.tabletBreakpoint;
        final isMobile = constraints.maxWidth < AppSpacing.mobileBreakpoint;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: AppSpacing.roundedSm,
                  ),
                  child: const Icon(Icons.admin_panel_settings,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tamil Nadu Municipal Governance Portal',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      'Greater Chennai Corporation • Central Command Center',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // Admin Role Badge
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppSpacing.roundedPill,
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        size: 16, color: AppColors.primary),
                    SizedBox(width: 4),
                    Text('Role: Admin (நிர்வாகம்)',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.account_circle, color: AppColors.primary, size: 22),
                tooltip: 'Administrator Profile / சுயவிவரம்',
                onPressed: () => setState(() => _selectedSidebarIndex = 12),
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
                          'Are you sure you want to end the administrative session?'),
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
              const SizedBox(width: AppSpacing.sm),
            ],
          ),
          body: Row(
            children: [
              // Sidebar Navigation (Desktop / Tablet)
              if (!isMobile)
                Container(
                  width: isDesktop ? 240 : 70,
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(right: BorderSide(color: AppColors.border)),
                  ),
                  child: ListView.builder(
                    itemCount: _sidebarItems.length,
                    itemBuilder: (context, index) {
                      final item = _sidebarItems[index];
                      final isSelected = _selectedSidebarIndex == index;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor:
                            AppColors.accent.withValues(alpha: 0.5),
                        leading: Icon(
                          isSelected ? item["activeIcon"] : item["icon"],
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 20,
                        ),
                        title: isDesktop
                            ? Text(
                                item["label"],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryDark
                                      : AppColors.textPrimary,
                                ),
                              )
                            : null,
                        onTap: () =>
                            setState(() => _selectedSidebarIndex = index),
                      );
                    },
                  ),
                ),

              // Main Workspace Content
              Expanded(
                child: _buildWorkspaceContent(isDesktop),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkspaceContent(bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Could not load administrative data: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton.icon(
                onPressed: _loadAdminData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry / மீண்டும் முயற்சி'),
              ),
            ],
          ),
        ),
      );
    }
    switch (_selectedSidebarIndex) {
      case 5: // Live Map
        return _buildLiveMapPlaceholder();
      case 6: // AI Insights
        return _buildAIInsightsView();
      case 12: // My Profile
        return ProfileScreen(
          onLogout: widget.onLogout,
        );
      case 0: // Overview
      case 1: // All Complaints
      case 2: // Pending Complaints
      default:
        return _buildOverviewDashboard(isDesktop);
    }
  }

  Widget _buildOverviewDashboard(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPI Metric Cards Row
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isDesktop ? 6 : 2,
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: isDesktop ? 1.4 : 1.3,
            children: [
              MetricCard(
                title: 'Total Lodged',
                value: _metrics['total_complaints']?.toString() ??
                    '${_complaints.length}',
                subtitle: '+12% this week',
                icon: Icons.assignment_outlined,
              ),
              MetricCard(
                title: 'Under Review',
                value:
                    '${_complaints.where((c) => c.status == ComplaintStatus.underReview || c.status == ComplaintStatus.submitted).length}',
                subtitle: 'Awaiting triage',
                icon: Icons.hourglass_top_outlined,
                iconColor: AppColors.warning,
                iconBgColor: AppColors.warningLight,
              ),
              MetricCard(
                title: 'In Progress',
                value:
                    '${_complaints.where((c) => c.status == ComplaintStatus.inProgress || c.status == ComplaintStatus.assigned).length}',
                subtitle: 'Field crews deployed',
                icon: Icons.engineering_outlined,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.accent,
              ),
              MetricCard(
                title: 'Resolved',
                value:
                    '${_complaints.where((c) => c.status == ComplaintStatus.resolved).length}',
                subtitle: '92% Satisfaction',
                icon: Icons.check_circle_outline,
                iconColor: AppColors.success,
                iconBgColor: AppColors.successLight,
              ),
              MetricCard(
                title: 'Critical SLA',
                value:
                    '${_complaints.where((c) => c.priority == ComplaintPriority.critical).length}',
                subtitle: '< 4 hours target',
                icon: Icons.warning_amber,
                iconColor: AppColors.error,
                iconBgColor: AppColors.errorLight,
              ),
              const MetricCard(
                title: 'Avg Resolution',
                value: '18.4 hrs',
                subtitle: 'SLA target: 24 hrs',
                icon: Icons.speed_outlined,
                iconColor: Color(0xFF2563EB),
                iconBgColor: Color(0xFFEFF6FF),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Filters & Search Bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Wrap(
                spacing: AppSpacing.md,
                runSpacing: AppSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search #, title, area...',
                        prefixIcon: Icon(Icons.search, size: 18),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedStatusFilter,
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Statuses')),
                      DropdownMenuItem(
                          value: 'submitted', child: Text('Submitted')),
                      DropdownMenuItem(
                          value: 'under_review', child: Text('Under Review')),
                      DropdownMenuItem(
                          value: 'assigned', child: Text('Assigned')),
                      DropdownMenuItem(
                          value: 'in_progress', child: Text('In Progress')),
                      DropdownMenuItem(
                          value: 'resolved', child: Text('Resolved')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedStatusFilter = val);
                      }
                    },
                  ),
                  DropdownButton<String>(
                    value: _selectedCategoryFilter,
                    items: const [
                      DropdownMenuItem(
                          value: 'all', child: Text('All Categories')),
                      DropdownMenuItem(
                          value: 'water_supply', child: Text('Water Supply')),
                      DropdownMenuItem(
                          value: 'garbage_collection',
                          child: Text('Garbage Collection')),
                      DropdownMenuItem(
                          value: 'road_damage', child: Text('Road Damage')),
                      DropdownMenuItem(
                          value: 'streetlights', child: Text('Streetlights')),
                      DropdownMenuItem(
                          value: 'drainage', child: Text('Drainage')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCategoryFilter = val);
                      }
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Reset'),
                    onPressed: () => setState(() {
                      _selectedStatusFilter = 'all';
                      _selectedCategoryFilter = 'all';
                      _searchQuery = '';
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Complaints Data Table
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Complaints Registry (${_filteredComplaints.length} records)',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Export CSV'),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                if (_filteredComplaints.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                          SizedBox(height: AppSpacing.sm),
                          Text(
                            'No complaints found matching criteria / கோரிக்கைகள் எதுவும் இல்லை',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.all(AppColors.surfaceSubtle),
                    columns: const [
                      DataColumn(
                          label: Text('Complaint #',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Title & Location',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Category',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Priority',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Status',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Department / Officer',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('AI Confidence',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                      DataColumn(
                          label: Text('Actions',
                              style: TextStyle(fontWeight: FontWeight.w700))),
                    ],
                    rows: _filteredComplaints.map((c) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(c.complaintNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary)),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ComplaintDetailScreen(complaint: c)),
                              );
                            },
                          ),
                          DataCell(
                            SizedBox(
                              width: 220,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(c.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                  Text(c.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(c.categoryLabel,
                              style: const TextStyle(fontSize: 12))),
                          DataCell(
                              PriorityIndicator(priority: c.priorityString)),
                          DataCell(StatusBadge(
                              status: c.statusString, isSmall: true)),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(c.departmentName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                                Text(c.assignedOfficerName ?? 'Unassigned',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: AppSpacing.roundedPill),
                              child: Text('${(c.aiConfidence * 100).toInt()}%',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark)),
                            ),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.person_add_outlined,
                                      size: 18, color: AppColors.primary),
                                  tooltip: 'Assign Officer / Department',
                                  onPressed: () => _handleAssignDialog(c),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined,
                                      size: 18),
                                  tooltip: 'View Full Timeline',
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => ComplaintDetailScreen(
                                              complaint: c)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMapPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text('Live Geospatial PostGIS Map & Hotspot Clusters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: AppSpacing.xs),
          Text(
              'Displays real-time pin markers with category color codes across GCC zones.',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAIInsightsView() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Classification & NLP Metrics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  title: 'Model Accuracy',
                  value: '95.4%',
                  subtitle: 'Evaluated on Tamil/English',
                  icon: Icons.psychology,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MetricCard(
                  title: 'Duplicate Tickets Prevented',
                  value: '18',
                  subtitle: 'Semantic overlap > 0.45',
                  icon: Icons.copy_outlined,
                  iconColor: AppColors.warning,
                  iconBgColor: AppColors.warningLight,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: MetricCard(
                  title: 'Tamil Speech-to-Text',
                  value: '94.2%',
                  subtitle: 'Average word recognition',
                  icon: Icons.record_voice_over,
                  iconColor: AppColors.success,
                  iconBgColor: AppColors.successLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
