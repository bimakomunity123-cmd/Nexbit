import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../widgets/account_widgets.dart';
import 'nexbit_kyc_page.dart';

/// "Profil Saya" — personal info, verification status, profile settings,
/// and a danger zone. Uses the real name/email set at login/register
/// ([currentUserName]/[currentUserEmail]); everything else (phone,
/// country, user id, join date) is deterministic mock data seeded from
/// the email since there's no real backend behind this demo. Identity
/// verification status IS real, though — fetched from /kyc/status (see
/// NexbitKycPage) rather than the permanently-hardcoded "Verified" badge
/// this section used to show.
class NexbitProfilePage extends StatefulWidget {
  const NexbitProfilePage({super.key});

  @override
  State<NexbitProfilePage> createState() => _NexbitProfilePageState();
}

class _NexbitProfilePageState extends State<NexbitProfilePage> {
  KycStatus _kycStatus = KycStatus.unverified;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  Future<void> _loadKycStatus() async {
    try {
      final json = await ApiClient.getKycStatus(authToken.value);
      if (!mounted) return;
      setState(() => _kycStatus = kycStatusFromJson(json['status'] as String));
    } catch (_) {
      // Stays on the unverified default on a failed fetch — same
      // fail-quiet convention as every other best-effort load in this app.
    }
  }

  Future<void> _openKycPage(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitKycPage()));
    // The KYC page's own state may have changed while it was open
    // (submitted a verification) — refresh so this page's badges agree.
    _loadKycStatus();
  }

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
                  _ProfileHeader(name: displayName, email: email, kycStatus: _kycStatus),
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
                        iconColor: _kycStatusColor(_kycStatus),
                        label: S.profileIdentity,
                        trailing: _kycStatusChip(_kycStatus),
                        onTap: () => _openKycPage(context),
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
                          onPressed: () => _editDisplayName(context, displayName),
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
                          // Only ever clears this session — this demo has
                          // no session/token-revocation list, so there's
                          // no real "every other device" to reach even if
                          // one existed (see User.is_active's docstring in
                          // models.py for the same caveat on deactivate).
                          clearSession();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          _snack(context, S.profileLogoutAllSnack);
                        },
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.pause_circle_outline,
                        iconColor: NexbitColors.down,
                        label: S.profileDeactivateAccount,
                        onTap: () async {
                          final confirmed = await _confirm(
                            context,
                            title: S.profileDeactivateConfirmTitle,
                            message: S.profileDeactivateConfirmMessage,
                            onConfirm: () async {
                              try {
                                await ApiClient.deactivateAccount(authToken.value);
                                return null;
                              } on ApiException catch (e) {
                                return e.message;
                              }
                            },
                          );
                          if (!confirmed || !context.mounted) return;
                          clearSession();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          _snack(context, S.profileAccountDeactivatedSnack);
                        },
                      ),
                      const AccountRowDivider(),
                      AccountInfoRow(
                        icon: Icons.delete_outline,
                        iconColor: NexbitColors.down,
                        label: S.profileDeleteAccount,
                        onTap: () async {
                          final confirmed = await _confirm(
                            context,
                            title: S.profileDeleteConfirmTitle,
                            message: S.profileDeleteConfirmMessage,
                            danger: true,
                            onConfirm: () async {
                              try {
                                await ApiClient.deleteAccount(authToken.value);
                                return null;
                              } on ApiException catch (e) {
                                return e.message;
                              }
                            },
                          );
                          if (!confirmed || !context.mounted) return;
                          clearSession();
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          _snack(context, S.profileAccountDeletedSnack);
                        },
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

  void _editDisplayName(BuildContext context, String currentName) {
    final nameCtrl = TextEditingController(text: currentName);
    bool loading = false;
    String? error;

    Future<void> submit(StateSetter setDialogState, BuildContext dialogContext) async {
      final name = nameCtrl.text.trim();
      if (name.isEmpty) {
        setDialogState(() => error = S.profileDisplayNameRequired);
        return;
      }
      setDialogState(() {
        loading = true;
        error = null;
      });
      try {
        // Real backend call (see backend/app/routers/auth.py's PATCH
        // /auth/profile) — persists the new name server-side, not just
        // in this session's ValueNotifier.
        final result = await ApiClient.updateProfile(authToken.value, name: name);
        currentUserName.value = result['name'] as String;
        if (!dialogContext.mounted) return;
        Navigator.of(dialogContext).pop();
        _snack(context, S.profileDisplayNameUpdatedSnack);
      } on ApiException catch (e) {
        setDialogState(() {
          loading = false;
          error = e.message;
        });
      }
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: NexbitColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
          title: Text(S.profileDisplayName, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AccountDialogField(hint: S.profileDisplayName, controller: nameCtrl),
                if (error != null) AccountDialogError(error!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(dialogContext).pop(),
              child: Text(S.accountCancel, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
            ),
            TextButton(
              onPressed: loading ? null : () => submit(setDialogState, dialogContext),
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: NexbitColors.accent),
                    )
                  : Text(S.accountConfirm, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  /// [onConfirm] returns null on success (closes the dialog) or an
  /// error message to show inline (dialog stays open) — same pattern
  /// as showDepositWithdrawDialog/showExchangeDialog, so a real backend
  /// call (deactivate/delete — see their call sites) that fails doesn't
  /// silently claim success the way this dialog used to (it fired
  /// onConfirm unconditionally, with no backend call behind it at all).
  ///
  /// Returns whether it was actually confirmed (and succeeded) — the
  /// caller does any further navigation (popping back to root, showing
  /// a snackbar) only after this dialog has fully closed. Doing that
  /// navigation from inside onConfirm itself, before this dialog's own
  /// route was popped, raced the two pops against each other (both
  /// operate on the same underlying Navigator) and left the app on a
  /// blank screen — a real bug caught while testing this exact flow.
  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required Future<String?> Function() onConfirm,
    bool danger = false,
  }) async {
    bool loading = false;
    String? error;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: NexbitColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: NexbitColors.line)),
          title: Text(title, style: NexbitText.body(fontSize: 16, weight: FontWeight.w700, color: NexbitColors.text)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(message, style: NexbitText.body(fontSize: 13.5, height: 1.4)),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.down)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: loading ? null : () => Navigator.of(dialogContext).pop(false),
              child: Text(S.accountCancel, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.muted)),
            ),
            TextButton(
              onPressed: loading
                  ? null
                  : () async {
                      setDialogState(() {
                        loading = true;
                        error = null;
                      });
                      final failureMessage = await onConfirm();
                      if (!dialogContext.mounted) return;
                      if (failureMessage == null) {
                        Navigator.of(dialogContext).pop(true);
                      } else {
                        setDialogState(() {
                          loading = false;
                          error = failureMessage;
                        });
                      }
                    },
              child: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: NexbitColors.accent),
                    )
                  : Text(S.accountConfirm,
                      style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: danger ? NexbitColors.down : NexbitColors.accent)),
            ),
          ],
        ),
      ),
    );
    return confirmed ?? false;
  }
}

