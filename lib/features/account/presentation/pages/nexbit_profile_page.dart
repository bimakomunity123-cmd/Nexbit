import 'package:flutter/material.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../widgets/account_widgets.dart';

/// "Profil Saya" — personal info, verification status, profile settings,
/// and a danger zone. Uses the real name/email set at login/register
/// ([currentUserName]/[currentUserEmail]); everything else (phone,
/// country, user id, join date) is deterministic mock data seeded from
/// the email since there's no real backend behind this demo.
class NexbitProfilePage extends StatelessWidget {
  const NexbitProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) => AccountPageScaffold(
        title: S.profileHeading,
        child: ValueListenableBuilder<String>(
          valueListenable: currentUserName,
          builder: (context, name, _) => ValueListenableBuilder<String>(
            valueListenable: currentUserEmail,
            builder: (context, email, __) {
              final seed = email.isEmpty ? 0 : email.codeUnits.fold<int>(0, (a, b) => a + b);
              final username = '@${email.split('@').first.toLowerCase()}';
              final phone = '+62 8${100 + seed % 900}-${1000 + seed % 9000}-${1000 + (seed * 7) % 9000}';
              final userId = 'NXB-${(100000 + seed * 37) % 900000}';
              final displayName = name.isEmpty ? 'Nexbit User' : name;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(name: displayName, email: email),
                  const SizedBox(height: 24),
                  AccountSectionCard(
                    title: S.profilePersonalInfoHeading,
                    children: [
                      AccountInfoRow(icon: Icons.badge_outlined, label: S.profileFullName, trailing: Text(displayName, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted))),
                      const AccountRowDivider(),
                      AccountInfoRow(icon: Icons.alternate_email, label: S.profileUsername, trailing: Text(username, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted))),
                      const AccountRowDivider(),
                      AccountInfoRow(icon: Icons.mail_outline, label: S.loginEmail, trailing: Text(email, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted))),
                      const AccountRowDivider(),
                      AccountInfoRow(icon: Icons.phone_outlined, label: S.profilePhoneNumber, trailing: Text(phone, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted))),
                      const AccountRowDivider(),
                      AccountInfoRow(icon: Icons.public, label: S.profileCountry, trailing: Text('Indonesia', style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted))),
                      const AccountRowDivider(),
                      AccountInfoRow(icon: Icons.fingerprint, label: S.profileUserId, trailing: Text(userId, style: NexbitText.mono(fontSize: 12.5, color: NexbitColors.muted2))),
                    ],
                  ),
                  AccountSectionCard(
                    title: S.profileAccountVerificationHeading,
                    children: [
                      AccountInfoRow(
                        icon: Icons.verified_user_outlined,
                        iconColor: NexbitColors.up,
                        label: S.profileIdentity,
                        trailing: _StatusChip(label: S.profileVerifiedBadge, color: NexbitColors.up),
                      ),
                    ],
                  ),
                  AccountSectionCard(
                    title: S.profileSettingsHeading,
                    children: [
                      AccountInfoRow(
                        icon: Icons.image_outlined,
                        label: S.profilePhoto,
                        trailing: TextButton(
                          onPressed: () => _snack(context, S.accountComingSoonSnack),
                          child: Text(S.securityChangeButton, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent)),
                        ),
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.drive_file_rename_outline,
                        label: S.profileDisplayName,
                        trailing: TextButton(
                          onPressed: () => _snack(context, S.accountComingSoonSnack),
                          child: Text(S.securityChangeButton, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent)),
                        ),
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.translate,
                        label: S.profileLanguageLabel,
                        trailing: Text(locale == AppLocale.id ? S.navLangIndonesian : S.navLangEnglish,
                            style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
                      ),
                    ],
                  ),
                  AccountSectionCard(
                    title: S.profileDangerZoneHeading,
                    children: [
                      AccountInfoRow(
                        icon: Icons.logout,
                        label: S.profileLogoutAllDevices,
                        onTap: () {
                          isLoggedIn.value = false;
                          currentUserName.value = '';
                          currentUserEmail.value = '';
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          _snack(context, S.profileLogoutAllSnack);
                        },
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.pause_circle_outline,
                        iconColor: NexbitColors.down,
                        label: S.profileDeactivateAccount,
                        onTap: () => _confirm(
                          context,
                          title: S.profileDeactivateConfirmTitle,
                          message: S.profileDeactivateConfirmMessage,
                          onConfirm: () {
                            isLoggedIn.value = false;
                            currentUserName.value = '';
                            currentUserEmail.value = '';
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            _snack(context, S.profileAccountDeactivatedSnack);
                          },
                        ),
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.delete_outline,
                        iconColor: NexbitColors.down,
                        label: S.profileDeleteAccount,
                        onTap: () => _confirm(
                          context,
                          title: S.profileDeleteConfirmTitle,
                          message: S.profileDeleteConfirmMessage,
                          danger: true,
                          onConfirm: () {
                            isLoggedIn.value = false;
                            currentUserName.value = '';
                            currentUserEmail.value = '';
                            Navigator.of(context).popUntil((route) => route.isFirst);
                            _snack(context, S.profileAccountDeletedSnack);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _confirm(BuildContext context, {required String title, required String message, required VoidCallback onConfirm, bool danger = false}) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: NexbitColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
        title: Text(title, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
        content: Text(message, style: NexbitText.body(fontSize: 13.5, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(S.accountCancel, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            child: Text(S.accountConfirm, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: danger ? NexbitColors.down : NexbitColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  const _ProfileHeader({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.surface,
        border: Border.all(color: NexbitColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: NexbitColors.accentGradient, shape: BoxShape.circle),
            child: const Icon(Icons.person, size: 34, color: Color(0xFF04120E)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: NexbitText.body(fontSize: 17, weight: FontWeight.w700, color: NexbitColors.text))),
                    const SizedBox(width: 8),
                    _StatusChip(label: S.profileVerifiedBadge, color: NexbitColors.up),
                  ],
                ),
                const SizedBox(height: 4),
                Text(email, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
                const SizedBox(height: 4),
                Text(S.profileMemberSince('14 Feb 2024'), style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
              ],
            ),
          ),
        ],
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: NexbitText.body(fontSize: 11, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
