import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../widgets/auth_form_fields.dart';

/// Forgot-password page — a single centered card (no split illustration;
/// this flow is a quick in-and-out, not a destination) with two states:
/// the email form, then a "check your email" confirmation once submitted.
class NexbitForgotPasswordPage extends StatefulWidget {
  const NexbitForgotPasswordPage({super.key});

  @override
  State<NexbitForgotPasswordPage> createState() => _NexbitForgotPasswordPageState();
}

class _NexbitForgotPasswordPageState extends State<NexbitForgotPasswordPage> {
  final _emailController = TextEditingController();
  String? _errorText;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  void _submit() {
    final email = _emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        _errorText = S.forgotPasswordEmailRequired;
      } else if (!_isValidEmail(email)) {
        _errorText = S.forgotPasswordEmailInvalid;
      } else {
        _errorText = null;
        _sent = true;
      }
    });
  }

  void _resend() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.forgotPasswordResentSnack), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
        backgroundColor: NexbitColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: NetworkBackground()),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: NexbitColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: NexbitColors.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const NexbitLogoLockup(markSize: 34, borderRadius: 9, wordmarkFontSize: 22, spacing: 10),
                          const SizedBox(height: 32),
                          if (_sent) _SentState(email: _emailController.text.trim(), onResend: _resend) else _FormState(
                            controller: _emailController,
                            errorText: _errorText,
                            onSubmit: _submit,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Hoverable(
                              hoverScale: 1.03,
                              builder: (context, hovered) => InkWell(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text(S.forgotPasswordBackToLogin,
                                    style: NexbitText.body(
                                        fontSize: 13.5,
                                        weight: FontWeight.w600,
                                        color: hovered ? NexbitColors.text : NexbitColors.accent)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Hoverable(
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
            ),
          ],
        ),
      ),
    );
  }
}

class _FormState extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmit;
  const _FormState({required this.controller, required this.errorText, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.forgotPasswordHeading, style: NexbitText.display(fontSize: 26, color: NexbitColors.accent)),
        const SizedBox(height: 8),
        Text(S.forgotPasswordSubtitle, style: NexbitText.body(fontSize: 14, height: 1.5)),
        const SizedBox(height: 24),
        AuthFieldLabel(S.loginEmail),
        const SizedBox(height: 6),
        AuthTextField(
          hint: S.loginEmail,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          errorText: errorText,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 22),
        AuthPrimaryButton(label: S.forgotPasswordSubmit, onTap: onSubmit),
      ],
    );
  }
}

class _SentState extends StatelessWidget {
  final String email;
  final VoidCallback onResend;
  const _SentState({required this.email, required this.onResend});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: NexbitColors.accentGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.mark_email_read_outlined, color: Color(0xFF04120E), size: 28),
        ),
        const SizedBox(height: 20),
        Text(S.forgotPasswordCheckEmailHeading, style: NexbitText.display(fontSize: 24, color: NexbitColors.accent)),
        const SizedBox(height: 8),
        Text(S.forgotPasswordCheckEmailBody(email), style: NexbitText.body(fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        Hoverable(
          hoverScale: 1.03,
          builder: (context, hovered) => InkWell(
            onTap: onResend,
            child: Text(S.forgotPasswordResend,
                style: NexbitText.body(
                    fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
          ),
        ),
      ],
    );
  }
}
