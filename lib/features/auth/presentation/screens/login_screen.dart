import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import 'register_screen.dart';

/// Secure Production Login Screen with Tamil/English Localization & RBAC Routing
class LoginScreen extends StatefulWidget {
  final Function(String role) onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController =
      TextEditingController(text: 'citizen@nammaooru.ai');
  final _passwordController = TextEditingController(text: 'Citizen@123');

  bool _rememberSession = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    LanguageController().addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LanguageController().removeListener(_onLanguageChanged);
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillDevCredentials(String role) {
    setState(() {
      _errorMessage = null;
      switch (role) {
        case 'citizen':
          _identifierController.text = 'citizen@nammaooru.ai';
          _passwordController.text = 'Citizen@123';
          break;
        case 'admin':
          _identifierController.text = 'admin@nammaooru.ai';
          _passwordController.text = 'Admin@123';
          break;
        case 'officer':
          _identifierController.text = 'officer@nammaooru.ai';
          _passwordController.text = 'Officer@123';
          break;
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await ApiService().login(
        emailOrPhone: _identifierController.text.trim(),
        password: _passwordController.text,
      );

      final role = res['role'] as String? ?? 'citizen';

      if (!mounted) return;
      setState(() => _isLoading = false);

      widget.onLoginSuccess(role);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _showForgotPasswordDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.roundedMd),
        title: Row(
          children: [
            const Icon(Icons.help_outline, color: AppColors.primary),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                l10n.tr('forgot_password_dialog_title'),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          l10n.tr('forgot_password_dialog_msg'),
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.tr('close')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCtrl = LanguageController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Language Switcher Toggle
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.md, top: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppSpacing.roundedPill,
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangButton('தமிழ்', 'ta', langCtrl),
                _buildLangButton('English', 'en', langCtrl),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Header
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              width: 2),
                        ),
                        child: const Icon(
                          Icons.location_city,
                          size: 44,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.tr('app_name'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.tr('app_subtitle'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.tr('tagline'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Quick Test Accounts Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: AppSpacing.roundedSm,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.flash_on,
                                  size: 14, color: AppColors.warning),
                              const SizedBox(width: 4),
                              Text(
                                l10n.tr('quick_dev_accounts'),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              ActionChip(
                                label: Text(l10n.tr('citizen'),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                                avatar: const Icon(Icons.person,
                                    size: 14, color: AppColors.primary),
                                backgroundColor: AppColors.surface,
                                onPressed: () => _fillDevCredentials('citizen'),
                              ),
                              ActionChip(
                                label: Text(l10n.tr('admin'),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                                avatar: const Icon(Icons.admin_panel_settings,
                                    size: 14, color: Color(0xFF7C3AED)),
                                backgroundColor: AppColors.surface,
                                onPressed: () => _fillDevCredentials('admin'),
                              ),
                              ActionChip(
                                label: Text(l10n.tr('field_officer'),
                                    style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                                avatar: const Icon(Icons.engineering,
                                    size: 14, color: AppColors.warning),
                                backgroundColor: AppColors.surface,
                                onPressed: () => _fillDevCredentials('officer'),
                              ),
                            ],
                          ),
                        ],
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
                                size: 18, color: AppColors.error),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.error,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

                    // Email / Phone Field
                    AppTextField(
                      label: l10n.tr('email_or_phone'),
                      controller: _identifierController,
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: AppColors.primary),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return l10n.tr('validation_required');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password Field
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
                    const SizedBox(height: AppSpacing.xs),

                    // Remember & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _rememberSession,
                              activeColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) => setState(
                                  () => _rememberSession = val ?? true),
                            ),
                            Text(
                              l10n.tr('remember_session'),
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () =>
                              _showForgotPasswordDialog(context, l10n),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            l10n.tr('forgot_password'),
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Login Button
                    AppButton(
                      label: l10n.tr('sign_in'),
                      leadingIcon: Icons.login,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _handleLogin,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Registration Navigation Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => RegisterScreen(
                                onRegisterSuccess: (role) =>
                                    widget.onLoginSuccess(role),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          l10n.tr('dont_have_account'),
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

  Widget _buildLangButton(
      String label, String code, LanguageController langCtrl) {
    final isSelected = langCtrl.currentLocale.languageCode == code;
    return InkWell(
      onTap: () => langCtrl.setLanguage(code),
      borderRadius: AppSpacing.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppSpacing.roundedPill,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
