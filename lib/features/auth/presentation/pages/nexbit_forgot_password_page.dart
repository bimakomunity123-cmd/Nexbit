import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../widgets/auth_form_fields.dart';

enum _Stage { form, sent, reset, done }

/// Forgot-password page — a single centered card (no split illustration;
/// this flow is a quick in-and-out, not a destination) that walks through
/// four states: the email form, a "check your email" confirmation, the
/// actual reset form (token + new password), then a success state.
///
/// Real backend calls throughout (see backend/app/routers/auth.py's
/// /auth/forgot-password and /auth/reset-password) — but since this app
/// has no email service configured, the "sent" state surfaces the reset
/// token directly (only when the account actually exists) behind an
/// explicitly-labeled "Mode Demo" shortcut, rather than pretending an
/// email was really sent. A real product must only deliver this token
/// over a verified out-of-band channel.
class NexbitForgotPasswordPage extends StatefulWidget {
  const NexbitForgotPasswordPage({super.key});

  @override
  State<NexbitForgotPasswordPage> createState() => _NexbitForgotPasswordPageState();
}

class _NexbitForgotPasswordPageState extends State<NexbitForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _Stage _stage = _Stage.form;
  bool _loading = false;
  String? _emailError;
  String? _resetError;
  // Only set when the submitted email actually belongs to an account — see
  // the class doc above and the backend docstring it references.
  String? _resetToken;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  Future<void> _submit() async {
    if (_loading) return;
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _emailError = S.forgotPasswordEmailRequired);
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = S.forgotPasswordEmailInvalid);
      return;
    }
    setState(() {
      _emailError = null;
      _loading = true;
    });
    try {
      final result = await ApiClient.forgotPassword(email);
      _resetToken = result['reset_token'] as String?;
      if (!mounted) return;
      setState(() {
        _stage = _Stage.sent;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _emailError = e.message;
        _loading = false;
      });
    }
  }

  Future<void> _resend() async {
    await _submit();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.forgotPasswordResentSnack), duration: const Duration(seconds: 2)),
    );
  }

  void _goToResetForm() {
    if (_resetToken != null) _tokenController.text = _resetToken!;
    setState(() {
      _resetError = null;
      _stage = _Stage.reset;
    });
  }

  Future<void> _submitReset() async {
    if (_loading) return;
    final token = _tokenController.text.trim();
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;
    if (token.isEmpty || newPw.isEmpty || confirmPw.isEmpty) {
      setState(() => _resetError = S.resetPasswordFieldsRequired);
      return;
    }
    if (newPw.length < 8) {
      setState(() => _resetError = S.resetPasswordTooShort);
      return;
    }
    if (newPw != confirmPw) {
      setState(() => _resetError = S.resetPasswordMismatch);
      return;
    }
    setState(() {
      _resetError = null;
      _loading = true;
    });
    try {
      await ApiClient.resetPassword(token: token, newPassword: newPw);
      if (!mounted) return;
      setState(() {
        _stage = _Stage.done;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _resetError = e.message;
        _loading = false;
      });
    }
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
                          switch (_stage) {
                            _Stage.form => _FormState(
                                controller: _emailController,
                                errorText: _emailError,
                                loading: _loading,
                                onSubmit: _submit,
                              ),
                            _Stage.sent => _SentState(
                                email: _emailController.text.trim(),
                                hasResetToken: _resetToken != null,
                                onResend: _resend,
                                onContinueReset: _goToResetForm,
                              ),
                            _Stage.reset => _ResetState(
                                tokenController: _tokenController,
                                newPasswordController: _newPasswordController,
                                confirmPasswordController: _confirmPasswordController,
                                errorText: _resetError,
                                loading: _loading,
                                prefilled: _resetToken != null,
                                onSubmit: _submitReset,
                              ),
                            _Stage.done => const _DoneState(),
                          },
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
  final bool loading;
  final VoidCallback onSubmit;
  const _FormState({required this.controller, required this.errorText, required this.loading, required this.onSubmit});

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
        AuthPrimaryButton(label: S.forgotPasswordSubmit, onTap: onSubmit, loading: loading),
      ],
    );
  }
}

class _SentState extends StatelessWidget {
  final String email;
  final bool hasResetToken;
  final VoidCallback onResend;
  final VoidCallback onContinueReset;
  const _SentState({
    required this.email,
    required this.hasResetToken,
    required this.onResend,
    required this.onContinueReset,
  });

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
        const SizedBox(height: 16),
        Hoverable(
          hoverScale: 1.03,
          builder: (context, hovered) => InkWell(
            onTap: onResend,
            child: Text(S.forgotPasswordResend,
                style: NexbitText.body(
                    fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
          ),
        ),
        // Demo-only shortcut — only shown when the email actually belongs
        // to an account, since that's the only time a reset token exists
        // to continue with. See the page-level doc comment for why this
        // exists and why a real product must not do this.
        if (hasResetToken) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: NexbitColors.accent.withOpacity(0.08),
              border: Border.all(color: NexbitColors.accent.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 15, color: NexbitColors.accent),
                    const SizedBox(width: 6),
                    Text(S.forgotPasswordDemoNoticeHeading,
                        style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: NexbitColors.accent)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(S.forgotPasswordDemoNoticeBody, style: NexbitText.body(fontSize: 12, height: 1.4, color: NexbitColors.muted)),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: AuthPrimaryButton(label: S.forgotPasswordContinueReset, onTap: onContinueReset)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ResetState extends StatelessWidget {
  final TextEditingController tokenController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final String? errorText;
  final bool loading;
  final bool prefilled;
  final VoidCallback onSubmit;
  const _ResetState({
    required this.tokenController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.errorText,
    required this.loading,
    required this.prefilled,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.resetPasswordHeading, style: NexbitText.display(fontSize: 24, color: NexbitColors.accent)),
        const SizedBox(height: 8),
        Text(S.resetPasswordSubtitle, style: NexbitText.body(fontSize: 14, height: 1.5)),
        const SizedBox(height: 20),
        AuthFieldLabel(S.resetPasswordTokenLabel),
        const SizedBox(height: 6),
        AuthTextField(hint: S.resetPasswordTokenLabel, controller: tokenController),
        if (prefilled) ...[
          const SizedBox(height: 6),
          Text(S.resetPasswordPrefilledNotice, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
        ],
        const SizedBox(height: 16),
        AuthFieldLabel(S.resetPasswordNewPassword),
        const SizedBox(height: 6),
        AuthTextField(hint: S.resetPasswordNewPassword, controller: newPasswordController, obscure: true),
        const SizedBox(height: 16),
        AuthFieldLabel(S.resetPasswordConfirmPassword),
        const SizedBox(height: 6),
        AuthTextField(
          hint: S.resetPasswordConfirmPassword,
          controller: confirmPasswordController,
          obscure: true,
          onSubmitted: (_) => onSubmit(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 10),
          Text(errorText!, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.down)),
        ],
        const SizedBox(height: 22),
        AuthPrimaryButton(label: S.resetPasswordSubmit, onTap: onSubmit, loading: loading),
      ],
    );
  }
}

class _DoneState extends StatelessWidget {
  const _DoneState();

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
          child: const Icon(Icons.check_circle_outline, color: Color(0xFF04120E), size: 28),
        ),
        const SizedBox(height: 20),
        Text(S.resetPasswordSuccessHeading, style: NexbitText.display(fontSize: 24, color: NexbitColors.accent)),
        const SizedBox(height: 8),
        Text(S.resetPasswordSuccessBody, style: NexbitText.body(fontSize: 14, height: 1.5)),
      ],
    );
  }
}