/// Color/label/icon for each real [KycStatus] — shared by the header
/// badge and the Account Verification row so they never disagree.
Color _kycStatusColor(KycStatus status) => switch (status) {
      KycStatus.verified => NexbitColors.up,
      KycStatus.pending => NexbitColors.accent2,
      KycStatus.unverified => NexbitColors.muted,
    };

String _kycStatusLabel(KycStatus status) => switch (status) {
      KycStatus.verified => S.profileVerifiedBadge,
      KycStatus.pending => S.profilePendingBadge,
      KycStatus.unverified => S.profileUnverifiedBadge,
    };

IconData _kycStatusIcon(KycStatus status) => switch (status) {
      KycStatus.verified => Icons.check_circle,
      KycStatus.pending => Icons.hourglass_top,
      KycStatus.unverified => Icons.info_outline,
    };

Widget _kycStatusChip(KycStatus status) =>
    _StatusChip(label: _kycStatusLabel(status), color: _kycStatusColor(status), icon: _kycStatusIcon(status));

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final KycStatus kycStatus;
  const _ProfileHeader({required this.name, required this.email, required this.kycStatus});

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
                    _kycStatusChip(kycStatus),
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
  final IconData icon;
  const _StatusChip({required this.label, required this.color, this.icon = Icons.check_circle});

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
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: NexbitText.body(fontSize: 11, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
