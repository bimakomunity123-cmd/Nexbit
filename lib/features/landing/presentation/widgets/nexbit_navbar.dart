import 'package:flutter/material.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../../account/presentation/pages/nexbit_help_page.dart';
import '../../../account/presentation/pages/nexbit_preferences_page.dart';
import '../../../account/presentation/pages/nexbit_profile_page.dart';
import '../../../account/presentation/pages/nexbit_security_page.dart';
import 'max_width_box.dart';
import 'nexbit_buttons.dart';

/// Shared top navbar — used by the landing page and reused as-is on the
/// other top-level pages (Harga, Trading) so the site feels consistent
/// wherever you land.
class NexbitNavbar extends StatelessWidget {
  final bool isMobile;
  final VoidCallback? onLogoTap;
  final VoidCallback? onHargaTap;
  final VoidCallback? onMarketTap;
  final VoidCallback? onStakingTap;
  final VoidCallback? onFuturesTap;
  final VoidCallback? onBlogTap;
  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterTap;
  /// Stable id ('harga','market','staking','futures','blog') of
  /// the section currently on screen, so its nav link stays accent-colored
  /// instead of only lighting up on hover. Null = no section highlighted.
  final String? activeId;

  const NexbitNavbar({
    super.key,
    required this.isMobile,
    this.onLogoTap,
    this.onHargaTap,
    this.onMarketTap,
    this.onStakingTap,
    this.onFuturesTap,
    this.onBlogTap,
    this.onLoginTap,
    this.onRegisterTap,
    this.activeId,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = <(String, String, VoidCallback?)>[
      ('harga', S.navHarga, onHargaTap),
      ('market', S.navMarket, onMarketTap),
      ('staking', S.navStaking, onStakingTap),
      ('futures', S.navFutures, onFuturesTap),
      ('blog', S.navBlog, onBlogTap),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 56, vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: NexbitColors.line)),
      ),
      child: MaxWidthBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Hoverable(
              hoverScale: 1.04,
              builder: (context, hovered) => InkWell(
                onTap: onLogoTap,
                child: const NexbitLogoLockup(markSize: 30, wordmarkFontSize: 20, spacing: 10),
              ),
            ),
            if (!isMobile)
              Row(
                children: [
                  for (final item in navItems)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: _NavLink(label: item.$2, onTap: item.$3, active: item.$1 == activeId),
                    ),
                ],
              ),
            Row(
              children: [
                if (!isMobile) ...[
                  _LocaleToggle(),
                  const SizedBox(width: 18),
                ],
                ValueListenableBuilder<bool>(
                  valueListenable: isLoggedIn,
                  builder: (context, loggedIn, _) {
                    if (loggedIn) return const _AccountMenu();
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hoverable(
                          hoverScale: 1.06,
                          builder: (context, hovered) => TextButton(
                            onPressed: onLoginTap,
                            child: AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 160),
                              curve: Curves.easeOut,
                              style: NexbitText.body(
                                fontSize: 14.5,
                                weight: FontWeight.w500,
                                color: hovered ? NexbitColors.accent : NexbitColors.text,
                              ),
                              child: Text(S.navLogin),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Hoverable(
                          hoverScale: 1.06,
                          builder: (context, hovered) => AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              gradient: NexbitColors.accentGradient,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: hovered
                                  ? [
                                      BoxShadow(
                                        color: NexbitColors.accent.withOpacity(0.45),
                                        blurRadius: 18,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: TextButton(
                              onPressed: onRegisterTap,
                              child: Text(S.navRegister,
                                  style:
                                      NexbitText.body(fontSize: 14.5, weight: FontWeight.w600, color: const Color(0xFF04120E))),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The signed-in state of the Masuk/Daftar slot — an avatar (with a small
/// "online" dot) that opens a menu: the account's name/email (whatever
/// was actually typed at login/register, not a hardcoded placeholder),
/// a few account links, and "Keluar" (log out). Logging out flips
/// [isLoggedIn] back to false (so every page's navbar updates at once,
/// same as the ID/EN toggle) and returns to the landing page.
class _AccountMenu extends StatelessWidget {
  const _AccountMenu();

  static const _itemWidth = 220.0;

  void _logout(BuildContext context) {
    clearSession();
    Navigator.of(context).popUntil((route) => route.isFirst);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.navLogoutSuccessSnack), duration: const Duration(seconds: 2)),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      offset: const Offset(0, 44),
      color: NexbitColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: NexbitColors.line)),
      onSelected: (value) {
        switch (value) {
          case 'logout':
            _logout(context);
            break;
          case 'profile':
            _open(context, const NexbitProfilePage());
            break;
          case 'security':
            _open(context, const NexbitSecurityPage());
            break;
          case 'preferences':
            _open(context, const NexbitPreferencesPage());
            break;
          case 'help':
            _open(context, const NexbitHelpPage());
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: SizedBox(
            width: _itemWidth,
            child: Row(
              children: [
                const _Avatar(size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ValueListenableBuilder<String>(
                        valueListenable: currentUserName,
                        builder: (context, name, _) => Text(
                          name.isEmpty ? S.navMyProfile : name,
                          overflow: TextOverflow.ellipsis,
                          style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text),
                        ),
                      ),
                      ValueListenableBuilder<String>(
                        valueListenable: currentUserEmail,
                        builder: (context, email, _) => Text(
                          email,
                          overflow: TextOverflow.ellipsis,
                          style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        _item('profile', Icons.person_outline, S.navMyProfile),
        _item('security', Icons.shield_outlined, S.navSecurity),
        _item('preferences', Icons.tune, S.navPreferences),
        _item('help', Icons.help_outline, S.navHelp),
        const PopupMenuDivider(),
        _item('logout', Icons.logout, S.navLogout, color: NexbitColors.accent2),
      ],
      child: Hoverable(
        hoverScale: 1.06,
        builder: (context, hovered) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Avatar(size: 34, hovered: hovered, showStatusDot: true),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: NexbitColors.muted),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _item(String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem<String>(
      value: value,
      child: SizedBox(
        width: _itemWidth,
        child: Row(
          children: [
            Icon(icon, size: 17, color: color ?? NexbitColors.muted),
            const SizedBox(width: 10),
            Text(label, style: NexbitText.body(fontSize: 13.5, color: color ?? NexbitColors.text)),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final double size;
  final bool hovered;
  final bool showStatusDot;
  const _Avatar({required this.size, this.hovered = false, this.showStatusDot = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: NexbitColors.accentGradient,
            shape: BoxShape.circle,
            border: Border.all(color: hovered ? NexbitColors.accent : Colors.transparent, width: 2),
          ),
          child: Icon(Icons.person, size: size * 0.53, color: const Color(0xFF04120E)),
        ),
        if (showStatusDot)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: NexbitColors.up,
                shape: BoxShape.circle,
                border: Border.all(color: NexbitColors.bg, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

/// "ID | EN" language switcher — a pill button that opens a dropdown with
/// both languages (flag + native name); picking one sets [appLocale],
/// which rebuilds the whole app (see main.dart) with the new strings.
class _LocaleToggle extends StatefulWidget {
  @override
  State<_LocaleToggle> createState() => _LocaleToggleState();
}

class _LocaleToggleState extends State<_LocaleToggle> {
  @override
  void initState() {
    super.initState();
    appLocale.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    appLocale.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = appLocale.value;
    return PopupMenuButton<AppLocale>(
      tooltip: '',
      offset: const Offset(0, 44),
      color: NexbitColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: NexbitColors.line)),
      onSelected: (locale) => appLocale.value = locale,
      itemBuilder: (context) => [
        _localeItem(AppLocale.id, '🇮🇩', 'ID', S.navLangIndonesian, active),
        _localeItem(AppLocale.en, '🇬🇧', 'EN', S.navLangEnglish, active),
      ],
      child: Hoverable(
        hoverScale: 1.04,
        builder: (context, hovered) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: NexbitColors.surface2,
            border: Border.all(color: hovered ? NexbitColors.accent : NexbitColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.public, size: 15, color: NexbitColors.accent),
              const SizedBox(width: 6),
              Text(active == AppLocale.id ? 'ID' : 'EN',
                  style: NexbitText.mono(fontSize: 12, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(width: 2),
              const Icon(Icons.keyboard_arrow_down, size: 15, color: NexbitColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<AppLocale> _localeItem(AppLocale locale, String flag, String code, String label, AppLocale active) {
    final isActive = locale == active;
    return PopupMenuItem<AppLocale>(
      value: locale,
      child: SizedBox(
        width: 200,
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(code,
                      style: NexbitText.body(
                          fontSize: 13, weight: FontWeight.w700, color: isActive ? NexbitColors.accent : NexbitColors.text)),
                  Text(label, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
                ],
              ),
            ),
            if (isActive) const Icon(Icons.check, size: 16, color: NexbitColors.accent),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool active;
  const _NavLink({required this.label, this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.08,
      builder: (context, hovered) => InkWell(
        onTap: onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          style: NexbitText.body(
            fontSize: 14.5,
            weight: active ? FontWeight.w600 : FontWeight.w500,
            color: (active || hovered) ? NexbitColors.accent : NexbitColors.muted,
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
