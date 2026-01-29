import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum StatusType { available, lowStock, outOfStock }

class StatusIndicator extends StatelessWidget {
  final StatusType type;
  final String label;
  final int? count;
  final bool showCount;

  const StatusIndicator({
    super.key,
    required this.type,
    required this.label,
    this.count,
    this.showCount = false,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case StatusType.available:
        backgroundColor = AppTheme.successGreen;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case StatusType.lowStock:
        backgroundColor = AppTheme.warningOrange;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case StatusType.outOfStock:
        backgroundColor = AppTheme.errorRed;
        textColor = Colors.white;
        icon = Icons.error;
        break;
    }

    if (showCount) {
      // Detailed scheme - outlined style
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: backgroundColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: backgroundColor),
            const SizedBox(width: 6),
            Text(
              '$label${count != null ? ' ($count)' : ''}',
              style: TextStyle(
                color: backgroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    } else {
      // Full fill style
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }
}
