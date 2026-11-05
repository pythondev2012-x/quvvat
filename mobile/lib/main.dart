import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/shell_controller.dart';
import 'providers/wishlist_provider.dart';
import 'screens/main_shell.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final settings = SettingsProvider();
  await settings.load();

  final api = ApiClient(languageProvider: () => settings.language);
  final auth = AuthProvider(api);
  await auth.restore();

  final cart = CartProvider(api);
  final wishlist = WishlistProvider(api);

  auth.addListener(() {
    cart.onAuthChanged(auth.isLoggedIn);
    wishlist.onAuthChanged(auth.isLoggedIn);
  });

  if (auth.isLoggedIn) {
    cart.refresh();
    wishlist.refresh();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ChangeNotifierProvider<CartProvider>.value(value: cart),
        ChangeNotifierProvider<WishlistProvider>.value(value: wishlist),
        ChangeNotifierProvider<ShellController>(
          create: (_) => ShellController(),
        ),
      ],
      child: const QuvvatApp(),
    ),
  );
}

class QuvvatApp extends StatelessWidget {
  const QuvvatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp(
      title: 'Quvvat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: Locale(settings.language),
      supportedLocales: const [
        Locale('uz'),
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainShell(),
    );
  }
}
