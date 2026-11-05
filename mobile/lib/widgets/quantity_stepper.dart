import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 999,
    this.compact = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 28.0 : 36.0;
    return Container(
      height: size,
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _button(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
            size: size,
          ),
          SizedBox(
            width: compact ? 26 : 34,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppText.body(
                size: compact ? 12 : 14,
                weight: FontWeight.w600,
              ),
            ),
          ),
          _button(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
            size: size,
          ),
        ],
      ),
    );
  }

  Widget _button({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required double size,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        child: Icon(
          icon,
          size: compact ? 15 : 18,
          color: enabled ? AppColors.black : AppColors.line,
        ),
      ),
    );
  }
}
