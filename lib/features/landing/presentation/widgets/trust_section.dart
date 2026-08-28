import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'nexbit_buttons.dart';

/// Generic, non-institutional trust badges — deliberately avoids naming
/// real regulators/certifiers since Nexbit is a demo brand. Built at
/// render time (not `const`) since the labels read the live [S] strings.
List<(IconData, String)> get _kBadges => [
      (Icons.enhanced_encryption_outlined, S.trustBadgeEncryption),
      (Icons.fact_check_outlined, S.trustBadgeAudit),
      (Icons.security_outlined, S.trustBadgeInsured),
      (Icons.gavel_outlined, S.trustBadgeCompliance),
    ];

/// Closing "trust" band with a CTA and a row of security/compliance
/// badges — the reassurance section right before the footer.
class TrustSection extends StatelessWidget {
  final bool isMobile;
  const TrustSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 56, vertical: 70),
      child: Column(
        children: [
          Text(
            S.trustHeading,
            textAlign: TextAlign.center,
            style: NexbitText.display(fontSize: isMobile ? 22 : 28, color: NexbitColors.accent, height: 1.35),
          ),
          const SizedBox(height: 16),
          Text(
            S.trustSubtext,
            textAlign: TextAlign.center,
            style: NexbitText.body(fontSize: 15),
          ),
          const SizedBox(height: 28),
          PrimaryButton(label: S.trustCta, onTap: () {}),
          const SizedBox(height: 56),
          Text(S.trustCertifiedSecured,
              style: NexbitText.mono(fontSize: 12.5, color: NexbitColors.muted, letterSpacing: 1)),
          const SizedBox(height: 20),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final badge in _kBadges) _CertBadge(icon: badge.$1, label: badge.$2),
            ],
          ),
        ],
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _CertBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: NexbitColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: NexbitColors.accent),
          const SizedBox(width: 8),
          Text(label, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.text)),
        ],
      ),
    );
  }
}
