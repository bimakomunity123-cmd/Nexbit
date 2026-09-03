import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../widgets/account_widgets.dart';

enum KycStatus { unverified, pending, verified }

KycStatus kycStatusFromJson(String value) {
  switch (value) {
    case 'pending':
      return KycStatus.pending;
    case 'verified':
      return KycStatus.verified;
    default:
      return KycStatus.unverified;
  }
}

/// "Verifikasi Identitas" — a demo KYC-lite flow reached from the account
/// menu, and linked from Profil Saya's Account Verification section.
/// IMPORTANT: this never checks the submitted name/id number against any
/// real identity registry (see backend/app/models.py's KycVerification
/// docstring) — it's purely a state machine (unverified -> pending ->
/// verified) so that section means something instead of being a
/// permanently-hardcoded "Verified" badge, which is what it was before
/// this page existed.
class NexbitKycPage extends StatefulWidget {
  const NexbitKycPage({super.key});

  @override
  State<NexbitKycPage> createState() => _NexbitKycPageState();
}

class _NexbitKycPageState extends State<NexbitKycPage> {
  bool _loading = true;
  KycStatus _status = KycStatus.unverified;
  String? _fullName;
  String? _idNumber;

  final _nameCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _idCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    try {
      final json = await ApiClient.getKycStatus(authToken.value);
      if (!mounted) return;
      setState(() {
        _status = kycStatusFromJson(json['status'] as String);
        _fullName = json['full_name'] as String?;
        _idNumber = json['id_number'] as String?;
        _loading = false;
      });
    } catch (_) {
      // Falls back to the unverified form on a failed fetch (offline,
      // backend down) rather than showing an error — worst case the
      // user just sees the submission form again.
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final id = _idCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = S.kycNameRequired);
      return;
    }
    if (!RegExp(r'^\d{16}$').hasMatch(id)) {
      setState(() => _error = S.kycIdNumberInvalid);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final json = await ApiClient.submitKyc(authToken.value, name, id);
      if (!mounted) return;
      setState(() {
        _status = kycStatusFromJson(json['status'] as String);
        _fullName = json['full_name'] as String?;
        _idNumber = json['id_number'] as String?;
        _submitting = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AccountPageScaffold(
      title: S.kycHeading,
      child: _loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(child: CircularProgressIndicator(color: NexbitColors.accent)),
            )
          : switch (_status) {
              KycStatus.unverified => _unverifiedForm(),
              KycStatus.pending => _statusCard(
                  icon: Icons.hourglass_top,
                  color: NexbitColors.accent2,
                  title: S.kycPendingTitle,
                  subtitle: S.kycPendingSubtitle,
                ),
              KycStatus.verified => _statusCard(
                  icon: Icons.verified,
                  color: NexbitColors.up,
                  title: S.kycVerifiedTitle,
                  subtitle: S.kycVerifiedSubtitle,
                ),
            },
    );
  }

  Widget _unverifiedForm() {
    return AccountSectionCard(
      title: S.kycFormHeading,
      children: [
        Text(S.kycDemoNotice, style: NexbitText.body(fontSize: 12.5, height: 1.4, color: NexbitColors.muted)),
        const SizedBox(height: 18),
        Text(S.kycFullNameLabel, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
        const SizedBox(height: 6),
        AccountDialogField(hint: S.kycFullNameHint, controller: _nameCtrl),
        const SizedBox(height: 14),
        Text(S.kycIdNumberLabel, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
        const SizedBox(height: 6),
        AccountDialogField(hint: S.kycIdNumberHint, controller: _idCtrl, keyboardType: TextInputType.number),
        if (_error != null) AccountDialogError(_error!),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(label: S.kycSubmitButton, loading: _submitting, onTap: _submit),
        ),
      ],
    );
  }

  Widget _statusCard({required IconData icon, required Color color, required String title, required String subtitle}) {
    return AccountSectionCard(
      title: S.kycHeading,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: NexbitText.body(fontSize: 14.5, weight: FontWeight.w700, color: NexbitColors.text)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: NexbitText.body(fontSize: 12.5, height: 1.4, color: NexbitColors.muted)),
                ],
              ),
            ),
          ],
        ),
        if (_fullName != null && _idNumber != null) ...[
          const SizedBox(height: 16),
          const AccountRowDivider(),
          const SizedBox(height: 4),
          AccountInfoRow(
            icon: Icons.badge_outlined,
            label: S.kycFullNameLabel,
            trailing: Text(_fullName!, style: NexbitText.body(fontSize: 13, color: NexbitColors.muted)),
          ),
          AccountInfoRow(
            icon: Icons.pin_outlined,
            label: S.kycIdNumberLabel,
            trailing: Text(_maskId(_idNumber!), style: NexbitText.mono(fontSize: 13, color: NexbitColors.muted)),
          ),
        ],
      ],
    );
  }

  String _maskId(String id) => id.length <= 4 ? id : '${'•' * (id.length - 4)}${id.substring(id.length - 4)}';
}
