import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../widgets/staking_page_header.dart';
import '../widgets/staking_sidebar.dart';
import 'nexbit_staking_dashboard_page.dart';
import 'nexbit_staking_portfolio_page.dart';
import 'nexbit_staking_transaction_history_page.dart';

/// Staking "Pengaturan" — account security settings: a real password-
/// change form with live requirement validation, and working
/// two-factor-authentication toggles.
class NexbitStakingSettingsPage extends StatelessWidget {
  const NexbitStakingSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    void openDashboard() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingDashboardPage()),
        );
    void openMyStaking() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingPortfolioPage()),
        );
    void openTxHistory() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingTransactionHistoryPage()),
        );

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
                  final sidebar = StakingSidebar(
                    isMobile: isMobile,
                    activeId: 'settings',
                    onLogoTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    onDashboardTap: openDashboard,
                    onMyStakingTap: openMyStaking,
                    onTxHistoryTap: openTxHistory,
                    onSettingsTap: () {},
                  );
                  final content = _SettingsContent(isMobile: isMobile);
                  return isMobile
                      ? SingleChildScrollView(child: Column(children: [sidebar, content]))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            sidebar,
                            Expanded(child: SingleChildScrollView(child: content)),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final bool isMobile;
  const _SettingsContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StakingPageHeader(title: S.stakingSettingsHeading, subtitle: S.stakingSettingsSubheading, isMobile: isMobile),
          const SizedBox(height: 22),
          _ChangePasswordCard(isMobile: isMobile),
          const SizedBox(height: 18),
          _TwoFactorCard(isMobile: isMobile),
        ],
      ),
    );
  }
}

/// Shared collapsible-card shell — a tappable header with a rotating
/// chevron, and an [AnimatedSize] body so expand/collapse actually
/// animates instead of just snapping.
class _CollapsibleCard extends StatefulWidget {
  final String title;
  final Widget child;
  const _CollapsibleCard({required this.title, required this.child});

  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<_CollapsibleCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Hoverable(
            hoverScale: 1.0,
            builder: (context, hovered) => InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(widget.title, style: NexbitText.display(fontSize: 17, weight: FontWeight.w700)),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(Icons.expand_more_rounded, color: NexbitColors.muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: widget.child,
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordCard extends StatefulWidget {
  final bool isMobile;
  const _ChangePasswordCard({required this.isMobile});

  @override
  State<_ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<_ChangePasswordCard> {
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _oldError;
  String? _confirmError;

  bool get _hasMinLength => _newController.text.length >= 8;
  bool get _hasLower => RegExp(r'[a-z]').hasMatch(_newController.text);
  bool get _hasUpper => RegExp(r'[A-Z]').hasMatch(_newController.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_newController.text);
  bool get _hasSpecial => RegExp(r'[^A-Za-z0-9]').hasMatch(_newController.text);
  bool get _allRequirementsMet => _hasMinLength && _hasLower && _hasUpper && _hasNumber && _hasSpecial;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _oldController.clear();
      _newController.clear();
      _confirmController.clear();
      _oldError = null;
      _confirmError = null;
    });
  }

  void _save() {
    setState(() {
      _oldError = _oldController.text.isEmpty ? S.stakingOldPasswordRequired : null;
      _confirmError = _confirmController.text != _newController.text ? S.stakingConfirmPasswordMismatch : null;
    });
    if (_oldError != null) return;
    if (!_allRequirementsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: NexbitColors.surface2,
          behavior: SnackBarBehavior.floating,
          content: Text(S.stakingPasswordRequirementsNotMet, style: NexbitText.body(fontSize: 13, color: NexbitColors.text)),
        ),
      );
      return;
    }
    if (_confirmError != null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: NexbitColors.surface2,
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(Icons.check_circle, size: 18, color: NexbitColors.accent),
            const SizedBox(width: 10),
            Text(S.stakingPasswordChangedSuccess, style: NexbitText.body(fontSize: 13, color: NexbitColors.text)),
          ],
        ),
      ),
    );
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    return _CollapsibleCard(
      title: S.stakingChangePasswordHeading,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 20,
            runSpacing: 18,
            children: [
              SizedBox(
                width: widget.isMobile ? double.infinity : 380,
                child: _PasswordField(
                  label: S.stakingOldPassword,
                  controller: _oldController,
                  obscure: _obscureOld,
                  onToggleObscure: () => setState(() => _obscureOld = !_obscureOld),
                  errorText: _oldError,
                  onChanged: (_) {
                    if (_oldError != null) setState(() => _oldError = null);
                  },
                ),
              ),
              SizedBox(
                width: widget.isMobile ? double.infinity : 380,
                child: _PasswordField(
                  label: S.stakingNewPassword,
                  controller: _newController,
                  obscure: _obscureNew,
                  onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: widget.isMobile ? double.infinity : 380,
            child: _PasswordField(
              label: S.stakingConfirmPassword,
              controller: _confirmController,
              obscure: _obscureConfirm,
              onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
              errorText: _confirmError,
              onChanged: (_) {
                if (_confirmError != null) setState(() => _confirmError = null);
              },
            ),
          ),
          const SizedBox(height: 22),
          Text(S.stakingPasswordRequirementsHeading, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.text)),
          const SizedBox(height: 10),
          _RequirementRow(met: _hasMinLength, label: S.stakingReqMinLength),
          _RequirementRow(met: _hasLower, label: S.stakingReqLower),
          _RequirementRow(met: _hasUpper, label: S.stakingReqUpper),
          _RequirementRow(met: _hasNumber, label: S.stakingReqNumber),
          _RequirementRow(met: _hasSpecial, label: S.stakingReqSpecial),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              PrimaryButton(label: S.stakingSaveChange, onTap: _save),
              OutlineButton(label: S.stakingCancel, onTap: _reset),
            ],
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggleObscure,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.muted)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: NexbitText.mono(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: NexbitColors.surface2,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            errorText: errorText,
            errorStyle: NexbitText.body(fontSize: 11.5, color: NexbitColors.down),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18, color: NexbitColors.muted),
              onPressed: onToggleObscure,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
            enabledBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.line)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.accent)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: NexbitColors.down)),
          ),
        ),
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String label;
  const _RequirementRow({required this.met, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Icon(
              met ? Icons.check_circle : Icons.circle_outlined,
              key: ValueKey(met),
              size: 15,
              color: met ? NexbitColors.accent : NexbitColors.muted2,
            ),
          ),
          const SizedBox(width: 8),
          Text(label, style: NexbitText.body(fontSize: 12.5, color: met ? NexbitColors.text : NexbitColors.muted)),
        ],
      ),
    );
  }
}

