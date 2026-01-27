import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/app_route.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final theme = Theme.of(context);
    
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          left: isRTL
              ? BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1)
              : BorderSide.none,
          right: isRTL
              ? BorderSide.none
              : BorderSide(color: theme.colorScheme.outline.withOpacity(0.2), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo/Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Align(
              alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
              child: Text(
                'LIPS',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: AppRoute.values.map((route) {
                final isSelected = currentLocation == route.path;
                final label = isRTL ? route.arabicLabel : route.englishLabel;
                return _SidebarItem(
                  route: route,
                  label: label,
                  isSelected: isSelected,
                  isRTL: isRTL,
                  onTap: () => context.go(route.path),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final AppRoute route;
  final String label;
  final bool isSelected;
  final bool isRTL;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.route,
    required this.label,
    required this.isSelected,
    required this.isRTL,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Icon(
                  route.icon,
                  size: 20,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
