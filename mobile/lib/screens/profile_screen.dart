import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/api_config.dart';
import '../l10n/l10n.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/ui.dart';
import '../widgets/app_logo.dart';
import '../widgets/language_sheet.dart';
import 'login_screen.dart';
import 'orders_screen.dart';
import 'register_screen.dart';
import 'settings_screen.dart';
import 'wishlist_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            if (auth.isLoggedIn)
              _loggedInHeader(context, auth)
            else
              _guestHeader(context),
            const SizedBox(height: 22),
            if (auth.isLoggedIn) ...[
              _menuTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: context.tr('myOrders'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
                },
              ),
              _menuTile(
                context,
                icon: Icons.favorite_border_rounded,
                title: context.tr('wishlist'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const WishlistScreen()),
                  );
                },
              ),
            ],
            _menuTile(
              context,
              icon: Icons.settings_outlined,
              title: context.tr('settings'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _menuTile(
              context,
              icon: Icons.language_rounded,
              title: context.tr('language'),
              value: context
                  .watch<SettingsProvider>()
                  .languageLabel(context.watch<SettingsProvider>().language),
              onTap: () => showLanguageSheet(context),
            ),
            const SizedBox(height: 6),
            _menuTile(
              context,
              icon: Icons.admin_panel_settings_outlined,
              iconColor: AppColors.red,
              title: context.tr('adminLogin'),
              onTap: () => _openAdminPanel(context),
            ),
            const SizedBox(height: 18),
            if (auth.isLoggedIn)
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await confirmDialog(
                    context,
                    title: context.tr('logout'),
                    message: context.tr('logoutConfirm'),
                    confirmLabel: context.tr('logout'),
                    destructive: true,
                  );
                  if (!confirmed || !context.mounted) {
                    return;
                  }
                  await auth.logout();
                  if (context.mounted) {
                    showAppSnack(context, context.tr('logoutSuccess'));
                  }
                },
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(context.tr('logout')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                ),
              ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Quvvat · ${context.tr('version')} 1.0.0',
                style: AppText.body(size: 11, color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Django admin panelini brauzerda ochadi — admin login o'sha yerda.
  Future<void> _openAdminPanel(BuildContext context) async {
    final failedMessage = context.tr('adminOpenFailed');
    final origin = ApiConfig.origin;
    if (origin.isEmpty) {
      showAppSnack(context, failedMessage, error: true);
      return;
    }
    try {
      final opened = await launchUrl(
        Uri.parse('$origin/admin/'),
        mode: LaunchMode.externalApplication,
      );
      if (!opened && context.mounted) {
        showAppSnack(context, failedMessage, error: true);
      }
    } catch (_) {
      if (context.mounted) {
        showAppSnack(context, failedMessage, error: true);
      }
    }
  }

  Widget _guestHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(size: 36),
        const SizedBox(height: 28),
        Text(
          context.tr('profileGuestTitle'),
          style: AppText.display(size: 23),
        ),
        const SizedBox(height: 8),
        Text(
          context.tr('profileGuestText'),
          style: AppText.body(size: 14, color: AppColors.muted),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: Text(context.tr('login')),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: Text(context.tr('register')),
        ),
      ],
    );
  }

  Widget _loggedInHeader(BuildContext context, AuthProvider auth) {
    final user = auth.user;
    final name = user?.fullName ?? user?.username ?? '';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  user?.initial ?? 'Q',
                  style: AppText.display(size: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.display(size: 17, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '@${user?.username ?? ''}',
                      style: AppText.body(
                        size: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((user?.phone.isNotEmpty ?? false) ||
              (user?.email.isNotEmpty ?? false)) ...[
            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 12),
            if (user!.phone.isNotEmpty)
              _contactRow(Icons.phone_outlined, user.phone),
            if (user.email.isNotEmpty)
              _contactRow(Icons.mail_outline_rounded, user.email),
          ],
          if ((user?.dateJoined ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${context.tr('memberSince')}: ${formatDate(user!.dateJoined).split(' ').first}',
              style: AppText.body(size: 11, color: Colors.white54),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(size: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? value,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor ?? AppColors.ink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppText.body(
                      size: 14,
                      weight: FontWeight.w500,
                    ),
                  ),
                ),
                if (value != null)
                  Text(
                    value,
                    style: AppText.body(
                      size: 12,
                      color: AppColors.muted,
                    ),
                  ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
