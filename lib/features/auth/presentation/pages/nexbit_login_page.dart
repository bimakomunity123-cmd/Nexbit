import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../../core/widgets/nexbit_logo_mark.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../widgets/auth_form_fields.dart';
import '../widgets/login_illustration.dart';
import 'nexbit_forgot_password_page.dart';
import 'nexbit_register_page.dart';

enum _LoginStage { credentials, twoFactor }

/// Login page — matches the classic split layout (form left, welcome
/// illustration right) but deliberately skips any CAPTCHA/robot-check
/// widget, and the illustration is an original Nexbit graphic rather
/// than a copy of any real site's artwork.
class NexbitLoginPage extends StatefulWidget {
  const NexbitLoginPage({super.key});

  @override
  State<NexbitLoginPage> createState() => _NexbitLoginPageState();
}

class _NexbitLoginPageState extends State<NexbitLoginPage> {
  bool _obscure = true;
  bool _remember = false;
  bool _loading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Set only when the account has 2FA enabled — see backend/app/
  // routers/auth.py's login(), which returns a challenge instead of a
  // token in that case. _demoOtpCode is a demo-only shortcut (this app
  // has no real SMS/authenticator service), same pattern as the
  // forgot-password flow's reset token.
  _LoginStage _stage = _LoginStage.credentials;
  String? _challengeToken;
  String? _demoOtpCode;
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _completeLogin(Map<String, dynamic> result) {
    final user = result['user'] as Map<String, dynamic>;
    currentUserEmail.value = user['email'] as String;
    currentUserName.value = user['name'] as String;
    authToken.value = result['access_token'] as String;
    isLoggedIn.value = true;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NexbitFuturesPage()),
    );
  }

  Future<void> _submit() async {
    if (_loading) return; // guards the Enter-key submit path too, not just the button
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      _snack(S.loginRequiredFields);
      return;
    }
    setState(() => _loading = true);
    try {
      // Real backend call (see backend/) — a wrong email/password now
      // actually fails instead of silently accepting anything.
      final result = await ApiClient.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (result['two_factor_required'] == true) {
        setState(() {
          _stage = _LoginStage.twoFactor;
          _challengeToken = result['challenge_token'] as String;
          _demoOtpCode = result['otp_code'] as String;
          _loading = false;
        });
        return;
      }
      _completeLogin(result);
    } on ApiException catch (e) {
      _snack(e.message);
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitOtp() async {
    if (_loading) return;
    if (_otpController.text.trim().isEmpty) {
      _snack(S.loginTwoFactorCodeRequired);
      return;
    }
    setState(() => _loading = true);
    try {
      final result = await ApiClient.verifyTwoFactor(
        challengeToken: _challengeToken!,
        code: _otpController.text.trim(),
      );
      if (!mounted) return;
      _completeLogin(result);
    } on ApiException catch (e) {
      _snack(e.message);
      if (mounted) setState(() => _loading = false);
    }
  }

  void _backToCredentials() {
    setState(() {
      _stage = _LoginStage.credentials;
      _challengeToken = null;
      _demoOtpCode = null;
      _otpController.clear();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listens to appLocale directly so this page rebuilds with fresh text
    // whenever the ID/EN toggle flips — independent of Navigator/route
    // mechanics, which don't automatically re-invoke a route's builder.
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => Scaffold(
        backgroundColor: NexbitColors.bg,
        body: Stack(
          children: [
            const Positioned.fill(child: NetworkBackground()),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                  final form = _stage == _LoginStage.credentials
                      ? _LoginForm(
                          obscure: _obscure,
                          remember: _remember,
                          loading: _loading,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          onToggleObscure: () => setState(() => _obscure = !_obscure),
                          onToggleRemember: (v) => setState(() => _remember = v ?? false),
                          onSubmit: _submit,
                        )
                      : _TwoFactorForm(
                          otpController: _otpController,
                          loading: _loading,
                          demoOtpCode: _demoOtpCode!,
                          onSubmit: _submitOtp,
                          onBack: _backToCredentials,
                        );
                  final illustration = LoginIllustration(isMobile: isMobile);

                  final content = Padding(
                    padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 56, vertical: 32),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              form,
                              const SizedBox(height: 48),
                              illustration,
                            ],
                          )
                        : ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 1280),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(flex: 100, child: form),
                                  const SizedBox(width: 60),
                                  Expanded(flex: 110, child: illustration),
                                ],
                              ),
                            ),
                          ),
                  );

                  // Center the whole block both ways when it fits the
                  // screen, and still scroll cleanly if it doesn't (short
                  // viewports, zoomed-in mobile, etc).
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: Center(child: content),
                    ),
                  );
                },
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

