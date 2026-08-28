import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../domain/models/staking_asset.dart';
import '../widgets/staking_page_header.dart';
import '../widgets/staking_sidebar.dart';
import 'nexbit_staking_dashboard_page.dart';
import 'nexbit_staking_portfolio_page.dart';
import 'nexbit_staking_settings_page.dart';

enum _TxType { send, receive }

enum _TxStatus { completed, pending }

class _TxEntry {
  final DateTime date;
  final String time;
  final String assetId;
  final String assetName;
  final Color color;
  final _TxType type;
  final String counterparty;
  final double amount;
  final int decimals;
  final _TxStatus status;
  const _TxEntry({
    required this.date,
    required this.time,
    required this.assetId,
    required this.assetName,
    required this.color,
    required this.type,
    required this.counterparty,
    required this.amount,
    required this.decimals,
    required this.status,
  });
}

final _kTxEntries = <_TxEntry>[
  _TxEntry(
    date: DateTime(2024, 12, 6), time: '9:16 AM', assetId: 'USDT', assetName: 'Tether', color: const Color(0xFF26A17B),
    type: _TxType.send, counterparty: 'uzbg9t', amount: 0.0094, decimals: 4, status: _TxStatus.completed,
  ),
  _TxEntry(
    date: DateTime(2024, 12, 2), time: '9:04 AM', assetId: 'BTC', assetName: 'Bitcoin', color: const Color(0xFFF7931A),
    type: _TxType.send, counterparty: '1vyrQB', amount: 0.4509, decimals: 4, status: _TxStatus.completed,
  ),
  _TxEntry(
    date: DateTime(2024, 11, 5), time: '3:16 PM', assetId: 'DASH', assetName: 'Dash', color: const Color(0xFF008DE4),
    type: _TxType.receive, counterparty: 'jxwCXW', amount: 5.456, decimals: 3, status: _TxStatus.pending,
  ),
  _TxEntry(
    date: DateTime(2024, 10, 12), time: '9:04 PM', assetId: 'ETH', assetName: 'Ethereum', color: const Color(0xFF627EEA),
    type: _TxType.receive, counterparty: 'JHU8qx', amount: 6.774, decimals: 3, status: _TxStatus.completed,
  ),
  _TxEntry(
    date: DateTime(2024, 10, 6), time: '5:32 PM', assetId: 'MATIC', assetName: 'Polygon', color: const Color(0xFF8247E5),
    type: _TxType.send, counterparty: 'r224s1', amount: 43.33, decimals: 2, status: _TxStatus.completed,
  ),
  _TxEntry(
    date: DateTime(2024, 10, 3), time: '6:16 PM', assetId: 'BTC', assetName: 'Bitcoin', color: const Color(0xFFF7931A),
    type: _TxType.send, counterparty: 'rret4s', amount: 0.00797, decimals: 5, status: _TxStatus.completed,
  ),
];

/// Staking "Riwayat Transaksi" — every send/receive transaction across
/// wallet and staking activity, with real All/Send/Receive filter tabs.
class NexbitStakingTransactionHistoryPage extends StatefulWidget {
  const NexbitStakingTransactionHistoryPage({super.key});

  @override
  State<NexbitStakingTransactionHistoryPage> createState() => _NexbitStakingTransactionHistoryPageState();
}

class _NexbitStakingTransactionHistoryPageState extends State<NexbitStakingTransactionHistoryPage> {
  _TxType? _filter; // null = all

  List<_TxEntry> get _filtered =>
      _filter == null ? _kTxEntries : _kTxEntries.where((e) => e.type == _filter).toList();

  String _fmtDate(DateTime d) => '${S.monthShort(d.month)} ${d.day}, ${d.year}';

  @override
  Widget build(BuildContext context) {
    void openDashboard() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingDashboardPage()),
        );
    void openMyStaking() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingPortfolioPage()),
        );
    void openSettings() => Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const NexbitStakingSettingsPage()),
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
                    activeId: 'txHistory',
                    onLogoTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    onDashboardTap: openDashboard,
                    onMyStakingTap: openMyStaking,
                    onTxHistoryTap: () {},
                    onSettingsTap: openSettings,
                  );
                  final content = _Content(
                    isMobile: isMobile,
                    filter: _filter,
                    entries: _filtered,
                    fmtDate: _fmtDate,
                    onFilterChanged: (f) => setState(() => _filter = f),
                  );
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

class _Content extends StatelessWidget {
  final bool isMobile;
  final _TxType? filter;
  final List<_TxEntry> entries;
  final String Function(DateTime) fmtDate;
  final ValueChanged<_TxType?> onFilterChanged;

