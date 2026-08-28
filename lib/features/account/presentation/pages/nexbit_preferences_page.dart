import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/prefs/app_prefs.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../widgets/account_widgets.dart';

/// "Preferensi" — display, trading, notification, currency, and dashboard
/// preferences. Bahasa is wired to the real app-wide [appLocale] notifier
/// (itself persisted, see [AppPrefs]); Tema only has Dark genuinely
/// working (there's no real ThemeMode infrastructure yet) so Light/System
/// show a "coming soon" notice instead of silently doing nothing.
/// Everything else is local widget state persisted via [AppPrefs] so it
/// survives a reload — there's still no backend behind any of it.
class NexbitPreferencesPage extends StatefulWidget {
  const NexbitPreferencesPage({super.key});

  @override
  State<NexbitPreferencesPage> createState() => _NexbitPreferencesPageState();
}

class _NexbitPreferencesPageState extends State<NexbitPreferencesPage> {
  static const _kTimeframe = 'pref_timeframe';
  static const _kChartType = 'pref_chart_type';
  static const _kCurrency = 'pref_currency';
  static const _kPriceAlert = 'pref_price_alert';
  static const _kOrderFilled = 'pref_order_filled';
  static const _kOrderCancelled = 'pref_order_cancelled';
  static const _kMarketNews = 'pref_market_news';
  static const _kPromotions = 'pref_promotions';
  static const _kCompactMode = 'pref_compact_mode';
  static const _kShowBalance = 'pref_show_balance';
  static const _kShowPnl = 'pref_show_pnl';
  static const _kShowPortfolio = 'pref_show_portfolio';

  late String _timeframe = AppPrefs.getString(_kTimeframe, '1D');
  late String _chartType = AppPrefs.getString(_kChartType, 'Candlestick');
  late String _currency = AppPrefs.getString(_kCurrency, 'IDR');

  late bool _priceAlert = AppPrefs.getBool(_kPriceAlert, true);
  late bool _orderFilled = AppPrefs.getBool(_kOrderFilled, true);
  late bool _orderCancelled = AppPrefs.getBool(_kOrderCancelled, true);
  late bool _marketNews = AppPrefs.getBool(_kMarketNews, false);
  late bool _promotions = AppPrefs.getBool(_kPromotions, false);

  late bool _compactMode = AppPrefs.getBool(_kCompactMode, false);
  late bool _showBalance = AppPrefs.getBool(_kShowBalance, true);
  late bool _showPnl = AppPrefs.getBool(_kShowPnl, true);
  late bool _showPortfolio = AppPrefs.getBool(_kShowPortfolio, true);

  void _updateString(String key, String value, void Function(String) apply) {
    setState(() => apply(value));
    AppPrefs.setString(key, value);
    _saved();
  }

  void _updateBool(String key, bool value, void Function(bool) apply) {
    setState(() => apply(value));
    AppPrefs.setBool(key, value);
    _saved();
  }

