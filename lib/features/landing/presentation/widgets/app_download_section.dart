import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'max_width_box.dart';
import 'nexbit_buttons.dart';

/// "Download the app" section — a phone mockup on one side, pitch copy
/// and store badges on the other.
class AppDownloadSection extends StatelessWidget {
  final bool isMobile;
  const AppDownloadSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    // Not `const` — its subtree renders locale-dependent text (S.xxx),
    // so it must stay eligible to rebuild when appLocale changes.
    final phone = _PhoneMockup();

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.appDownloadHeading,
          style: NexbitText.display(fontSize: isMobile ? 22 : 26, color: NexbitColors.accent, height: 1.3),
        ),
        const SizedBox(height: 22),
        Text(S.appDownloadSubheading,
            style: NexbitText.body(fontSize: 17, weight: FontWeight.w700, color: NexbitColors.text)),
        const SizedBox(height: 10),
        Text(
          S.appDownloadParagraph,
          style: NexbitText.body(fontSize: 14.5, height: 1.7),
        ),
        const SizedBox(height: 22),
        Text(S.appDownloadNow, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StoreBadge(icon: Icons.shop_outlined, eyebrow: S.appDownloadGetItOn, storeName: 'Google Play'),
            _StoreBadge(icon: Icons.apple, eyebrow: S.appDownloadOnThe, storeName: 'App Store'),
          ],
        ),
      ],
    );

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 60, isMobile ? 22 : 56, 60),
      child: MaxWidthBox(
        child: isMobile
            ? Column(children: [Center(child: phone), const SizedBox(height: 44), text])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 85, child: Center(child: phone)),
                  const SizedBox(width: 60),
                  Expanded(flex: 115, child: text),
                ],
              ),
      ),
    );
  }
}

class _StoreBadge extends StatelessWidget {
  final IconData icon;
  final String eyebrow;
  final String storeName;
  const _StoreBadge({required this.icon, required this.eyebrow, required this.storeName});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.04,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: hovered ? NexbitColors.accent : Colors.transparent, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF04120E), size: 26),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(eyebrow,
                    style: const TextStyle(fontSize: 9, color: Color(0xFF444444), letterSpacing: .5)),
                Text(storeName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF04120E))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative phone frame with a miniature version of the app's home
/// screen — purely illustrative, no real device/OS chrome copied.
class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NexbitColors.surface,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: NexbitColors.accent, width: 2),
        boxShadow: [
          BoxShadow(color: NexbitColors.accent.withOpacity(0.25), blurRadius: 40, spreadRadius: -6),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          color: NexbitColors.bg,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 14, color: NexbitColors.accent),
                      const SizedBox(width: 4),
                      Text('Nexbit', style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: NexbitColors.text)),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notifications_none, size: 14, color: NexbitColors.muted),
                      const SizedBox(width: 8),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(color: NexbitColors.surface2, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(S.appDownloadGoodMorning, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted)),
              Text('Alice', style: NexbitText.body(fontSize: 13, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: NexbitColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.appDownloadBalance, style: TextStyle(fontSize: 9.5, color: const Color(0xFF04120E).withOpacity(0.7))),
                    const SizedBox(height: 4),
                    Text('4.990.000',
                        style: NexbitText.mono(fontSize: 17, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                    Text(S.appDownloadRupiah, style: TextStyle(fontSize: 9, color: const Color(0xFF04120E).withOpacity(0.7))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(S.appDownloadHighlights, style: NexbitText.body(fontSize: 11, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: S.appDownloadTopGainer24h,
                      asset: 'Bitcoin (BTC)',
                      change: '+3.09%',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniStatCard(
                      label: S.appDownloadHighest,
                      asset: 'Ethereum (ETH)',
                      change: '+1.12%',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final String asset;
  final String change;
  const _MiniStatCard({required this.label, required this.asset, required this.change});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: NexbitColors.surface2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: NexbitText.body(fontSize: 8.5, color: NexbitColors.muted)),
          const SizedBox(height: 6),
          Text(asset, style: NexbitText.body(fontSize: 9.5, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 2),
          Text(change, style: NexbitText.mono(fontSize: 9.5, weight: FontWeight.w600, color: NexbitColors.up)),
        ],
      ),
    );
  }
}