class _TwoFactorCard extends StatefulWidget {
  final bool isMobile;
  const _TwoFactorCard({required this.isMobile});

  @override
  State<_TwoFactorCard> createState() => _TwoFactorCardState();
}

class _TwoFactorCardState extends State<_TwoFactorCard> {
  // Two independent toggle groups, matching the reference design's
  // two-column layout — each switch is its own real, working toggle.
  bool _leftAuthApp = true;
  bool _leftPrimaryEmail = false;
  bool _leftSmsRecovery = true;
  bool _rightAuthApp = false;
  bool _rightPrimaryEmail = true;
  bool _rightSmsRecovery = false;

  @override
  Widget build(BuildContext context) {
    final leftColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleRow(
          title: S.staking2faAuthApp,
          subtitle: S.staking2faAuthAppDesc,
          value: _leftAuthApp,
          onChanged: (v) => setState(() => _leftAuthApp = v),
        ),
        _ToggleRow(
          title: S.staking2faPrimaryEmail,
          subtitle: S.staking2faPrimaryEmailDesc,
          value: _leftPrimaryEmail,
          onChanged: (v) => setState(() => _leftPrimaryEmail = v),
        ),
        _ToggleRow(
          title: S.staking2faSmsRecovery,
          subtitle: S.staking2faSmsRecoveryDesc,
          value: _leftSmsRecovery,
          onChanged: (v) => setState(() => _leftSmsRecovery = v),
        ),
      ],
    );
    final rightColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleRow(
          title: S.staking2faAuthApp,
          subtitle: S.staking2faAuthAppDesc,
          value: _rightAuthApp,
          onChanged: (v) => setState(() => _rightAuthApp = v),
        ),
        _ToggleRow(
          title: S.staking2faPrimaryEmail,
          subtitle: S.staking2faPrimaryEmailDesc,
          value: _rightPrimaryEmail,
          onChanged: (v) => setState(() => _rightPrimaryEmail = v),
        ),
        _ToggleRow(
          title: S.staking2faSmsRecovery,
          subtitle: S.staking2faSmsRecoveryDesc,
          value: _rightSmsRecovery,
          onChanged: (v) => setState(() => _rightSmsRecovery = v),
        ),
      ],
    );

    return _CollapsibleCard(
      title: S.staking2faHeading,
      child: widget.isMobile
          ? Column(children: [leftColumn, const SizedBox(height: 18), rightColumn])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: leftColumn),
                const SizedBox(width: 24),
                Expanded(child: rightColumn),
              ],
            ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w600, color: NexbitColors.text)),
                Text(subtitle, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: NexbitColors.accent,
            activeThumbColor: const Color(0xFF04120E),
            inactiveThumbColor: NexbitColors.muted,
            inactiveTrackColor: NexbitColors.surface2,
          ),
        ],
      ),
    );
  }
}
