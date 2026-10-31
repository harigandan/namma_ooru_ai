import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
import 'core/constants/app_constants.dart';
import 'core/services/api_service.dart';
import 'core/localization/app_localizations.dart';
import 'shared/widgets/responsive_scaffold.dart';
import 'shared/widgets/metric_card.dart';
import 'shared/widgets/complaint_card.dart';
import 'shared/widgets/app_button.dart';
import 'shared/widgets/empty_state.dart';
import 'features/complaints/domain/models/complaint_model.dart';
import 'features/complaints/presentation/screens/complaint_detail_screen.dart';
import 'features/complaints/presentation/screens/complaint_form_screen.dart';
import 'features/complaint_assistant/presentation/screens/ai_assistant_screen.dart';
import 'features/admin_dashboard/presentation/screens/admin_dashboard_screen.dart';
import 'features/field_officer/presentation/screens/officer_home_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/maps/presentation/screens/civic_map_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';

enum AppRole { citizen, admin, fieldOfficer }

/// Main Namma Ooru AI Application Root with Persistent Authentication & Localization
class NammaOoruApp extends ConsumerStatefulWidget {
  const NammaOoruApp({super.key});

  @override
  ConsumerState<NammaOoruApp> createState() => _NammaOoruAppState();
}

class _NammaOoruAppState extends ConsumerState<NammaOoruApp> {
  final LanguageController _langCtrl = LanguageController();

  bool _isCheckingSession = true;
  bool _isAuthenticated = false;
  AppRole _activeRole = AppRole.citizen;

