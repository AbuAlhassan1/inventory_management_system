import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import '../core/theme/app_theme.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: isRTL
              ? [
                  // RTL: Sidebar first (appears on right), content second (appears on left)
                  const AppSidebar(),
                  Expanded(
                    child: Container(
                      color: AppTheme.darkBackground,
                      child: child,
                    ),
                  ),
                ]
              : [
                  // LTR: Content first (appears on left), sidebar second (appears on right)
                  Expanded(
                    child: Container(
                      color: AppTheme.darkBackground,
                      child: child,
                    ),
                  ),
                  const AppSidebar(),
                ],
        ),
      ),
    );
  }
}
