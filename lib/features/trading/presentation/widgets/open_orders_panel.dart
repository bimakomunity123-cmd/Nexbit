import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

enum _OrderStatus { open, filled, cancelled }

class _MockOrder {
  final String pair;
  final OrderType type;
  final bool isBuy;
  final double price;
  final double amount;
  final int decimals;
  final DateTime time;
  _OrderStatus status;

  _MockOrder({
    required this.pair,
    required this.type,
    required this.isBuy,
    required this.price,
    required this.amount,
    required this.decimals,
    required this.time,
    required this.status,
  });

  double get total => price * amount;
}

/// Fills the space below the order-entry form with a real "Open Orders /
/// Order History" table — the panel every trading platform has there, so
/// that area reads as finished rather than empty.
class OpenOrdersPanel extends StatefulWidget {
  final TradingPair pair;
  const OpenOrdersPanel({super.key, required this.pair});

  @override
  State<OpenOrdersPanel> createState() => _OpenOrdersPanelState();
}

class _OpenOrdersPanelState extends State<OpenOrdersPanel> {
  bool _showHistory = false;
  late List<_MockOrder> _orders = _seed(widget.pair);

  static List<_MockOrder> _seed(TradingPair pair) {
    final rng = Random(pair.id.hashCode);
    final now = DateTime.now();
    final types = OrderType.values;
    // A generous count, split across both tabs, so this still fills
    // tall/large monitors instead of running dry after just 1-2 rows and
    // leaving empty (if correctly-coloured) space below.
    return List.generate(22, (i) {
      final isOpen = i < 8;
      final priceJitter = 1 + (rng.nextDouble() - 0.5) * 0.01;
      return _MockOrder(
        pair: pair.label,
        type: types[rng.nextInt(types.length)],
        isBuy: rng.nextBool(),
        price: pair.base * priceJitter,
        amount: double.parse((rng.nextDouble() * 0.5 + 0.01).toStringAsFixed(pair.decimals >= 3 ? 3 : 5)),
        decimals: pair.decimals,
        time: now.subtract(Duration(minutes: i * 37 + 5)),
        status: isOpen ? _OrderStatus.open : (rng.nextBool() ? _OrderStatus.filled : _OrderStatus.cancelled),
      );
    });
  }

  @override
  void didUpdateWidget(covariant OpenOrdersPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pair.id != widget.pair.id) setState(() => _orders = _seed(widget.pair));
  }

  void _cancel(_MockOrder o) {
    setState(() => o.status = _OrderStatus.cancelled);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(S.orderCancelledSnack), duration: const Duration(seconds: 2)),
    );
  }

  String _time(DateTime t) =>
      '${t.day.toString().padLeft(2, '0')}/${t.month.toString().padLeft(2, '0')} '
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _statusLabel(_OrderStatus s) => switch (s) {
        _OrderStatus.open => S.orderStatusOpen,
        _OrderStatus.filled => S.orderStatusFilled,
        _OrderStatus.cancelled => S.orderStatusCancelled,
      };

  Color _statusColor(_OrderStatus s) => switch (s) {
        _OrderStatus.open => NexbitColors.accent,
        _OrderStatus.filled => NexbitColors.up,
        _OrderStatus.cancelled => NexbitColors.muted2,
      };

  @override
  Widget build(BuildContext context) {
    final visible =
        _orders.where((o) => _showHistory ? o.status != _OrderStatus.open : o.status == _OrderStatus.open).toList();

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

  Widget _buildRows(List<_MockOrder> visible) {
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                child: Row(
                  children: [
                    _cell(o.pair, flex: 2),
                    _cell(
                      '${o.isBuy ? S.buyAction('').trim() : S.sellAction('').trim()} · ${o.type.label}',
                      flex: 2,
                      color: o.isBuy ? NexbitColors.up : NexbitColors.down,
                    ),
                    _cell(formatPrice(o.price, o.decimals), flex: 3, mono: true),
                    _cell(o.amount.toStringAsFixed(o.decimals >= 3 ? 3 : 5), flex: 2, mono: true),
                    _cell(formatPrice(o.total, o.decimals), flex: 3, mono: true),
                    _cell(_time(o.time), flex: 2, mono: true, color: NexbitColors.muted2),
                    _cell(_statusLabel(o.status), flex: 2, color: _statusColor(o.status)),
                    if (!_showHistory)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () => _cancel(o),
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
