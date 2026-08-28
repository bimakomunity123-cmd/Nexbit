import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'max_width_box.dart';

/// "Support 60+ Bank & E-Wallet" section: copy on one side, a stylised
/// (non-brand) payment-methods graphic on the other.
class PaymentSupportSection extends StatelessWidget {
  final bool isMobile;
  const PaymentSupportSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          S.paymentHeading,
          style: NexbitText.display(fontSize: isMobile ? 26 : 32, color: NexbitColors.accent, height: 1.25),
        ),
        const SizedBox(height: 22),
        Text(S.paymentSubheading,
            style: NexbitText.body(fontSize: 17, weight: FontWeight.w700, color: NexbitColors.text)),
        const SizedBox(height: 12),
        Text(
          S.paymentParagraph,
          style: NexbitText.body(fontSize: 14.5, height: 1.7),
        ),
      ],
    );

    // Not `const` — its subtree renders locale-dependent text (S.xxx),
    // so it must stay eligible to rebuild when appLocale changes.
    final graphic = _PaymentGraphic();

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(isMobile ? 22 : 56, 60, isMobile ? 22 : 56, 60),
      child: MaxWidthBox(
        child: isMobile
            ? Column(children: [text, const SizedBox(height: 44), Center(child: graphic)])
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 110, child: text),
                  const SizedBox(width: 60),
                  Expanded(flex: 90, child: Center(child: graphic)),
                ],
              ),
      ),
    );
  }
}

/// Stylised stand-in for a payment-methods illustration — an angled
/// gradient "blob" with floating category chips. Deliberately generic
/// (no real e-wallet/bank brand logos).
class _PaymentGraphic extends StatelessWidget {
  const _PaymentGraphic();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.5,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                gradient: NexbitColors.accentGradient,
                borderRadius: BorderRadius.circular(52),
              ),
            ),
          ),
          Positioned(
            left: 4,
            top: 30,
            child: _PaymentChip(icon: Icons.account_balance_wallet_outlined, label: S.paymentChipEwallet),
          ),
          Positioned(
            right: 4,
            top: 86,
            child: _PaymentChip(icon: Icons.qr_code_2_outlined, label: S.paymentChipQris),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: _PaymentChip(icon: Icons.account_balance_outlined, label: S.paymentChipBankTransfer),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PaymentChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF04120E)),
          const SizedBox(width: 6),
          Text(label, style: NexbitText.body(fontSize: 12, weight: FontWeight.w700, color: const Color(0xFF04120E))),
        ],
      ),
    );
  }
}