  const _Content({
    required this.isMobile,
    required this.filter,
    required this.entries,
    required this.fmtDate,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final latest = _kTxEntries.first;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 18 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StakingPageHeader(title: S.stakingTxHistoryHeading, subtitle: S.stakingTxHistorySubheading, isMobile: isMobile),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 720;
              final overview = _OverviewCard(count: _kTxEntries.length, fmtDate: fmtDate);
              final avgTime = _AvgTimeCard(lastTxDate: fmtDate(latest.date), lastTxTime: latest.time);
              if (!wide) {
                return Column(children: [overview, const SizedBox(height: 16), avgTime]);
              }
              // IntrinsicHeight gives the Row a *finite* height to stretch
              // against — without it, CrossAxisAlignment.stretch here asks
              // each card to fill the Row's height, but the Row itself is
              // unbounded (this sits inside a scrolling Column), so the
              // constraint it hands back down is infinite.
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: overview),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: avgTime),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 22),
          _FilterTabs(selected: filter, onChanged: onFilterChanged),
          const SizedBox(height: 4),
          _TxTable(entries: entries, fmtDate: fmtDate),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final int count;
  final String Function(DateTime) fmtDate;
  const _OverviewCard({required this.count, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    final from = _kTxEntries.last.date;
    final to = _kTxEntries.first.date;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.stakingTxOverviewHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(gradient: NexbitColors.accentGradient, borderRadius: BorderRadius.circular(12)),
                    child: Icon(Icons.swap_vert_rounded, size: 22, color: const Color(0xFF04120E).withOpacity(0.65)),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$count', style: NexbitText.display(fontSize: 26, weight: FontWeight.w700)),
                      Text(S.stakingTxCountLabel, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
                    ],
                  ),
                ],
              ),
              _DateChip(label: S.stakingTxFrom, date: fmtDate(from)),
              _DateChip(label: S.stakingTxTo, date: fmtDate(to)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String date;
  const _DateChip({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: NexbitColors.surface2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: NexbitColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 13, color: NexbitColors.muted),
              const SizedBox(width: 8),
              Text(date, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _AvgTimeCard extends StatelessWidget {
  final String lastTxDate;
  final String lastTxTime;
  const _AvgTimeCard({required this.lastTxDate, required this.lastTxTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.stakingTxAvgTimeHeading, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700, color: NexbitColors.text)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 22, color: NexbitColors.accent),
              const SizedBox(width: 10),
              Text('41s', style: NexbitText.display(fontSize: 22, weight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: NexbitColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: NexbitColors.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.stakingTxLastTransaction, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted)),
                    const SizedBox(width: 8),
                    Text('$lastTxDate, $lastTxTime', style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  final _TxType? selected;
  final ValueChanged<_TxType?> onChanged;
  const _FilterTabs({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: NexbitColors.panel, borderRadius: BorderRadius.circular(10)),
      child: Wrap(
        children: [
          _Tab(label: S.stakingTxTabAll, active: selected == null, onTap: () => onChanged(null)),
          _Tab(label: S.stakingTxTabSend, active: selected == _TxType.send, onTap: () => onChanged(_TxType.send)),
          _Tab(label: S.stakingTxTabReceive, active: selected == _TxType.receive, onTap: () => onChanged(_TxType.receive)),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: active ? NexbitColors.surface2 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: NexbitText.body(
                fontSize: 12.5, weight: active ? FontWeight.w700 : FontWeight.w500, color: active ? NexbitColors.text : NexbitColors.muted)),
      ),
    );
  }
}

class _TxTable extends StatelessWidget {
  final List<_TxEntry> entries;
  final String Function(DateTime) fmtDate;
  const _TxTable({required this.entries, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: _h(S.stakingTxColDate)),
                      Expanded(flex: 3, child: _h(S.stakingTxColAsset)),
                      Expanded(flex: 4, child: _h(S.stakingTxColType)),
                      Expanded(flex: 2, child: _h(S.stakingColJumlah)),
                      Expanded(flex: 2, child: _h(S.stakingColStatus)),
                    ],
                  ),
                ),
              if (entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Center(child: Text(S.stakingTxEmpty, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2))),
                )
              else
                for (var i = 0; i < entries.length; i++)
                  _TxRow(entry: entries[i], wide: wide, isLast: i == entries.length - 1, fmtDate: fmtDate),
            ],
          );
        },
      ),
    );
  }

  Widget _h(String text) => Text(text, style: NexbitText.body(fontSize: 11, weight: FontWeight.w600, color: NexbitColors.muted2));
}

class _TxRow extends StatelessWidget {
  final _TxEntry entry;
  final bool wide;
  final bool isLast;
  final String Function(DateTime) fmtDate;
  const _TxRow({required this.entry, required this.wide, required this.isLast, required this.fmtDate});

  @override
  Widget build(BuildContext context) {
    final dateCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(fmtDate(entry.date), style: NexbitText.body(fontSize: 13, weight: FontWeight.w600, color: NexbitColors.text)),
        Text(entry.time, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
      ],
    );
    final assetCol = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: entry.color, shape: BoxShape.circle),
          child: Text(entry.assetId[0],
              style: NexbitText.mono(fontSize: 12, weight: FontWeight.w700, color: const Color(0xFF04120E))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(entry.assetName, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: NexbitColors.text)),
            Text(entry.assetId, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
          ],
        ),
      ],
    );
    final typeCol = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          entry.type == _TxType.send ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
          size: 15,
          color: entry.type == _TxType.send ? NexbitColors.down : NexbitColors.up,
        ),
        const SizedBox(width: 6),
        Text(entry.type == _TxType.send ? S.stakingTxSentTo : S.stakingTxReceivedFrom,
            style: NexbitText.body(fontSize: 12.5, color: NexbitColors.text)),
        const SizedBox(width: 6),
        Text('••••${entry.counterparty}', style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2)),
      ],
    );
    final amountCol = Text('${formatStakeAmount(entry.amount, decimals: entry.decimals)} ${entry.assetId}',
        style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600));
    final statusChip = _StatusChip(status: entry.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: NexbitColors.lineSoft))),
      child: wide
          ? Row(
              children: [
                Expanded(flex: 3, child: dateCol),
                Expanded(flex: 3, child: assetCol),
                Expanded(flex: 4, child: typeCol),
                Expanded(flex: 2, child: amountCol),
                Expanded(flex: 2, child: statusChip),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [assetCol, statusChip]),
                const SizedBox(height: 10),
                typeCol,
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [dateCol, amountCol]),
              ],
            ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final _TxStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == _TxStatus.completed;
    final color = isCompleted ? NexbitColors.accent : const Color(0xFFF3BA2F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCompleted ? Icons.check_circle_outline : Icons.schedule_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(isCompleted ? S.stakingTxStatusCompleted : S.stakingTxStatusPending,
              style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
