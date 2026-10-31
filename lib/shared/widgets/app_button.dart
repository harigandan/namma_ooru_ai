import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum AppButtonVariant { primary, secondary, outlined, text, danger }

/// Reusable branded button component supporting multiple variants, loading states, and icons
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = AppColors.textInverse;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.secondary;
        fgColor = AppColors.textInverse;
        break;
      case AppButtonVariant.outlined:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderSide = const BorderSide(color: AppColors.primary, width: 1.5);
        break;
      case AppButtonVariant.text:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.error;
        fgColor = AppColors.textInverse;
        break;
    }

    final content = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(fgColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, size: 18, color: fgColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: fgColor,
                  ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(trailingIcon, size: 18, color: fgColor),
              ],
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: onPressed == null ? AppColors.border : bgColor,
        borderRadius: AppSpacing.roundedSm,
        child: InkWell(
          onTap: (isLoading || onPressed == null) ? null : onPressed,
          borderRadius: AppSpacing.roundedSm,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: AppSpacing.roundedSm,
              border:
                  borderSide != null ? Border.fromBorderSide(borderSide) : null,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: content,
          ),
        ),
      ),
    );
  }
}
