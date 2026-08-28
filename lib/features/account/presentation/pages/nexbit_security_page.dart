import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/prefs/app_prefs.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../widgets/account_widgets.dart';

/// "Keamanan" — security score, login/auth toggles (2FA, biometric),
/// active devices, and a recent security-activity feed. 2FA/biometric
/// are real local widget state, persisted via [AppPrefs] so they survive
/// a reload; device list and activity feed are deterministic mock data.
class NexbitSecurityPage extends StatefulWidget {
  const NexbitSecurityPage({super.key});

  @override
  State<NexbitSecurityPage> createState() => _NexbitSecurityPageState();
}

class _NexbitSecurityPageState extends State<NexbitSecurityPage> {
  static const _kTwoFa = 'sec_2fa';
  static const _kBiometric = 'sec_biometric';

  late bool _twoFa = AppPrefs.getBool(_kTwoFa, false);
  late bool _biometric = AppPrefs.getBool(_kBiometric, true);

  void _setTwoFa(bool v) {
    setState(() => _twoFa = v);
    AppPrefs.setBool(_kTwoFa, v);
  }

  void _setBiometric(bool v) {
    setState(() => _biometric = v);
    AppPrefs.setBool(_kBiometric, v);
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _changePassword() {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NexbitColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
        title: Text(S.securityChangePasswordTitle, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(S.securityOldPassword, oldCtrl),
              const SizedBox(height: 12),
              _dialogField(S.securityNewPassword, newCtrl),
              const SizedBox(height: 12),
              _dialogField(S.securityConfirmNewPassword, confirmCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(S.accountCancel, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _snack(S.securityPasswordChangedSnack);
            },
            child: Text(S.accountConfirm, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => AccountPageScaffold(
        title: S.securityHeading,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: NexbitColors.surface,
                border: Border.all(color: NexbitColors.line),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: NexbitColors.accent.withOpacity(0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.shield, size: 26, color: NexbitColors.accent),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(S.securityScoreHeading, style: NexbitText.body(fontSize: 15.5, weight: FontWeight.w700, color: NexbitColors.text)),
                            const SizedBox(width: 8),
                            Text('72/100', style: NexbitText.mono(fontSize: 12.5, color: NexbitColors.accent)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: 0.72,
                            minHeight: 6,
                            backgroundColor: NexbitColors.surface2,
                            valueColor: const AlwaysStoppedAnimation(NexbitColors.accent),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(S.securityScoreDesc, style: NexbitText.body(fontSize: 12.5, height: 1.4)),
                        const SizedBox(height: 12),
                        Hoverable(
                          hoverScale: 1.02,
                          builder: (context, hovered) => InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () => _setTwoFa(true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(gradient: NexbitColors.accentGradient, borderRadius: BorderRadius.circular(9)),
                              child: Text(S.securityImproveButton, style: NexbitText.body(fontSize: 13, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AccountSectionCard(
              title: S.securityLoginAuthHeading,
              children: [
                AccountInfoRow(
                  icon: Icons.password_outlined,
                  label: S.securityPassword,
                  subtitle: S.securityPasswordLastChanged(46),
                  trailing: TextButton(
                    onPressed: _changePassword,
                    child: Text(S.securityChangeButton, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent)),
                  ),
                ),
                const AccountRowDivider(),
                AccountInfoRow(
                  icon: Icons.verified_user_outlined,
                  label: S.security2fa,
                  // The Aktif/Nonaktif status folds into the subtitle
                  // (rather than sitting inline next to the switch) so a
                  // long, wrapped label on narrow screens never squeezes
                  // the status text and switch together.
                  subtitle: '${S.security2faDesc} · ${_twoFa ? S.securityActive : S.securityInactive}',
                  trailing: Switch(value: _twoFa, activeColor: NexbitColors.accent, onChanged: _setTwoFa),
                ),
                const AccountRowDivider(),
                AccountInfoRow(
                  icon: Icons.fingerprint,
                  label: S.securityBiometric,
                  subtitle: S.securityBiometricDesc,
                  trailing: Switch(value: _biometric, activeColor: NexbitColors.accent, onChanged: _setBiometric),
                ),
              ],
            ),
            AccountSectionCard(
              title: S.securityActiveDevicesHeading,
              children: [
                AccountInfoRow(
                  icon: Icons.laptop_mac,
                  iconColor: NexbitColors.up,
                  label: S.securityCurrentDevice,
                  subtitle: 'Windows · Chrome · Jakarta, ID',
                  trailing: _StatusChip(label: S.securityActive, color: NexbitColors.up),
                ),
                const AccountRowDivider(),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Hoverable(
                    hoverScale: 1.02,
                    builder: (context, hovered) => InkWell(
                      onTap: () => _snack(S.securityViewAllDevices(3)),
                      child: Text(S.securityViewAllDevices(3), style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent)),
                    ),
                  ),
                ),
              ],
            ),
            AccountSectionCard(
              title: S.securityActivityHeading,
              trailing: Hoverable(
                hoverScale: 1.02,
                builder: (context, hovered) => InkWell(
                  onTap: () => _snack(S.accountComingSoonSnack),
                  child: Text(S.securityViewAll, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.accent)),
                ),
              ),
              children: [
                AccountInfoRow(icon: Icons.login, iconColor: NexbitColors.up, label: S.securityLoginSuccess, subtitle: '27 Aug 2026 · 09:14 · Jakarta, ID'),
                const AccountRowDivider(),
                AccountInfoRow(icon: Icons.key_outlined, iconColor: NexbitColors.accent2, label: S.securityPasswordChangedActivity, subtitle: '12 Jul 2026 · 21:03 · Jakarta, ID'),
                const AccountRowDivider(),
                AccountInfoRow(icon: Icons.warning_amber_outlined, iconColor: NexbitColors.down, label: S.securityLoginFailedActivity, subtitle: '03 Jun 2026 · 02:47 · Unknown'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: NexbitText.body(fontSize: 11, weight: FontWeight.w600, color: color)),
    );
  }
}
