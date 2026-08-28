import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';

/// Small label above an [AuthTextField] — shared by login/register/forgot-
/// password so all three auth screens look identical, not near-copies.
class AuthFieldLabel extends StatelessWidget {
  final String text;
  const AuthFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.muted));
  }
}

/// The dark, rounded text field used across every auth screen (login,
/// register, forgot password).
class AuthTextField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final bool obscure;
  final Widget? trailing;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final String? errorText;

  const AuthTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscure = false,
    this.trailing,
    this.onSubmitted,
    this.keyboardType,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      style: NexbitText.body(fontSize: 14, color: NexbitColors.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: NexbitText.body(fontSize: 14, color: NexbitColors.muted2),
        suffixIcon: trailing,
        errorText: errorText,
        filled: true,
        fillColor: NexbitColors.surface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: NexbitColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: NexbitColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: NexbitColors.accent),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: const BorderSide(color: NexbitColors.down),
        ),
      ),
    );
  }
}

/// The gradient "primary action" pill button shared by every auth screen.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const AuthPrimaryButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Hoverable(
        pressScale: 0.97,
        builder: (context, hovered) => AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: NexbitColors.accentGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: hovered
                ? [BoxShadow(color: NexbitColors.accent.withOpacity(0.45), blurRadius: 24, spreadRadius: 1)]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: NexbitText.body(fontSize: 15, weight: FontWeight.w700, color: const Color(0xFF04120E))),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