class _LoginForm extends StatelessWidget {
  final bool obscure;
  final bool remember;
  final bool loading;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onSubmit;

  const _LoginForm({
    required this.obscure,
    required this.remember,
    required this.loading,
    required this.emailController,
    required this.passwordController,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const NexbitLogoLockup(markSize: 34, borderRadius: 9, wordmarkFontSize: 22, spacing: 10),
          const SizedBox(height: 40),
          Text(S.loginHello, style: NexbitText.display(fontSize: 32, color: NexbitColors.accent)),
          const SizedBox(height: 6),
          Text(S.loginSubtitle, style: NexbitText.body(fontSize: 15)),
          const SizedBox(height: 28),
          AuthFieldLabel(S.loginEmail),
          const SizedBox(height: 6),
          AuthTextField(hint: S.loginEmail, controller: emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 18),
          AuthFieldLabel(S.loginPassword),
          const SizedBox(height: 6),
          AuthTextField(
            hint: S.loginPassword,
            controller: passwordController,
            obscure: obscure,
            onSubmitted: (_) => onSubmit(),
            trailing: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: NexbitColors.muted),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: remember,
                  onChanged: onToggleRemember,
                  activeColor: NexbitColors.accent,
                  checkColor: const Color(0xFF04120E),
                  side: const BorderSide(color: NexbitColors.line),
                ),
              ),
              const SizedBox(width: 10),
              Text(S.loginRememberMe, style: NexbitText.body(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(label: S.loginSubmit, onTap: onSubmit, loading: loading),
          const SizedBox(height: 18),
          Hoverable(
            hoverScale: 1.03,
            builder: (context, hovered) => InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NexbitForgotPasswordPage()),
              ),
              child: Text(S.loginForgotPassword,
                  style: NexbitText.body(
                      fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(S.loginNewUser, style: NexbitText.body(fontSize: 13.5)),
              Hoverable(
                hoverScale: 1.03,
                builder: (context, hovered) => InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NexbitRegisterPage()),
                  ),
                  child: Text(S.loginRegister,
                      style: NexbitText.body(
                          fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The 2FA step shown in place of the credentials form once login()
/// reports the account needs a code — see NexbitLoginPage's own doc
/// comment on _demoOtpCode for why that code is shown directly here.
class _TwoFactorForm extends StatelessWidget {
  final TextEditingController otpController;
  final bool loading;
  final String demoOtpCode;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _TwoFactorForm({
    required this.otpController,
    required this.loading,
    required this.demoOtpCode,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const NexbitLogoLockup(markSize: 34, borderRadius: 9, wordmarkFontSize: 22, spacing: 10),
          const SizedBox(height: 40),
          Text(S.loginTwoFactorHeading, style: NexbitText.display(fontSize: 30, color: NexbitColors.accent)),
          const SizedBox(height: 6),
          Text(S.loginTwoFactorSubtitle, style: NexbitText.body(fontSize: 15)),
          const SizedBox(height: 28),
          AuthFieldLabel(S.loginTwoFactorCodeLabel),
          const SizedBox(height: 6),
          AuthTextField(
            hint: '••••••',
            controller: otpController,
            keyboardType: TextInputType.number,
            onSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: 16),
          // Demo-only shortcut — see NexbitLoginPage's doc comment on
          // _demoOtpCode. A real product must deliver this over a
          // verified out-of-band channel, never show it in the UI.
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
                Text(S.loginTwoFactorDemoNoticeBody, style: NexbitText.body(fontSize: 12, height: 1.4, color: NexbitColors.muted)),
                const SizedBox(height: 10),
                Text(demoOtpCode, style: NexbitText.mono(fontSize: 20, weight: FontWeight.w700, color: NexbitColors.accent)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(label: S.loginTwoFactorSubmit, onTap: onSubmit, loading: loading),
          const SizedBox(height: 18),
          Center(
            child: Hoverable(
              hoverScale: 1.03,
              builder: (context, hovered) => InkWell(
                onTap: onBack,
                child: Text(S.loginTwoFactorBack,
                    style: NexbitText.body(
                        fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.text : NexbitColors.accent)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
