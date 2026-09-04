import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/futures_contract.dart';
import '../../domain/models/futures_order.dart';
import '../../domain/models/futures_position.dart';

enum _PosTab { positions, openOrders, orderHistory, tradeHistory }

/// The Positions / Open Orders / Order History / Trade History tab strip
/// under the chart — the real functional core of the page: closing a
/// position here actually removes it (and books its PnL), same
/// functional-realism bar as the rest of this app's mock trading flows.
class FuturesPositionsPanel extends StatefulWidget {
  final List<FuturesPosition> positions;
  final double Function(String contractId) markPriceOf;
  final ValueChanged<FuturesPosition> onClose;
  /// Closed positions for the Trade History tab — empty for a guest
  /// (never fetched) or while a logged-in user's history is still
  /// loading, same as every other list this app fetches post-login.
  final List<ClosedFuturesPosition> closedPositions;
  /// Every order ever placed — Open Orders and Order History both
  /// filter this same list by status, same split Spot's OpenOrdersPanel
  /// uses.
  final List<FuturesOrder> orders;
  final ValueChanged<FuturesOrder> onCancelOrder;

  const FuturesPositionsPanel({
    super.key,
    required this.positions,
    required this.markPriceOf,
    required this.onClose,
    this.closedPositions = const [],
    this.orders = const [],
    required this.onCancelOrder,
  });

  @override
  State<FuturesPositionsPanel> createState() => _FuturesPositionsPanelState();
}

class _FuturesPositionsPanelState extends State<FuturesPositionsPanel> {
  _PosTab _tab = _PosTab.positions;

