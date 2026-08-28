import 'package:flutter/material.dart';
import 'core/i18n/app_locale.dart';
import 'core/prefs/app_prefs.dart';
import 'features/auth/presentation/pages/nexbit_forgot_password_page.dart';
import 'features/auth/presentation/pages/nexbit_login_page.dart';
import 'features/auth/presentation/pages/nexbit_register_page.dart';
import 'features/blog/presentation/pages/nexbit_blog_page.dart';
import 'features/futures/presentation/pages/nexbit_futures_page.dart';
import 'features/landing/presentation/pages/nexbit_landing_page.dart';
import 'features/market/presentation/pages/nexbit_market_page.dart';
import 'features/market/presentation/pages/nexbit_price_page.dart';
import 'features/trading/presentation/pages/nexbit_trading_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads the persisted language (and arms saving future changes) before
  // the first frame, so a reload doesn't silently reset it to Indonesian.
  await AppPrefs.init();
  runApp(const NexbitApp());
}

class NexbitApp extends StatelessWidget {
  const NexbitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the whole app (including already-pushed pages) whenever
    // the ID/EN toggle in the navbar flips appLocale.value.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Nexbit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(useMaterial3: true),
          home: const NexbitLandingPage(),
          routes: {
            '/landing': (_) => const NexbitLandingPage(),
            '/trading': (_) => const NexbitTradingPage(),
            '/market': (_) => const NexbitMarketPage(),
            '/futures': (_) => const NexbitFuturesPage(),
            '/blog': (_) => const NexbitBlogPage(),
            '/harga': (_) => const NexbitPricePage(),
            '/login': (_) => const NexbitLoginPage(),
            '/register': (_) => const NexbitRegisterPage(),
            '/forgot-password': (_) => const NexbitForgotPasswordPage(),
          },
        );
      },
    );
  }
}
