import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../widgets/account_widgets.dart';

/// "Bantuan" — a searchable FAQ plus quick-help shortcuts, a contact
/// card, and a system-status board. The FAQ search and expand/collapse
/// are genuinely functional; "Chat dengan Support" and the quick-help
/// shortcuts just surface a "coming soon" notice since there's no real
/// support backend behind this demo.
class NexbitHelpPage extends StatefulWidget {
  const NexbitHelpPage({super.key});

  @override
  State<NexbitHelpPage> createState() => _NexbitHelpPageState();
}

class _NexbitHelpPageState extends State<NexbitHelpPage> {
  final _searchController = TextEditingController();
  String _query = '';
  // Tracked by question text rather than list position — the filtered
  // list's order/length changes as the user types, so a positional index
  // would end up "expanding" a different, unrelated question.
  String? _expandedFaqQuestion = S.helpFaqQ1;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        final faqs = [
          (S.helpFaqQ1, S.helpFaqA1),
          (S.helpFaqQ2, S.helpFaqA2),
          (S.helpFaqQ3, S.helpFaqA3),
          (S.helpFaqQ4, S.helpFaqA4),
        ];
        final filteredFaqs = _query.isEmpty
            ? faqs
            : faqs.where((f) => f.$1.toLowerCase().contains(_query.toLowerCase())).toList();

        return AccountPageScaffold(
          title: S.helpHeading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v),
                style: NexbitText.body(fontSize: 14, color: NexbitColors.text),
                decoration: InputDecoration(
                  hintText: S.helpSearchHint,
                  hintStyle: NexbitText.body(fontSize: 14, color: NexbitColors.muted2),
                  prefixIcon: const Icon(Icons.search, size: 20, color: NexbitColors.muted),
                  filled: true,
                  fillColor: NexbitColors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexbitColors.line)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexbitColors.line)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexbitColors.accent)),
                ),
              ),
              const SizedBox(height: 22),
              Text(S.helpQuickHelp, style: NexbitText.body(fontSize: 15.5, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 560;
                  final cards = [
                    _QuickHelpCard(icon: Icons.rocket_launch_outlined, title: S.helpGettingStarted, desc: S.helpGettingStartedDesc, onTap: () => _snack(S.accountComingSoonSnack)),
                    _QuickHelpCard(icon: Icons.account_balance_wallet_outlined, title: S.helpDepositWithdraw, desc: S.helpDepositWithdrawDesc, onTap: () => _snack(S.accountComingSoonSnack)),
                    _QuickHelpCard(icon: Icons.candlestick_chart_outlined, title: S.helpTrading, desc: S.helpTradingDesc, onTap: () => _snack(S.accountComingSoonSnack)),
                    _QuickHelpCard(icon: Icons.shield_outlined, title: S.helpSecurity, desc: S.helpSecurityDesc, onTap: () => _snack(S.accountComingSoonSnack)),
                  ];
                  if (isMobile) {
                    return Column(children: [for (final c in cards) Padding(padding: const EdgeInsets.only(bottom: 10), child: c)]);
                  }
                  return Row(
                    children: [
                      for (var i = 0; i < cards.length; i++) ...[
                        Expanded(child: cards[i]),
                        if (i != cards.length - 1) const SizedBox(width: 10),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              AccountSectionCard(
                title: S.helpFaqHeading,
                children: [
                  if (filteredFaqs.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(_noResultsLabel(locale), style: NexbitText.body(fontSize: 13, color: NexbitColors.muted2)),
                    )
                  else
                    for (var i = 0; i < filteredFaqs.length; i++) ...[
                      _FaqTile(
                        question: filteredFaqs[i].$1,
                        answer: filteredFaqs[i].$2,
                        expanded: _expandedFaqQuestion == filteredFaqs[i].$1,
                        onTap: () => setState(() =>
                            _expandedFaqQuestion = _expandedFaqQuestion == filteredFaqs[i].$1 ? null : filteredFaqs[i].$1),
                      ),
                      if (i != filteredFaqs.length - 1) const AccountRowDivider(),
                    ],
                  const SizedBox(height: 12),
                  Hoverable(
                    hoverScale: 1.02,
                    builder: (context, hovered) => InkWell(
                      onTap: () => _snack(S.accountComingSoonSnack),
                      child: Text(S.helpViewAllFaq, style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.accent)),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(18),
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [NexbitColors.accent.withOpacity(0.10), NexbitColors.accent2.withOpacity(0.08)]),
                  border: Border.all(color: NexbitColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.helpContactUs, style: NexbitText.body(fontSize: 15.5, weight: FontWeight.w700, color: NexbitColors.text)),
                    const SizedBox(height: 6),
                    Text(S.helpContactUsDesc, style: NexbitText.body(fontSize: 13, height: 1.4)),
                    const SizedBox(height: 14),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 14,
                      runSpacing: 10,
                      children: [
                        Hoverable(
                          hoverScale: 1.03,
                          builder: (context, hovered) => InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () => _snack(S.accountComingSoonSnack),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(gradient: NexbitColors.accentGradient, borderRadius: BorderRadius.circular(9)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF04120E)),
                                  const SizedBox(width: 8),
                                  Text(S.helpChatSupport, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: const Color(0xFF04120E))),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Text('${S.helpOrEmail} support@nexbit.app', style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                      ],
                    ),
                  ],
                ),
              ),
              AccountSectionCard(
                title: S.helpSystemStatus,
                children: [
                  _statusRow(S.helpStatusTrading),
                  const AccountRowDivider(),
                  _statusRow(S.helpStatusDeposit),
                  const AccountRowDivider(),
                  _statusRow(S.helpStatusWithdrawal),
                  const AccountRowDivider(),
                  _statusRow(S.helpStatusMarketData),
                  const AccountRowDivider(),
                  _statusRow(S.helpStatusApi),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _noResultsLabel(AppLocale locale) => locale == AppLocale.id ? 'Tidak ada hasil ditemukan' : 'No results found';

  Widget _statusRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(child: Text(label, style: NexbitText.body(fontSize: 13.5, color: NexbitColors.text))),
          Container(
            width: 7,
            height: 7,
            margin: const EdgeInsets.only(right: 7),
            decoration: const BoxDecoration(color: NexbitColors.up, shape: BoxShape.circle),
          ),
          Text(S.helpStatusOperational, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, color: NexbitColors.up)),
        ],
      ),
    );
  }
}

class _QuickHelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final VoidCallback onTap;
  const _QuickHelpCard({required this.icon, required this.title, required this.desc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.02,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: NexbitColors.surface,
            border: Border.all(color: hovered ? NexbitColors.accent : NexbitColors.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: NexbitColors.accent),
              const SizedBox(height: 10),
              Text(title, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(height: 4),
              Text(desc, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool expanded;
  final VoidCallback onTap;
  const _FaqTile({required this.question, required this.answer, required this.expanded, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(question, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w600, color: NexbitColors.text))),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 160),
                  turns: expanded ? 0.5 : 0,
                  child: const Icon(Icons.keyboard_arrow_down, size: 20, color: NexbitColors.muted),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 160),
              crossFadeState: expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 8, right: 24),
                child: Text(answer, style: NexbitText.body(fontSize: 12.5, height: 1.5, color: NexbitColors.muted)),
              ),
              secondChild: const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }
}
