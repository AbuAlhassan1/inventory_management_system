import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AppToggleSwitch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool isEnabled;

  const AppToggleSwitch({
    super.key,
    required this.label,
    required this.value,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isEnabled ? AppTheme.textPrimary : AppTheme.textTertiary,
            fontSize: 14,
          ),
        ),
        Switch(
          value: value,
          onChanged: isEnabled ? onChanged : null,
          activeColor: AppTheme.primaryTeal,
        ),
      ],
    );
  }
}