  List<FuturesOrder> get _openOrders => widget.orders.where((o) => o.status == FuturesOrderStatus.open).toList();
  List<FuturesOrder> get _orderHistory => widget.orders.where((o) => o.status != FuturesOrderStatus.open).toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Wrap(
              spacing: 22,
              runSpacing: 6,
              children: [
                _Tab(S.futuresTabPositions(widget.positions.length), active: _tab == _PosTab.positions, onTap: () => setState(() => _tab = _PosTab.positions)),
                _Tab(S.futuresTabOpenOrders(_openOrders.length), active: _tab == _PosTab.openOrders, onTap: () => setState(() => _tab = _PosTab.openOrders)),
                _Tab(S.futuresTabOrderHistory, active: _tab == _PosTab.orderHistory, onTap: () => setState(() => _tab = _PosTab.orderHistory)),
                _Tab(S.futuresTabTradeHistory, active: _tab == _PosTab.tradeHistory, onTap: () => setState(() => _tab = _PosTab.tradeHistory)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10), child: Divider(height: 1, color: NexbitColors.line)),
          switch (_tab) {
            _PosTab.positions => _positionsTable(),
            _PosTab.openOrders => _ordersTable(_openOrders, showAction: true, emptyLabel: S.futuresNoOpenOrders),
            _PosTab.orderHistory => _ordersTable(_orderHistory, showAction: false, emptyLabel: S.futuresNoHistory),
            _PosTab.tradeHistory => _tradeHistoryTable(),
          },
        ],
      ),
    );
  }

  /// Open Orders and Order History both render this — real order rows,
  /// or an empty state with the header still intact (an empty table
  /// reads as "not implemented yet" far less than a lone floating
  /// sentence does, matching how every real exchange keeps headers up
  /// on empty tabs).
  Widget _ordersTable(List<FuturesOrder> orders, {required bool showAction, required String emptyLabel}) {
    if (orders.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(emptyLabel, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2))),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 760.0;
        final columns = [
          S.futuresColTime,
          S.futuresColSymbol,
          S.futuresColSide,
          S.futuresColType,
          S.futuresColPrice,
          S.futuresColAmount,
          S.futuresColStatus,
          if (showAction) '',
        ];
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [for (final c in columns) _cell(c, flex: 1, header: true)]),
            ),
            const Divider(height: 1, color: NexbitColors.lineSoft),
            for (final o in orders) _orderRow(o, showAction: showAction),
          ],
        );
        if (constraints.maxWidth >= minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: table),
        );
      },
    );
  }

  Widget _orderRow(FuturesOrder o, {required bool showAction}) {
    final t = o.createdAt;
    final time = '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _cell(time, flex: 1, mono: true, color: NexbitColors.muted2),
          _cell(o.contract.label, flex: 1, bold: true),
          Expanded(
            flex: 1,
            child: Text(
              o.side == OrderSide.long ? S.futuresLong : S.futuresShort,
              style: NexbitText.body(
                fontSize: 11.5,
                weight: FontWeight.w700,
                color: o.side == OrderSide.long ? NexbitColors.up : NexbitColors.down,
              ),
            ),
          ),
          _cell(_orderTypeLabel(o.orderType), flex: 1),
          _cell(formatUsdt(o.price, o.contract.decimals), flex: 1, mono: true),
          _cell('${o.size.toStringAsFixed(2)} ${o.contract.id}', flex: 1, mono: true),
          _cell(_statusLabel(o.status), flex: 1, color: _statusColor(o.status)),
          if (showAction)
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => widget.onCancelOrder(o),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(S.orderCancelAction,
                      style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: NexbitColors.down)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _orderTypeLabel(FuturesOrderType t) => switch (t) {
        FuturesOrderType.limit => S.futuresTabLimit,
        FuturesOrderType.market => S.futuresTabMarket,
        FuturesOrderType.stopLimit => S.futuresTabStopLimit,
        FuturesOrderType.stopMarket => S.futuresTabStopMarket,
      };

  String _statusLabel(FuturesOrderStatus s) => switch (s) {
        FuturesOrderStatus.open => S.orderStatusOpen,
        FuturesOrderStatus.filled => S.orderStatusFilled,
        FuturesOrderStatus.cancelled => S.orderStatusCancelled,
      };

  Color _statusColor(FuturesOrderStatus s) => switch (s) {
        FuturesOrderStatus.open => NexbitColors.accent,
        FuturesOrderStatus.filled => NexbitColors.up,
        FuturesOrderStatus.cancelled => NexbitColors.muted2,
      };

  Widget _positionsTable() {
    if (widget.positions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(S.futuresNoPositions, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2))),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 760.0;
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _cell(S.futuresColContract, flex: 2, header: true),
                  _cell(S.futuresColSide, flex: 1, header: true),
                  _cell(S.futuresColSize, flex: 2, header: true),
                  _cell(S.futuresColEntryPrice, flex: 2, header: true),
                  _cell(S.futuresColMarkPrice, flex: 2, header: true),
                  _cell(S.futuresColPnl, flex: 2, header: true),
                  _cell(S.futuresColLiqPrice, flex: 2, header: true),
                  _cell('', flex: 1, header: true),
                ],
              ),
            ),
            for (final p in widget.positions) _positionRow(p),
          ],
        );
        if (constraints.maxWidth >= minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: table),
        );
      },
    );
  }

  Widget _positionRow(FuturesPosition p) {
    final mark = widget.markPriceOf(p.contract.id);
    final pnl = p.pnl(mark);
    final pnlPct = p.pnlPercent(mark);
    final pnlColor = pnl >= 0 ? NexbitColors.up : NexbitColors.down;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _cell(p.contract.label, flex: 2, bold: true),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (p.side == OrderSide.long ? NexbitColors.up : NexbitColors.down).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    p.side == OrderSide.long ? S.futuresLong : S.futuresShort,
                    textAlign: TextAlign.center,
                    style: NexbitText.body(
                      fontSize: 11.5,
                      weight: FontWeight.w700,
                      color: p.side == OrderSide.long ? NexbitColors.up : NexbitColors.down,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${p.marginMode == MarginMode.cross ? S.futuresMarginModeCross : S.futuresMarginModeIsolated} ${p.leverage}x',
                  style: NexbitText.body(fontSize: 10, color: NexbitColors.muted2),
                ),
              ],
            ),
          ),
          _cell('${p.size.toStringAsFixed(2)} ${p.contract.id}', flex: 2, mono: true),
          _cell(formatUsdt(p.entryPrice, p.contract.decimals), flex: 2, mono: true),
          _cell(formatUsdt(mark, p.contract.decimals), flex: 2, mono: true),
          Expanded(
            flex: 2,
            child: Text(
              '${pnl >= 0 ? '+' : ''}${pnl.abs().toStringAsFixed(2)} ${p.contract.quote}\n(${pnl >= 0 ? '+' : ''}${pnlPct.toStringAsFixed(2)}%)',
              style: NexbitText.mono(fontSize: 11.5, weight: FontWeight.w700, color: pnlColor),
            ),
          ),
          _cell(formatUsdt(p.liqPrice, p.contract.decimals), flex: 2, mono: true, color: NexbitColors.down),
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => widget.onClose(p),
              style: OutlinedButton.styleFrom(
                foregroundColor: NexbitColors.text,
                side: const BorderSide(color: NexbitColors.line),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(S.futuresClose, style: NexbitText.body(fontSize: 11.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tradeHistoryTable() {
    if (widget.closedPositions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Center(child: Text(S.futuresNoHistory, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2))),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 760.0;
        final columns = [
          S.futuresColTime,
          S.futuresColSymbol,
          S.futuresColSide,
          S.futuresColPrice,
          S.futuresColAmount,
          S.futuresColFee,
          S.futuresColPnl,
        ];
        final table = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [for (final c in columns) _cell(c, flex: 1, header: true)]),
            ),
            const Divider(height: 1, color: NexbitColors.lineSoft),
            for (final p in widget.closedPositions) _tradeHistoryRow(p),
          ],
        );
        if (constraints.maxWidth >= minWidth) return table;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: table),
        );
      },
    );
  }

  Widget _tradeHistoryRow(ClosedFuturesPosition p) {
    final pnlColor = p.realizedPnl >= 0 ? NexbitColors.up : NexbitColors.down;
    final t = p.closedAt;
    final time = '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _cell(time, flex: 1, mono: true, color: NexbitColors.muted2),
          _cell(p.contract.label, flex: 1, bold: true),
          Expanded(
            flex: 1,
            child: Text(
              p.side == OrderSide.long ? S.futuresLong : S.futuresShort,
              style: NexbitText.body(
                fontSize: 11.5,
                weight: FontWeight.w700,
                color: p.side == OrderSide.long ? NexbitColors.up : NexbitColors.down,
              ),
            ),
          ),
          _cell(formatUsdt(p.exitPrice, p.contract.decimals), flex: 1, mono: true),
          _cell('${p.size.toStringAsFixed(2)} ${p.contract.id}', flex: 1, mono: true),
          // No fee model anywhere in this demo (see other panels'
          // docstrings) — shown as 0.00 rather than omitted, so the
          // column header this table already had isn't left dangling.
          _cell('0.00 ${p.contract.quote}', flex: 1, mono: true, color: NexbitColors.muted2),
          _cell(
            '${p.realizedPnl >= 0 ? '+' : ''}${p.realizedPnl.toStringAsFixed(2)} ${p.contract.quote}',
            flex: 1,
            mono: true,
            color: pnlColor,
          ),
        ],
      ),
    );
  }

  Widget _cell(String text, {required int flex, bool header = false, bool bold = false, bool mono = false, Color? color}) {
    final style = header
        ? NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)
        : mono
            ? NexbitText.mono(fontSize: 12, color: color ?? NexbitColors.text)
            : NexbitText.body(fontSize: 12.5, weight: bold ? FontWeight.w700 : FontWeight.w400, color: color ?? NexbitColors.text);
    return Expanded(flex: flex, child: Text(text, style: style, overflow: TextOverflow.ellipsis));
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab(this.label, {required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 13,
            weight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? NexbitColors.text : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
