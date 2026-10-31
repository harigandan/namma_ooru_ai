import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';

/// Comprehensive Profile Screen supporting Citizen, Admin, and Field Officer roles.
class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic>? initialProfile;
  final VoidCallback onLogout;
  final Function(Map<String, dynamic>)? onProfileUpdated;

  const ProfileScreen({
    super.key,
    this.initialProfile,
    required this.onLogout,
    this.onProfileUpdated,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LanguageController _langCtrl = LanguageController();
  Map<String, dynamic>? _profile;
  bool _isLoading = false;
  List<Map<String, dynamic>> _availableWards = [];

  @override
  void initState() {
    super.initState();
    _profile = widget.initialProfile ?? ApiService().currentUserProfile;
    if (widget.initialProfile == null) {
      _refreshProfile();
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    try {
      final updated = await ApiService().getUserProfile();
      final wards = await ApiService().getWards();
      if (mounted) {
        setState(() {
          if (updated.isNotEmpty) {
            _profile = {
              ...?_profile,
              ...updated,
            };
          }
          if (wards.isNotEmpty) {
            _availableWards = wards;
          }
          _isLoading = false;
        });
        if (updated.isNotEmpty && _profile != null) {
          widget.onProfileUpdated?.call(_profile!);
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showWardCorrectionDialog(BuildContext context, AppLocalizations l10n) {
    final isTa = _langCtrl.isTamil;
    String? selectedWardId =
        _availableWards.isNotEmpty ? _availableWards.first['id'] : null;

    showDialog(
      context: context,
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
              title: Row(
                children: [
                  const Icon(Icons.pin_drop, color: AppColors.primary),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      l10n.tr('change_ward_request'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTa
                        ? 'நகராட்சி தரவுத்தளத்தில் இருந்து புதிய வார்டைத் தேர்ந்தெடுத்து உறுதிப்படுத்தவும்.'
                        : 'Select your correct residential ward from the municipal database.',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedWardId,
                    decoration: InputDecoration(
                      labelText: l10n.tr('select_new_ward'),
                      border: OutlineInputBorder(
                          borderRadius: AppSpacing.roundedSm),
                    ),
                    items: _availableWards.map((w) {
                      final wNum = w['ward_number'] ?? '';
                      final wName = isTa
                          ? (w['ward_name_ta'] ?? w['ward_name'])
                          : w['ward_name'];
                      return DropdownMenuItem<String>(
                        value: w['id'],
                        child: Text('$wNum: $wName',
                            style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (newId) {
                      setDlgState(() => selectedWardId = newId);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dlgCtx).pop(),
                  child: Text(l10n.tr('cancel')),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedWardId == null) return;
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.of(dlgCtx).pop();

                    final updated = await ApiService().updateCitizenWard(
                      wardId: selectedWardId!,
                      reason: 'Citizen profile update',
                    );

                    if (!mounted) return;
                    setState(() {
                      _profile = {
                        ...?_profile,
                        ...updated,
                      };
                    });
                    widget.onProfileUpdated?.call(_profile!);

                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.tr('ward_update_success'))),
                    );
                  },
                  child: Text(l10n.tr('save_changes')),
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
    final l10n = AppLocalizations.of(context);
    final isTa = _langCtrl.isTamil;

    final role = (_profile?['role'] ?? 'citizen').toString().toLowerCase();
    final isAdmin = role == 'admin';
    final isOfficer = role == 'field_officer';
    final isCitizen = !isAdmin && !isOfficer;

    final fullName = _profile?['full_name'] ??
        (isAdmin
            ? 'Municipal Administrator'
            : isOfficer
                ? 'Er. K. Sivakumar'
                : 'Namma Ooru Citizen');

    final email = _profile?['email'] ??
        (isAdmin
            ? 'admin@gcc.gov.in'
            : isOfficer
                ? 'officer.sivakumar@gcc.gov.in'
                : 'citizen@nammaooru.ai');

    final phone = _profile?['phone'] ??
        (isAdmin
            ? '+91 94440 00001'
            : isOfficer
                ? '+91 98400 12345'
                : '+91 98400 00002');

    final city = _profile?['city'] ?? 'Chennai';
    final muni = _profile?['municipality'] ??
        _profile?['municipality_name'] ??
        'Greater Chennai Corporation (GCC)';
    final zone = _profile?['zone'] ??
        (isOfficer ? 'Zone 5 (Royapuram)' : 'Zone 8 (Anna Nagar)');
    final wardNum = _profile?['ward_number'] ?? 'Ward 104';
    final wardName = _profile?['ward_name'] ?? 'Aminjikarai';

    return RefreshIndicator(
      onRefresh: _refreshProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: LinearProgressIndicator(minHeight: 3),
              ),
            const SizedBox(height: AppSpacing.sm),

            // Profile Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppSpacing.roundedMd,
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: isAdmin
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : isOfficer
                            ? AppColors.warningLight
                            : AppColors.accent,
                    child: Icon(
                      isAdmin
                          ? Icons.admin_panel_settings
                          : isOfficer
                              ? Icons.engineering
                              : Icons.person,
                      size: 46,
                      color: isAdmin
                          ? AppColors.secondary
                          : isOfficer
                              ? AppColors.warning
                              : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    fullName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$phone • $city',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Role Badge Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAdmin
                          ? AppColors.secondary.withValues(alpha: 0.1)
                          : isOfficer
                              ? AppColors.warningLight
                              : AppColors.successLight,
                      borderRadius: AppSpacing.roundedPill,
                      border: Border.all(
                        color: isAdmin
                            ? AppColors.secondary
                            : isOfficer
                                ? AppColors.warning
                                : AppColors.success,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          size: 14,
                          color: isAdmin
                              ? AppColors.secondary
                              : isOfficer
                                  ? AppColors.warning
                                  : AppColors.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAdmin
                              ? (isTa
                                  ? 'அங்கீகரிக்கப்பட்ட நகராட்சி நிர்வாகி'
                                  : 'Municipal Administrator • GCC')
                              : isOfficer
                                  ? (isTa
                                      ? 'களப்பணி பொறியாளர் / அதிகாரி'
                                      : 'Certified Field Officer • Ground Operations')
                                  : (isTa
                                      ? 'சரிபார்க்கப்பட்ட குடிமகன்'
                                      : 'Verified Resident Citizen'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isAdmin
                                ? AppColors.secondary
                                : isOfficer
                                    ? AppColors.warning
                                    : AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Profile Details Card
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email_outlined,
                        color: AppColors.primary),
                    title: Text(isTa ? 'மின்னஞ்சல் முகவரி' : 'Email Address'),
                    subtitle: Text(email),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.phone_outlined, color: AppColors.primary),
                    title: Text(isTa ? 'தொலைபேசி எண்' : 'Phone Number'),
                    subtitle: Text(phone),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.language, color: AppColors.primary),
                    title: Text(l10n.tr('language_preference')),
                    subtitle: Text(_langCtrl.isTamil
                        ? 'தமிழ் (Tamil) • செயலில்'
                        : 'English • Active'),
                    trailing: TextButton.icon(
                      icon: const Icon(Icons.translate, size: 16),
                      label: Text(_langCtrl.isTamil
                          ? 'Switch to English'
                          : 'தமிழுக்கு மாறு'),
                      onPressed: () => _langCtrl.toggleLanguage(),
                    ),
                  ),
                  const Divider(height: 1),

                  // Jurisdiction / Location Section
                  ListTile(
                    leading: const Icon(Icons.location_city,
                        color: AppColors.primary),
                    title: Text(isTa
                        ? 'அதிகார வரம்பு மற்றும் வார்டு'
                        : 'Civic Jurisdiction & Ward'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(muni,
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                        Text(
                          isCitizen
                              ? '$zone • $wardNum: $wardName'
                              : isAdmin
                                  ? 'Central Governance & GCC Command Center'
                                  : 'Assigned to $zone Ground Operations',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),

                  // Change Ward Action (Citizen only)
                  if (isCitizen)
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 12),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            icon: const Icon(Icons.edit_location_alt, size: 16),
                            label: Text(
                              l10n.tr('change_ward_request'),
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () =>
                                _showWardCorrectionDialog(context, l10n),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Role Security Information Banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.3),
                borderRadius: AppSpacing.roundedSm,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isTa
                              ? 'பாதுகாப்பான அணுகல் கட்டுப்பாடு (RBAC)'
                              : 'Backend-Enforced Role Security (RBAC)',
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isTa
                              ? 'உங்கள் கணக்கு அனுமதிகள் மற்றும் பாத்திரங்கள் சேவையகத்தில் JWT அங்கீகாரத்துடன் சரிபார்க்கப்படுகின்றன.'
                              : 'Your account permissions are cryptographically verified by the FastAPI backend server on every request.',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Sign Out / Logout Button
            AppButton(
              label: l10n.tr('logout'),
              leadingIcon: Icons.logout,
              variant: AppButtonVariant.danger,
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
                  widget.onLogout();
                }
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
