import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';

/// Shared page shell for the four account-menu drill-down pages (Profil
/// Saya, Keamanan, Preferensi, Bantuan). These are reached from the
/// navbar's account dropdown rather than being primary nav destinations,
/// so they use a simple "← Title" header instead of the full [NexbitNavbar]
/// — same pattern as [NexbitForgotPasswordPage].
class AccountPageScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  const AccountPageScaffold({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexbitColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.line))),
              child: Row(
                children: [
                  Hoverable(
                    hoverScale: 1.06,
                    builder: (context, hovered) => InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hovered ? NexbitColors.surface2 : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.arrow_back, size: 20, color: NexbitColors.muted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(title, style: NexbitText.display(fontSize: 20, color: NexbitColors.text)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A bordered card grouping related rows under a title — the basic
/// building block every account page's sections are made of.
class AccountSectionCard extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final List<Widget> children;
  const AccountSectionCard({super.key, required this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NexbitColors.surface,
        border: Border.all(color: NexbitColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: NexbitText.body(fontSize: 15.5, weight: FontWeight.w700, color: NexbitColors.text)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

/// icon + label (+ optional subtitle) + value/trailing widget — used for
/// both static info display and tappable "go do something" rows.
class AccountInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  const AccountInfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 19, color: iconColor ?? NexbitColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: NexbitText.body(fontSize: 14, color: NexbitColors.text)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
    if (onTap == null) return row;
    return Hoverable(
      hoverScale: 1,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          color: hovered ? NexbitColors.surface2.withOpacity(0.5) : Colors.transparent,
          child: row,
        ),
      ),
    );
  }
}

/// icon + label + subtitle + [Switch] — for on/off preference rows.
class AccountToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const AccountToggleRow({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AccountInfoRow(
      icon: icon,
      label: label,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: NexbitColors.accent,
      ),
    );
  }
}

/// The dark, rounded text field used inside the small confirm/cancel
/// dialogs across the account pages (change password, edit display name,
/// reset password) — shared so those dialogs don't each redefine the same
/// decoration.
class AccountDialogField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  const AccountDialogField({
    super.key,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: NexbitText.body(fontSize: 13.5, color: NexbitColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted2),
        filled: true,
        fillColor: NexbitColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.accent)),
      ),
    );
  }
}

/// Small inline error line shown inside an account-page dialog, under its
/// input fields — used by change-password/edit-name for backend/validation
/// errors.
class AccountDialogError extends StatelessWidget {
  final String message;
  const AccountDialogError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(message, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.down)),
    );
  }
}

/// A thin horizontal divider matching the section-card borders — used
/// between rows inside a card instead of extra vertical padding alone.
class AccountRowDivider extends StatelessWidget {
  const AccountRowDivider({super.key});
  @override
  Widget build(BuildContext context) => const Divider(color: NexbitColors.lineSoft, height: 1);
}

/// A small pill button — used for Cancel/Confirm-style actions and
/// segmented pickers (theme, timeframe, etc).
class AccountPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const AccountPill({super.key, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.04,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: active ? null : (hovered ? NexbitColors.surface2 : Colors.transparent),
            gradient: active ? NexbitColors.accentGradient : null,
            border: Border.all(color: active ? Colors.transparent : NexbitColors.line),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: NexbitText.body(
              fontSize: 13,
              weight: FontWeight.w600,
              color: active ? const Color(0xFF04120E) : NexbitColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
