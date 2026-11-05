import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n.dart';
import '../providers/settings_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../utils/ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  bool _saving = false;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(
      text: context.read<SettingsProvider>().baseUrl,
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }
    setState(() => _saving = true);
    final settings = context.read<SettingsProvider>();
    final ok = await settings.setBaseUrl(_urlController.text);
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    if (!ok) {
      showAppSnack(
        context,
        "Manzil noto'g'ri. Masalan: http://192.168.1.10:8000/api",
        error: true,
      );
      return;
    }
    _urlController.text = settings.baseUrl;
    showAppSnack(context, context.tr('save'));
  }

  Future<void> _testConnection() async {
    if (_testing) {
      return;
    }
    await _save();
    if (!mounted) {
      return;
    }
    setState(() => _testing = true);
    try {
      await context.read<ApiClient>().get('/');
      if (mounted) {
        showAppSnack(context, context.tr('connectionOk'));
      }
    } on ApiException catch (error) {
      if (mounted) {
        showAppSnack(
          context,
          '${context.tr('connectionFailed')}: ${error.message}',
          error: true,
        );
      }
    } catch (error) {
      if (mounted) {
        showAppSnack(context, error.toString(), error: true);
      }
    } finally {
      if (mounted) {
        setState(() => _testing = false);
      }
    }
  }

  Future<void> _reset() async {
    await context.read<SettingsProvider>().resetBaseUrl();
    if (mounted) {
      _urlController.text = context.read<SettingsProvider>().baseUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(context.tr('settings'), style: AppText.display(size: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Text(
            context.tr('serverSettings'),
            style: AppText.display(size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.tr('serverHint'),
            style: AppText.body(
              size: 12,
              color: AppColors.muted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: context.tr('serverUrl'),
              hintText: context.tr('serverUrlHint'),
              prefixIcon: const Icon(Icons.link_rounded),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: Text(context.tr('save')),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _testing ? null : _testConnection,
            icon: _testing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.black,
                    ),
                  )
                : const Icon(Icons.wifi_tethering_rounded, size: 18),
            label: Text(context.tr('testConnection')),
          ),
          const SizedBox(height: 6),
          TextButton(
            onPressed: _reset,
            child: Text(context.tr('reset')),
          ),
          const Divider(height: 34),
          Text(
            context.tr('language'),
            style: AppText.display(size: 16),
          ),
          const SizedBox(height: 6),
          for (final code in SettingsProvider.supportedLanguages)
            InkWell(
              onTap: () => settings.setLanguage(code),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        settings.languageLabel(code),
                        style: AppText.body(
                          size: 14,
                          weight: settings.language == code
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    if (settings.language == code)
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 19,
                        color: AppColors.red,
                      ),
                  ],
                ),
              ),
            ),
          const Divider(height: 34),
          Text(context.tr('about'), style: AppText.display(size: 16)),
          const SizedBox(height: 8),
          Text(
            "Quvvat — uy va ob'ektlar uchun santexnika jihozlari onlayn do'koni. "
            "Ilova orqali katalog, savat va buyurtmalarni boshqaring.",
            style: AppText.body(
              size: 13,
              color: AppColors.muted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${context.tr('version')}: 1.0.0',
            style: AppText.body(size: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
