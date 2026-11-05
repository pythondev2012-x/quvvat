import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36, this.showText = true});

  final double size;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.red,
            borderRadius: BorderRadius.circular(size * 0.22),
          ),
          alignment: Alignment.center,
          child: Text(
            'Q',
            style: AppText.display(
              size: size * 0.58,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Text(
            'QUVVAT',
            style: AppText.display(size: size * 0.55, letterSpacing: -0.8),
          ),
        ],
      ],
    );
  }
}
