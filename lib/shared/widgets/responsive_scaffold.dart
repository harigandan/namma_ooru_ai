import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class NavigationDestinationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const NavigationDestinationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Responsive Scaffold that switches between BottomNavigationBar (Mobile) and NavigationRail/Sidebar (Tablet/Desktop)
class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestinationItem> destinations;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? headerWidget;

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.headerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < AppSpacing.mobileBreakpoint;
        final isDesktop = constraints.maxWidth >= AppSpacing.tabletBreakpoint;

        if (isMobile) {
          return Scaffold(
            appBar: appBar,
            body: body,
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              backgroundColor: AppColors.surface,
              indicatorColor: AppColors.accent,
              destinations: destinations.map((d) {
                return NavigationDestination(
                  icon: Icon(d.icon, color: AppColors.textSecondary),
                  selectedIcon: Icon(d.selectedIcon, color: AppColors.primary),
                  label: d.label,
                );
              }).toList(),
            ),
          );
        }

        // Tablet & Desktop view with NavigationRail / Sidebar
        return Scaffold(
          appBar: appBar,
          floatingActionButton: floatingActionButton,
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: isDesktop
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.all,
                extended: isDesktop,
                backgroundColor: AppColors.surface,
                indicatorColor: AppColors.accent,
                leading: headerWidget != null
                    ? Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: headerWidget!,
                      )
                    : null,
                destinations: destinations.map((d) {
                  return NavigationRailDestination(
                    icon: Icon(d.icon, color: AppColors.textSecondary),
                    selectedIcon:
                        Icon(d.selectedIcon, color: AppColors.primary),
                    label: Text(
                      d.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const VerticalDivider(
                  width: 1, thickness: 1, color: AppColors.border),
              Expanded(child: body),
            ],
          ),
        );
      },
    );
  }
}
