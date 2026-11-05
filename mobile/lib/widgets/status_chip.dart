import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status, required this.label});

  final int status;
  final String label;

  Color get _color {
    switch (status) {
      case 2:
        return AppColors.orange;
      case 3:
        return AppColors.blue;
      case 4:
        return AppColors.green;
      case 5:
        return AppColors.muted;
      default:
        return AppColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.body(
          size: 11,
          weight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}
