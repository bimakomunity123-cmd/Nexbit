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
import 'nexbit_login_page.dart';

/// Register page — same split layout (form left, illustration right) as
/// the login page, with the extra fields a real sign-up needs.
class NexbitRegisterPage extends StatefulWidget {
  const NexbitRegisterPage({super.key});

  @override
  State<NexbitRegisterPage> createState() => _NexbitRegisterPageState();
}

class _NexbitRegisterPageState extends State<NexbitRegisterPage> {
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _loading = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v);

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Future<void> _submit() async {
    if (_loading) return; // guards the Enter-key submit path too, not just the button
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      _snack(S.registerRequiredFields);
      return;
    }
    if (!_isValidEmail(email)) {
      _snack(S.registerEmailInvalid);
      return;
    }
    if (password.length < 8) {
      _snack(S.registerPasswordTooShort);
      return;
    }
    if (password != confirm) {
      _snack(S.registerPasswordMismatch);
      return;
    }
    if (!_agreeTerms) {
      _snack(S.registerMustAgreeTerms);
      return;
    }

    setState(() => _loading = true);
    try {
      // Real backend call (see backend/) — a duplicate email now actually
      // gets rejected instead of silently "succeeding".
      final result = await ApiClient.register(name: name, email: email, password: password);
      final user = result['user'] as Map<String, dynamic>;
      currentUserName.value = user['name'] as String;
      currentUserEmail.value = user['email'] as String;
      authToken.value = result['access_token'] as String;
      isLoggedIn.value = true;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const NexbitFuturesPage()),
      );
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                  final form = _RegisterForm(
                    obscure: _obscure,
                    obscureConfirm: _obscureConfirm,
                    agreeTerms: _agreeTerms,
                    loading: _loading,
                    nameController: _nameController,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmController: _confirmController,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    onToggleObscureConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    onToggleAgree: (v) => setState(() => _agreeTerms = v ?? false),
                    onSubmit: _submit,
                  );
                  final illustration = LoginIllustration(
                    isMobile: isMobile,
                    title: S.registerWelcome,
                    subtitle: S.registerWelcomeSubtitle,
                  );

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

class _RegisterForm extends StatelessWidget {
  final bool obscure;
  final bool obscureConfirm;
  final bool agreeTerms;
  final bool loading;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onToggleObscure;
  final VoidCallback onToggleObscureConfirm;
  final ValueChanged<bool?> onToggleAgree;
  final VoidCallback onSubmit;

  const _RegisterForm({
    required this.obscure,
    required this.obscureConfirm,
    required this.agreeTerms,
    required this.loading,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.onToggleObscure,
    required this.onToggleObscureConfirm,
    required this.onToggleAgree,
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
          Text(S.registerHeading, style: NexbitText.display(fontSize: 32, color: NexbitColors.accent)),
          const SizedBox(height: 6),
          Text(S.registerSubtitle, style: NexbitText.body(fontSize: 15)),
          const SizedBox(height: 28),
          AuthFieldLabel(S.registerFullName),
          const SizedBox(height: 6),
          AuthTextField(hint: S.registerFullName, controller: nameController),
          const SizedBox(height: 18),
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
            trailing: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: NexbitColors.muted),
              onPressed: onToggleObscure,
            ),
          ),
          const SizedBox(height: 18),
          AuthFieldLabel(S.registerConfirmPassword),
          const SizedBox(height: 6),
          AuthTextField(
            hint: S.registerConfirmPassword,
            controller: confirmController,
            obscure: obscureConfirm,
            onSubmitted: (_) => onSubmit(),
            trailing: IconButton(
              icon: Icon(obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 18, color: NexbitColors.muted),
              onPressed: onToggleObscureConfirm,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: agreeTerms,
                  onChanged: onToggleAgree,
                  activeColor: NexbitColors.accent,
                  checkColor: const Color(0xFF04120E),
                  side: const BorderSide(color: NexbitColors.line),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(S.registerAgreeTerms, style: NexbitText.body(fontSize: 12.5, height: 1.4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthPrimaryButton(label: S.registerSubmit, onTap: onSubmit, loading: loading),
          const SizedBox(height: 18),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(S.registerHaveAccount, style: NexbitText.body(fontSize: 13.5)),
                Hoverable(
                  hoverScale: 1.03,
                  builder: (context, hovered) => InkWell(
                    // Always go to the Login page itself — not just "back",
                    // since Register can also be reached directly from the
                    // navbar's Daftar button on other pages, not only from
                    // Login's own "Daftar" link.
                    onTap: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const NexbitLoginPage()),
                    ),
                    child: Text(S.registerLoginLink,
                        style: NexbitText.body(
                            fontSize: 13.5,
                            weight: FontWeight.w600,
                            color: hovered ? NexbitColors.text : NexbitColors.accent)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
