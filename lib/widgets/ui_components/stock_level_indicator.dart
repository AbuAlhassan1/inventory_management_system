import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'status_indicator.dart';

class StockLevelIndicator extends StatelessWidget {
  final int currentStock;
  final int? maxStock;
  final double? width;
  final bool showLabel;

  const StockLevelIndicator({
    super.key,
    required this.currentStock,
    this.maxStock,
    this.width,
    this.showLabel = true,
  });

  StatusType _getStatusType() {
    if (currentStock == 0) {
      return StatusType.outOfStock;
    } else if (currentStock < 10) {
      return StatusType.lowStock;
    } else {
      return StatusType.available;
    }
  }

  Color _getColor() {
    final status = _getStatusType();
    switch (status) {
      case StatusType.available:
        return AppTheme.successGreen;
      case StatusType.lowStock:
        return AppTheme.warningOrange;
      case StatusType.outOfStock:
        return AppTheme.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMaxStock = maxStock ?? 200;
    final stockPercentage = (currentStock / effectiveMaxStock).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: width ?? 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stockPercentage,
              backgroundColor: AppTheme.darkSurfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_getColor()),
              minHeight: 8,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 8),
          Text(
            '$currentStock',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
