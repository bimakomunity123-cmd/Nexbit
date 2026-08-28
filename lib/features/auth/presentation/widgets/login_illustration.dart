import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Original "welcome back" graphic shared by the login/register pages — a
/// stylised dashboard/globe composition built from plain shapes and
/// Material icons, not a copy of any real site's artwork. Title/subtitle
/// default to the login copy but can be overridden (e.g. for the register
/// page) so both screens share one illustration instead of two near-copies.
class LoginIllustration extends StatelessWidget {
  final bool isMobile;
  final String? title;
  final String? subtitle;
  const LoginIllustration({super.key, required this.isMobile, this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title ?? S.loginWelcomeBack,
            style: NexbitText.display(fontSize: isMobile ? 22 : 26, color: NexbitColors.accent, height: 1.3)),
        const SizedBox(height: 10),
        Text(
          subtitle ?? S.loginWelcomeBackSubtitle,
          style: NexbitText.body(fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 36),
        Center(child: _DashboardGraphic(compact: isMobile)),
      ],
    );
  }
}

class _DashboardGraphic extends StatelessWidget {
  final bool compact;
  const _DashboardGraphic({required this.compact});

  @override
  Widget build(BuildContext context) {
    final size = compact ? 280.0 : 360.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Monitor stand.
          Positioned(
            bottom: size * 0.02,
            child: Container(
              width: size * 0.22,
              height: size * 0.05,
              decoration: BoxDecoration(
                color: NexbitColors.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Positioned(
            bottom: size * 0.07,
            child: Container(width: 3, height: size * 0.14, color: NexbitColors.surface2),
          ),
          // Main "screen" — globe dashboard.
          Positioned(
            bottom: size * 0.2,
            child: Container(
              width: size * 0.72,
              height: size * 0.56,
              padding: EdgeInsets.all(size * 0.03),
              decoration: BoxDecoration(
                color: NexbitColors.surface,
                borderRadius: BorderRadius.circular(size * 0.05),
                border: Border.all(color: NexbitColors.line, width: 2),
                boxShadow: [
                  BoxShadow(color: NexbitColors.accent.withOpacity(0.18), blurRadius: 40, spreadRadius: -6),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: NexbitColors.accentGradient,
                  borderRadius: BorderRadius.circular(size * 0.03),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.public, size: size * 0.32, color: const Color(0xFF04120E).withOpacity(0.55)),
              ),
            ),
          ),
          // Floating location pins on the "globe".
          Positioned(
            top: size * 0.24,
            right: size * 0.22,
            child: Icon(Icons.location_on, size: size * 0.08, color: NexbitColors.accent2),
          ),
          Positioned(
            top: size * 0.4,
            right: size * 0.32,
            child: Icon(Icons.location_on, size: size * 0.06, color: Colors.white.withOpacity(0.85)),
          ),
          // Floating mini widget card — bar chart.
          Positioned(
            left: 0,
            bottom: size * 0.06,
            child: _MiniWidgetCard(
              icon: Icons.bar_chart_rounded,
              color: NexbitColors.up,
              size: size * 0.24,
            ),
          ),
          // Floating mini widget card — donut chart.
          Positioned(
            right: 0,
            top: size * 0.02,
            child: _MiniWidgetCard(
              icon: Icons.pie_chart_rounded,
              color: NexbitColors.accent2,
              size: size * 0.22,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniWidgetCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const _MiniWidgetCard({required this.icon, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: NexbitColors.surface,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: NexbitColors.line),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Icon(icon, size: size * 0.46, color: color),
    );
  }
}
