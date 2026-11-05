import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

Future<void> showLanguageSheet(BuildContext context) async {
  final settings = context.read<SettingsProvider>();
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Til / Язык / Language', style: AppText.display(size: 17)),
              const SizedBox(height: 10),
              for (final code in SettingsProvider.supportedLanguages)
                ListTile(
                  onTap: () async {
                    await settings.setLanguage(code);
                    if (sheetContext.mounted) {
                      Navigator.of(sheetContext).pop();
                    }
                  },
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    settings.languageLabel(code),
                    style: AppText.body(
                      size: 15,
                      weight: settings.language == code
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: settings.language == code
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.red,
                          size: 20,
                        )
                      : null,
                ),
            ],
          ),
        ),
      );
    },
  );
}
