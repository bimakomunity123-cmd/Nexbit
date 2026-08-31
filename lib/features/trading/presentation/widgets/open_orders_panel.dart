import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/spot_order.dart';
import '../../domain/models/trading_pair.dart';

/// Fills the space below the order-entry form with a real "Open Orders /
/// Order History" table — backed by real backend orders for a logged-in
/// user, or a deterministic per-pair mock list for guests (see
/// NexbitTradingPage, which decides which one this gets and owns the
/// cancel handler for either case).
class OpenOrdersPanel extends StatefulWidget {
  final List<SpotOrder> orders;
  final ValueChanged<SpotOrder> onCancel;
  const OpenOrdersPanel({super.key, required this.orders, required this.onCancel});

  @override
  State<OpenOrdersPanel> createState() => _OpenOrdersPanelState();
}

class _OpenOrdersPanelState extends State<OpenOrdersPanel> {
  bool _showHistory = false;

  String _time(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _statusLabel(SpotOrderStatus s) => switch (s) {
        SpotOrderStatus.open => S.orderStatusOpen,
        SpotOrderStatus.filled => S.orderStatusFilled,
        SpotOrderStatus.cancelled => S.orderStatusCancelled,
      };

  Color _statusColor(SpotOrderStatus s) => switch (s) {
        SpotOrderStatus.open => NexbitColors.accent,
        SpotOrderStatus.filled => NexbitColors.up,
        SpotOrderStatus.cancelled => NexbitColors.muted2,
      };

  @override
  Widget build(BuildContext context) {
    final visible = widget.orders
        .where((o) => _showHistory ? o.status != SpotOrderStatus.open : o.status == SpotOrderStatus.open)
        .toList();

    return Container(
      color: NexbitColors.panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.lineSoft))),
            child: Row(
              children: [
                _OrdersTab(label: S.openOrdersTab, active: !_showHistory, onTap: () => setState(() => _showHistory = false)),
                const SizedBox(width: 20),
                _OrdersTab(label: S.orderHistoryTab, active: _showHistory, onTap: () => setState(() => _showHistory = true)),
              ],
            ),
          ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Text(
                  _showHistory ? S.noOrderHistory : S.noOpenOrders,
                  style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2),
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                // A horizontally-scrolling table needs a concrete, tight
                // width for its content (never an unbounded ConstrainedBox
                // under CrossAxisAlignment.stretch — that's the "BoxConstraints
                // forces an infinite width" crash) so it sizes to whichever
                // is bigger: the real viewport, or the table's minimum width.
                builder: (context, constraints) {
                  final tableWidth = max(constraints.maxWidth, 720.0);
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(width: tableWidth, child: _buildRows(visible)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRows(List<SpotOrder> visible) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _cell(S.ordersColPair, flex: 2, header: true),
              _cell(S.ordersColType, flex: 2, header: true),
              _cell(S.ordersColPrice, flex: 3, header: true),
              _cell(S.ordersColAmount, flex: 2, header: true),
              _cell(S.ordersColTotal, flex: 3, header: true),
              _cell(S.ordersColTime, flex: 2, header: true),
              _cell(S.ordersColStatus, flex: 2, header: true),
              if (!_showHistory) _cell(S.ordersColAction, flex: 2, header: true),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: visible.length,
            itemBuilder: (context, i) {
              final o = visible[i];
              final isBuy = o.side == SpotOrderSide.buy;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(
                  children: [
                    _cell(o.pair.label, flex: 2),
                    _cell(
                      '${isBuy ? S.buyAction('').trim() : S.sellAction('').trim()} · ${o.orderType.label}',
                      flex: 2,
                      color: isBuy ? NexbitColors.up : NexbitColors.down,
                    ),
                    _cell(formatPrice(o.price, o.pair.decimals), flex: 3, mono: true),
                    _cell(o.amount.toStringAsFixed(o.pair.decimals >= 3 ? 3 : 5), flex: 2, mono: true),
                    _cell(formatPrice(o.total, 0), flex: 3, mono: true),
                    _cell(_time(o.createdAt), flex: 2, mono: true, color: NexbitColors.muted2),
                    _cell(_statusLabel(o.status), flex: 2, color: _statusColor(o.status)),
                    if (!_showHistory)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => widget.onCancel(o),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              S.orderCancelAction,
                              style: NexbitText.body(fontSize: 11.5, weight: FontWeight.w600, color: NexbitColors.down),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _cell(String text, {required int flex, bool header = false, bool mono = false, Color? color}) {
    final style = header
        ? NexbitText.mono(fontSize: 10.5, color: NexbitColors.muted2)
        : mono
            ? NexbitText.mono(fontSize: 12, color: color ?? NexbitColors.text)
            : NexbitText.body(fontSize: 12, color: color ?? NexbitColors.text);
    return Expanded(flex: flex, child: Text(text, style: style, overflow: TextOverflow.ellipsis));
  }
}

/// Deterministic per-pair fake order history — shown only to guests
/// (never touches the backend), same purpose as Futures' seeded demo
/// position: the page still looks alive to a visitor who hasn't logged
/// in yet.
List<SpotOrder> seedGuestOrders(TradingPair pair) {
  final rng = Random(pair.id.hashCode);
  final now = DateTime.now();
  final types = OrderType.values;
  return List.generate(22, (i) {
    final isOpen = i < 8;
    final priceJitter = 1 + (rng.nextDouble() - 0.5) * 0.01;
    return SpotOrder(
      pair: pair,
      side: rng.nextBool() ? SpotOrderSide.buy : SpotOrderSide.sell,
      orderType: types[rng.nextInt(types.length)],
      price: pair.base * priceJitter,
      amount: double.parse((rng.nextDouble() * 0.5 + 0.01).toStringAsFixed(pair.decimals >= 3 ? 3 : 5)),
      status: isOpen ? SpotOrderStatus.open : (rng.nextBool() ? SpotOrderStatus.filled : SpotOrderStatus.cancelled),
      createdAt: now.subtract(Duration(minutes: i * 37 + 5)),
    );
  });
}

class _OrdersTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _OrdersTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 12.5,
            weight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? NexbitColors.text : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}