  int _citizenNavIndex = 0;
  List<ComplaintModel> _complaints = [];
  bool _isLoadingComplaints = false;
  String? _errorMessage;

  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _langCtrl.initialize();
    await _checkSession();
  }

  Future<void> _checkSession() async {
    setState(() => _isCheckingSession = true);

    try {
      final sessionProfile = await ApiService().restoreSession();
      if (sessionProfile != null) {
        final roleStr = sessionProfile['role'] as String? ?? 'citizen';
        _userProfile = sessionProfile;
        _activeRole = _roleFromString(roleStr);
        _isAuthenticated = true;

        if (_activeRole == AppRole.citizen) {
          _loadComplaints();
        }
      } else {
        _isAuthenticated = false;
      }
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      if (mounted) {
        setState(() => _isCheckingSession = false);
      }
    }
  }

  AppRole _roleFromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppRole.admin;
      case 'field_officer':
        return AppRole.fieldOfficer;
      case 'citizen':
      default:
        return AppRole.citizen;
    }
  }

  void _handleLoginSuccess(String role) {
    setState(() {
      _activeRole = _roleFromString(role);
      _userProfile = ApiService().currentUserProfile;
      _isAuthenticated = true;
      _citizenNavIndex = 0;
    });

    if (_activeRole == AppRole.citizen) {
      _loadComplaints();
    }
  }

  Future<void> _handleLogout() async {
    await ApiService().logout();
    if (mounted) {
      setState(() {
        _isAuthenticated = false;
        _activeRole = AppRole.citizen;
        _userProfile = null;
        _complaints = [];
      });
    }
  }

  Future<void> _loadComplaints() async {
    setState(() {
      _isLoadingComplaints = true;
      _errorMessage = null;
    });

    try {
      final liveComplaints = await ApiService().getComplaints();
      if (mounted) {
        setState(() {
          _complaints = liveComplaints;
          _isLoadingComplaints = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoadingComplaints = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _langCtrl,
      builder: (context, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          locale: _langCtrl.currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (innerContext) => _buildRootFlow(innerContext),
          ),
        );
      },
    );
  }

  Widget _buildRootFlow(BuildContext context) {
    // 1. Splash / Checking Auth State
    if (_isCheckingSession) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: const Icon(Icons.location_city,
                    size: 54, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'நம்ம ஊர் AI • Namma Ooru AI',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'தமிழ்நாடு நகராட்சி நிர்வாகம்',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Unauthenticated State -> Must Login
    if (!_isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: _handleLoginSuccess,
      );
    }

    // 3. Authenticated Role Dashboards
    switch (_activeRole) {
      case AppRole.admin:
        return AdminDashboardScreen(
          onLogout: _handleLogout,
        );
      case AppRole.fieldOfficer:
        return OfficerHomeScreen(
          onLogout: _handleLogout,
        );
      case AppRole.citizen:
        return _buildCitizenScaffold(context);
    }
  }

  Widget _buildCitizenScaffold(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final citizenDestinations = [
      NavigationDestinationItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
        label: l10n.tr('home'),
      ),
      NavigationDestinationItem(
        icon: Icons.assignment_outlined,
        selectedIcon: Icons.assignment,
        label: l10n.tr('complaints'),
      ),
      NavigationDestinationItem(
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome,
        label: l10n.tr('ai_assistant'),
      ),
      NavigationDestinationItem(
        icon: Icons.map_outlined,
        selectedIcon: Icons.map,
        label: l10n.tr('civic_map'),
      ),
      NavigationDestinationItem(
        icon: Icons.person_outline,
        selectedIcon: Icons.person,
        label: l10n.tr('profile'),
      ),
    ];

    return ResponsiveScaffold(
      selectedIndex: _citizenNavIndex,
      onDestinationSelected: (index) =>
          setState(() => _citizenNavIndex = index),
      destinations: citizenDestinations,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: AppSpacing.roundedSm,
              ),
              child: const Icon(Icons.location_city,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('app_name'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  l10n.tr('app_subtitle'),
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Language Switcher Toggle Pill
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.roundedPill,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () => _langCtrl.setLanguage('ta'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _langCtrl.isTamil
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: AppSpacing.roundedPill,
                    ),
                    child: Text(
                      'தமிழ்',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _langCtrl.isTamil
                            ? AppColors.textInverse
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _langCtrl.setLanguage('en'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: !_langCtrl.isTamil
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: AppSpacing.roundedPill,
                    ),
                    child: Text(
                      'Eng',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: !_langCtrl.isTamil
                            ? AppColors.textInverse
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Citizen Profile Avatar Action
          IconButton(
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: _citizenNavIndex == 4 ? AppColors.primary : AppColors.accent,
              child: Icon(
                Icons.person,
                size: 16,
                color: _citizenNavIndex == 4 ? Colors.white : AppColors.primary,
              ),
            ),
            tooltip: l10n.tr('profile'),
            onPressed: () => setState(() => _citizenNavIndex = 4),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error, size: 20),
            tooltip: l10n.tr('logout'),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(l10n.tr('logout')),
                  content: Text(l10n.tr('logout_confirm')),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(l10n.tr('cancel')),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(l10n.tr('logout'),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _handleLogout();
              }
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _buildCitizenCurrentView(context),
    );
  }

  Widget _buildCitizenCurrentView(BuildContext context) {
    switch (_citizenNavIndex) {
      case 0:
        return _buildCitizenHomeView(context);
      case 1:
        return _buildCitizenComplaintsListView();
      case 2:
        return AIAssistantScreen(
          onComplaintSubmitted: () {
            setState(() => _citizenNavIndex = 1);
            _loadComplaints();
          },
        );
      case 3:
        return const CivicMapScreen();
      case 4:
      default:
        return ProfileScreen(
          initialProfile: _userProfile,
          onLogout: _handleLogout,
          onProfileUpdated: (updated) {
            setState(() => _userProfile = updated);
          },
        );
    }
  }

  Widget _buildCitizenHomeView(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (_isLoadingComplaints) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xxl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text('Connection Error: $_errorMessage',
                  textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                  label: 'Retry / மீண்டும் முயற்சி',
                  onPressed: _loadComplaints),
            ],
          ),
        ),
      );
    }

    final residentName = _userProfile?['full_name'] ?? 'Citizen';

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting & Quick Action Hero Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppSpacing.roundedMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_langCtrl.isTamil ? 'வணக்கம்' : 'Welcome'}, $residentName!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textInverse,
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _citizenNavIndex = 4),
                        borderRadius: AppSpacing.roundedPill,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: AppSpacing.roundedPill,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_pin,
                                  size: 14, color: AppColors.textInverse),
                              const SizedBox(width: 4),
                              Text(
                                _userProfile?['city'] ?? 'Chennai',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textInverse,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.tr('tagline'),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textInverse.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.roundedSm),
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                    ),
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: Text(
                      l10n.tr('lodge_complaint'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ComplaintFormScreen(
                            onSubmitted: _loadComplaints,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Metrics Summary Row
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    title: l10n.tr('my_complaints'),
                    value: '${_complaints.length}',
                    subtitle: 'Total Lodged',
                    icon: Icons.assignment_outlined,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricCard(
                    title: l10n.tr('status_in_progress'),
                    value:
                        '${_complaints.where((c) => c.status == ComplaintStatus.inProgress || c.status == ComplaintStatus.assigned).length}',
                    subtitle: 'Active Action',
                    icon: Icons.hourglass_top_outlined,
                    iconColor: AppColors.warning,
                    iconBgColor: AppColors.warningLight,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: MetricCard(
                    title: l10n.tr('status_resolved'),
                    value:
                        '${_complaints.where((c) => c.status == ComplaintStatus.resolved).length}',
                    subtitle: 'Solved',
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                    iconBgColor: AppColors.successLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Section: Recent Complaints
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.tr('recent_issues'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => setState(() => _citizenNavIndex = 1),
                  child: Text(
                    '${l10n.tr('filter_all')} (${_complaints.length})',
                    style: const TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            if (_complaints.isEmpty)
              EmptyState(
                title: l10n.tr('no_complaints_found'),
                description:
                    'Lodge your first complaint in your area through text, voice, or image.',
                actionLabel: l10n.tr('lodge_complaint'),
                onAction: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          ComplaintFormScreen(onSubmitted: _loadComplaints),
                    ),
                  );
                },
              )
            else
              ..._complaints.take(3).map(
                    (c) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ComplaintCard(
                        complaintNumber: c.complaintNumber,
                        title: c.title,
                        category: c.category,
                        status: c.statusString,
                        priority: c.priorityString,
                        address: c.address,
                        timeAgo:
                            '${DateTime.now().difference(c.createdAt).inHours} hrs ago',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ComplaintDetailScreen(complaint: c),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitizenComplaintsListView() {
    final l10n = AppLocalizations.of(context);

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: _complaints.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.tr('my_complaints')} (${_complaints.length})',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    tooltip: l10n.tr('lodge_complaint'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              ComplaintFormScreen(onSubmitted: _loadComplaints),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          if (_complaints.isEmpty) {
            return EmptyState(
              title: l10n.tr('no_complaints_found'),
              description: 'Zero active or previous complaints.',
            );
          }

          final c = _complaints[index - 1];
          return ComplaintCard(
            complaintNumber: c.complaintNumber,
            title: c.title,
            category: c.category,
            status: c.statusString,
            priority: c.priorityString,
            address: c.address,
            timeAgo:
                '${DateTime.now().difference(c.createdAt).inHours} hrs ago',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComplaintDetailScreen(complaint: c),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
