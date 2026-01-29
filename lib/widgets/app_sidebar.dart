import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/models/app_route.dart';
import '../core/theme/app_theme.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    final theme = Theme.of(context);
    final width = _isExpanded ? 280.0 : 80.0;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
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
            padding: const EdgeInsets.all(20),
            child: _isExpanded
                ? Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTealDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'نكسوس MS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  )
                : Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
          ),
          
          // User Profile Section (only when expanded)
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.warningOrange.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: AppTheme.warningOrange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'أحمد السيد',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'مدير الخدمات اللوجستية',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          const Divider(height: 1),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (_isExpanded)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'القائمة الرئيسية',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ...AppRoute.values.take(3).map((route) {
                  final isSelected = currentLocation == route.path;
                  final label = isRTL ? route.arabicLabel : route.englishLabel;
                  return _SidebarItem(
                    route: route,
                    label: label,
                    isSelected: isSelected,
                    isRTL: isRTL,
                    isExpanded: _isExpanded,
                    onTap: () => context.go(route.path),
                  );
                }),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text(
                      'الإدارة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ...AppRoute.values.skip(3).take(2).map((route) {
                    final isSelected = currentLocation == route.path;
                    final label = isRTL ? route.arabicLabel : route.englishLabel;
                    return _SidebarItem(
                      route: route,
                      label: label,
                      isSelected: isSelected,
                      isRTL: isRTL,
                      isExpanded: _isExpanded,
                      onTap: () => context.go(route.path),
                    );
                  }),
                  if (_isExpanded) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'النظام',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _SidebarItem(
                      route: AppRoute.settings,
                      label: isRTL ? AppRoute.settings.arabicLabel : AppRoute.settings.englishLabel,
                      isSelected: currentLocation == AppRoute.settings.path,
                      isRTL: isRTL,
                      isExpanded: _isExpanded,
                      onTap: () => context.go(AppRoute.settings.path),
                    ),
                  ],
                ],
              ],
            ),
          ),
          
          // Collapse/Expand Button
          Padding(
            padding: const EdgeInsets.all(12),
            child: IconButton(
              icon: Icon(
                _isExpanded ? Icons.chevron_right : Icons.chevron_left,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
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
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.route,
    required this.label,
    required this.isSelected,
    required this.isRTL,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected
            ? AppTheme.primaryTeal.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? 16 : 12,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              children: [
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                if (isSelected) const SizedBox(width: 12),
                Icon(
                  route.icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.primaryTeal
                      : AppTheme.textSecondary,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      textAlign: isRTL ? TextAlign.right : TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label.split(' ').first, // Show first word only in collapsed mode
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
