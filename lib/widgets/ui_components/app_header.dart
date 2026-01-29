import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<String>? breadcrumbs;
  final Widget? trailing;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;

  const AppHeader({
    super.key,
    this.title,
    this.subtitle,
    this.breadcrumbs,
    this.trailing,
    this.searchHint,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.darkSurfaceVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.help_outline, color: AppTheme.textSecondary, size: 20),
                onPressed: () {},
                tooltip: 'مساعدة',
              ),
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: AppTheme.textSecondary, size: 20),
                onPressed: () {},
                tooltip: 'الإشعارات',
              ),
              const Spacer(),
              if (searchHint != null)
                SizedBox(
                  width: 400,
                  child: TextField(
                    onChanged: onSearchChanged,
                    decoration: InputDecoration(
                      hintText: searchHint,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: AppTheme.darkSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              if (searchHint != null) const SizedBox(width: 16),
              if (title != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title!,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              if (title != null) const SizedBox(width: 16),
              Icon(Icons.list, color: AppTheme.textSecondary),
              if (trailing != null) ...[
                const SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
          if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                ...breadcrumbs!.asMap().entries.map((entry) {
                  final isLast = entry.key == breadcrumbs!.length - 1;
                  return Row(
                    children: [
                      Text(
                        entry.value,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isLast
                              ? AppTheme.textPrimary
                              : AppTheme.textSecondary,
                          fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_left,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
