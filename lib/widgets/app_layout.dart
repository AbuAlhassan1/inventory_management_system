import 'package:flutter/material.dart';
import 'app_sidebar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isRTL = locale.languageCode == 'ar';
    
    return Scaffold(
      body: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Row(
          children: isRTL
              ? [
                  // RTL: Sidebar first (appears on right), content second (appears on left)
                  const AppSidebar(),
                  Expanded(child: child),
                ]
              : [
                  // LTR: Content first (appears on left), sidebar second (appears on right)
                  Expanded(child: child),
                  const AppSidebar(),
                ],
        ),
      ),
    );
  }
}
