import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

/// Citizen & Authorized Personnel Registration Screen with Municipality -> Zone -> Ward Cascading
class RegisterScreen extends StatefulWidget {
  final Function(String role) onRegisterSuccess;

  const RegisterScreen({
    super.key,
    required this.onRegisterSuccess,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _cityController = TextEditingController(text: 'Chennai');
  final _authCodeController = TextEditingController();
  final _wardSearchController = TextEditingController();

  String _selectedRole = 'citizen';
  String _preferredLanguage = 'ta';
  bool _isLoading = false;
  String? _errorMessage;

  // Geography cascading data
  List<Map<String, dynamic>> _municipalities = [];
  String? _selectedMunicipalityId;
  String? _selectedMunicipalityName;

  List<Map<String, dynamic>> _zones = [];
  String? _selectedZoneId;
  String? _selectedZoneName;

  List<Map<String, dynamic>> _wards = [];
  List<Map<String, dynamic>> _filteredWards = [];
  String? _selectedWardId;
  String? _selectedWardNumber;
  bool _isLoadingGeography = true;

  @override
  void initState() {
    super.initState();
    _loadGeographyData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _cityController.dispose();
    _authCodeController.dispose();
    _wardSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadGeographyData() async {
    setState(() => _isLoadingGeography = true);
    try {
      final munis = await ApiService().getMunicipalities();
      if (!mounted) return;
      setState(() {
        _municipalities = munis;
        if (munis.isNotEmpty) {
          _selectedMunicipalityId = munis.first['id'];
          _selectedMunicipalityName = munis.first['name'];
        }
      });

      if (_selectedMunicipalityId != null) {
        await _loadZonesForMunicipality(_selectedMunicipalityId!);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoadingGeography = false);
    }
  }

  Future<void> _loadZonesForMunicipality(String muniId) async {
    try {
      final zones = await ApiService().getZones(municipalityId: muniId);
      if (!mounted) return;
      setState(() {
        _zones = zones;
        if (zones.isNotEmpty) {
          _selectedZoneId = zones.first['id'];
          _selectedZoneName = zones.first['name'];
        } else {
          _selectedZoneId = null;
          _selectedZoneName = null;
        }
      });

      if (_selectedZoneId != null) {
        await _loadWardsForZone(_selectedZoneId!);
      }
    } catch (_) {}
  }

  Future<void> _loadWardsForZone(String zoneId) async {
    try {
      final wards = await ApiService().getWards(zoneId: zoneId);
      if (!mounted) return;
      setState(() {
        _wards = wards;
        _filteredWards = wards;
        if (wards.isNotEmpty) {
          _selectedWardId = wards.first['id'];
          _selectedWardNumber = wards.first['ward_number'];
        } else {
          _selectedWardId = null;
          _selectedWardNumber = null;
        }
      });
    } catch (_) {}
  }

  void _filterWards(String query) {
    if (query.isEmpty) {
      setState(() => _filteredWards = _wards);
      return;
    }
    final q = query.toLowerCase();
    setState(() {
      _filteredWards = _wards.where((w) {
        final num = (w['ward_number'] ?? '').toString().toLowerCase();
        final name = (w['ward_name'] ?? '').toString().toLowerCase();
        final nameTa = (w['ward_name_ta'] ?? '').toString().toLowerCase();
        return num.contains(q) || name.contains(q) || nameTa.contains(q);
      }).toList();
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'citizen' && (_selectedWardId == null || _selectedWardId!.isEmpty)) {
      setState(() {
        _errorMessage = 'Please select a valid residential ward to continue.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService().register(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        city: _cityController.text.trim(),
        municipality: _selectedMunicipalityName,
        zone: _selectedZoneName,
        wardId: _selectedWardId,
        wardNumber: _selectedWardNumber,
        role: _selectedRole,
        authorizationCode:
            _selectedRole != 'citizen' ? _authCodeController.text.trim() : null,
      );

      final role = res['role'] as String? ?? 'citizen';

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.of(context).pop(); // Dismiss register screen
      widget.onRegisterSuccess(role);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTa = l10n.isTamil;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.tr('register_title'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Subtitle
                    Text(
                      l10n.tr('register_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Error Banner
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: AppSpacing.roundedSm,
                          border: Border.all(
                              color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                color: AppColors.error, size: 20),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Full Name
                    AppTextField(
                      label: l10n.tr('full_name'),
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline,
                          color: AppColors.primary),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Phone Number
                    AppTextField(
                      label: l10n.tr('phone_number'),
                      controller: _phoneController,
                      prefixIcon: const Icon(Icons.phone_outlined,
                          color: AppColors.primary),
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        if (val.trim().length < 10) {
                          return l10n.tr('validation_phone');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email Address
                    AppTextField(
                      label: l10n.tr('email_or_phone'),
                      controller: _emailController,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.primary),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        if (!val.contains('@')) {
                          return l10n.tr('validation_email');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    AppTextField(
                      label: l10n.tr('password'),
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: AppColors.primary),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        if (val.length < 6) {
                          return l10n.tr('validation_password_len');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password
                    AppTextField(
                      label: l10n.tr('confirm_password'),
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_reset_outlined,
                          color: AppColors.primary),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        if (val != _passwordController.text) {
                          return l10n.tr('validation_password_match');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Account Role Selector
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        labelText: l10n.tr('account_role'),
                        border: OutlineInputBorder(
                            borderRadius: AppSpacing.roundedSm),
                        prefixIcon: const Icon(Icons.badge_outlined,
                            color: AppColors.primary),
                      ),
                      items: [
                        DropdownMenuItem(
                            value: 'citizen', child: Text(l10n.tr('citizen'))),
                        DropdownMenuItem(
                            value: 'admin',
                            child: Text('${l10n.tr('admin')} (Official)')),
                        DropdownMenuItem(
                            value: 'field_officer',
                            child:
                                Text('${l10n.tr('field_officer')} (Official)')),
                      ],
                      onChanged: (val) =>
                          setState(() => _selectedRole = val ?? 'citizen'),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Authorization Code Field (if admin or officer)
                    if (_selectedRole != 'citizen') ...[
                      AppTextField(
                        label: l10n.tr('auth_code_optional'),
                        controller: _authCodeController,
                        prefixIcon: const Icon(Icons.security,
                            color: Color(0xFF7C3AED)),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Official invite authorization code required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _selectedRole == 'admin'
                            ? 'Hint: TN-ADMIN-2026'
                            : 'Hint: TN-OFFICER-2026',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Section: Resident Ward Location (For Citizens)
                    if (_selectedRole == 'citizen') ...[
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
                              children: [
                                const Icon(Icons.location_on,
                                    color: AppColors.primary, size: 18),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  isTa ? 'வசிப்பிட வார்டு விவரங்கள்' : 'Jurisdiction & Ward Selection',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isTa
                                  ? 'உங்கள் மாமன்ற வார்டைத் தேர்வு செய்வதன் மூலம் பகுதி அளவிலான சேவைகளைப் பெறலாம்.'
                                  : 'Select Corporation, Zone and Ward to register with municipal jurisdiction.',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.textSecondary),
                            ),
                            if (_isLoadingGeography) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: LinearProgressIndicator(),
                              ),
                            ],
                            const SizedBox(height: AppSpacing.sm),

                            // 1. Municipality Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedMunicipalityId,
                              decoration: InputDecoration(
                                labelText: l10n.tr('municipality_label'),
                                border: OutlineInputBorder(
                                    borderRadius: AppSpacing.roundedSm),
                                prefixIcon: const Icon(Icons.apartment,
                                    color: AppColors.primary, size: 20),
                              ),
                              items: _municipalities.map((m) {
                                final label = isTa ? (m['name_ta'] ?? m['name']) : m['name'];
                                return DropdownMenuItem<String>(
                                  value: m['id'],
                                  child: Text(label, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (mId) {
                                if (mId != null && mId != _selectedMunicipalityId) {
                                  final m = _municipalities.firstWhere((x) => x['id'] == mId);
                                  setState(() {
                                    _selectedMunicipalityId = mId;
                                    _selectedMunicipalityName = m['name'];
                                  });
                                  _loadZonesForMunicipality(mId);
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 2. Zone Dropdown
                            DropdownButtonFormField<String>(
                              initialValue: _selectedZoneId,
                              decoration: InputDecoration(
                                labelText: l10n.tr('zone_label'),
                                border: OutlineInputBorder(
                                    borderRadius: AppSpacing.roundedSm),
                                prefixIcon: const Icon(Icons.map_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                              items: _zones.map((z) {
                                final label = isTa ? (z['name_ta'] ?? z['name']) : z['name'];
                                return DropdownMenuItem<String>(
                                  value: z['id'],
                                  child: Text(label, style: const TextStyle(fontSize: 13)),
                                );
                              }).toList(),
                              onChanged: (zId) {
                                if (zId != null && zId != _selectedZoneId) {
                                  final z = _zones.firstWhere((x) => x['id'] == zId);
                                  setState(() {
                                    _selectedZoneId = zId;
                                    _selectedZoneName = z['name'];
                                  });
                                  _loadWardsForZone(zId);
                                }
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // 3. Ward Search / Filter Bar
                            TextField(
                              controller: _wardSearchController,
                              onChanged: _filterWards,
                              decoration: InputDecoration(
                                hintText: l10n.tr('search_ward_hint'),
                                prefixIcon: const Icon(Icons.search, size: 18),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                    borderRadius: AppSpacing.roundedSm),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            // 4. Ward Dropdown Selector
                            DropdownButtonFormField<String>(
                              initialValue: _selectedWardId,
                              decoration: InputDecoration(
                                labelText: l10n.tr('ward_label'),
                                border: OutlineInputBorder(
                                    borderRadius: AppSpacing.roundedSm),
                                prefixIcon: const Icon(Icons.pin_drop_outlined,
                                    color: AppColors.primary, size: 20),
                              ),
                              items: _filteredWards.map((w) {
                                final wNum = w['ward_number'] ?? '';
                                final wName = isTa ? (w['ward_name_ta'] ?? w['ward_name']) : w['ward_name'];
                                return DropdownMenuItem<String>(
                                  value: w['id'],
                                  child: Text(
                                    '$wNum: $wName',
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (wId) {
                                if (wId != null) {
                                  final w = _wards.firstWhere((x) => x['id'] == wId);
                                  setState(() {
                                    _selectedWardId = wId;
                                    _selectedWardNumber = w['ward_number'];
                                  });
                                }
                              },
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return l10n.tr('validation_ward_required');
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Preferred Language Selector
                    DropdownButtonFormField<String>(
                      initialValue: _preferredLanguage,
                      decoration: InputDecoration(
                        labelText: l10n.tr('preferred_language_label'),
                        border: OutlineInputBorder(
                            borderRadius: AppSpacing.roundedSm),
                        prefixIcon: const Icon(Icons.language,
                            color: AppColors.primary),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'ta', child: Text('தமிழ் (Tamil)')),
                        DropdownMenuItem(
                            value: 'en', child: Text('English')),
                      ],
                      onChanged: (val) =>
                          setState(() => _preferredLanguage = val ?? 'ta'),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Register Button
                    AppButton(
                      label: l10n.tr('sign_up'),
                      leadingIcon: Icons.how_to_reg,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleRegister,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Back to Sign In
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          l10n.tr('already_have_account'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