  void _saved() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.preferencesSavedSnack), duration: const Duration(seconds: 1)),
    );
  }

  void _themeNotAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.preferencesThemeNotAvailableSnack), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => AccountPageScaffold(
        title: S.preferencesHeading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccountSectionCard(
              title: S.preferencesDisplayHeading,
              children: [
                _pickerRow(
                  icon: Icons.dark_mode_outlined,
                  label: S.preferencesTheme,
                  subtitle: S.preferencesThemeDesc,
                  pills: [
                    AccountPill(label: S.preferencesThemeDark, active: true, onTap: () {}),
                    AccountPill(label: S.preferencesThemeLight, active: false, onTap: _themeNotAvailable),
                    AccountPill(label: S.preferencesThemeSystem, active: false, onTap: _themeNotAvailable),
                  ],
                ),
                const AccountRowDivider(),
                _pickerRow(
                  icon: Icons.translate,
                  label: S.profileLanguageLabel,
                  subtitle: S.preferencesLanguageDesc,
                  pills: [
                    AccountPill(label: 'ID', active: locale == AppLocale.id, onTap: () => appLocale.value = AppLocale.id),
                    AccountPill(label: 'EN', active: locale == AppLocale.en, onTap: () => appLocale.value = AppLocale.en),
                  ],
                ),
              ],
            ),
            AccountSectionCard(
              title: S.preferencesTradingHeading,
              children: [
                _pickerRow(
                  icon: Icons.schedule,
                  label: S.preferencesDefaultTimeframe,
                  pills: [
                    for (final tf in ['1H', '4H', '1D', '1W'])
                      AccountPill(label: tf, active: _timeframe == tf, onTap: () => _updateString(_kTimeframe, tf, (v) => _timeframe = v)),
                  ],
                ),
                const AccountRowDivider(),
                _pickerRow(
                  icon: Icons.candlestick_chart_outlined,
                  label: S.preferencesDefaultChart,
                  pills: [
                    for (final type in ['Candlestick', 'Line'])
                      AccountPill(label: type, active: _chartType == type, onTap: () => _updateString(_kChartType, type, (v) => _chartType = v)),
                  ],
                ),
              ],
            ),
            AccountSectionCard(
              title: S.preferencesNotificationsHeading,
              children: [
                AccountToggleRow(icon: Icons.notifications_active_outlined, label: S.preferencesPriceAlert, value: _priceAlert, onChanged: (v) => _updateBool(_kPriceAlert, v, (v) => _priceAlert = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.check_circle_outline, label: S.preferencesOrderFilled, value: _orderFilled, onChanged: (v) => _updateBool(_kOrderFilled, v, (v) => _orderFilled = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.cancel_outlined, label: S.preferencesOrderCancelled, value: _orderCancelled, onChanged: (v) => _updateBool(_kOrderCancelled, v, (v) => _orderCancelled = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.article_outlined, label: S.preferencesMarketNews, value: _marketNews, onChanged: (v) => _updateBool(_kMarketNews, v, (v) => _marketNews = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.local_offer_outlined, label: S.preferencesPromotions, value: _promotions, onChanged: (v) => _updateBool(_kPromotions, v, (v) => _promotions = v)),
              ],
            ),
            AccountSectionCard(
              title: S.preferencesCurrencyHeading,
              children: [
                _pickerRow(
                  icon: Icons.attach_money,
                  label: S.preferencesCurrency,
                  subtitle: S.preferencesCurrencyDesc,
                  pills: [
                    for (final c in ['IDR', 'USD'])
                      AccountPill(label: c, active: _currency == c, onTap: () => _updateString(_kCurrency, c, (v) => _currency = v)),
                  ],
                ),
              ],
            ),
            AccountSectionCard(
              title: S.preferencesDashboardHeading,
              children: [
                AccountToggleRow(icon: Icons.view_compact_outlined, label: S.preferencesCompactMode, value: _compactMode, onChanged: (v) => _updateBool(_kCompactMode, v, (v) => _compactMode = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.account_balance_wallet_outlined, label: S.preferencesShowBalance, value: _showBalance, onChanged: (v) => _updateBool(_kShowBalance, v, (v) => _showBalance = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.trending_up, label: S.preferencesShowPnl, value: _showPnl, onChanged: (v) => _updateBool(_kShowPnl, v, (v) => _showPnl = v)),
                const AccountRowDivider(),
                AccountToggleRow(icon: Icons.pie_chart_outline, label: S.preferencesShowPortfolio, value: _showPortfolio, onChanged: (v) => _updateBool(_kShowPortfolio, v, (v) => _showPortfolio = v)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickerRow({required IconData icon, required String label, String? subtitle, required List<Widget> pills}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 19, color: NexbitColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: NexbitText.body(fontSize: 14, color: NexbitColors.text)),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 31),
            child: Wrap(spacing: 8, runSpacing: 8, children: pills),
          ),
        ],
      ),
    );
  }
}
