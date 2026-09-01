import 'package:flutter/material.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../domain/models/spot_order.dart';
import '../../domain/models/trading_pair.dart';

/// The Buy/Sell order-entry panel — Limit/Instant/Stop-Limit tabs shared
/// by both columns, real price/amount fields (Instant uses the live
/// market price, Limit/Stop-Limit take a typed price), a %-of-buying-
/// power slider, and a submit that actually places a real order via
/// [onSubmitOrder] — see NexbitTradingPage, which wires that to the
/// backend (ApiClient.createSpotOrder) for a logged-in user.
class OrderFormPanel extends StatefulWidget {
  final TradingPair pair;
  final double idrBalance;
  final double Function(String assetId) holdingQuantityOf;
  /// Returns whether the order actually went through — see
  /// NexbitTradingPage._submitOrder, which is also the one place that
  /// shows the resulting success/error snackbar, only once the real
  /// backend result is known.
  final Future<bool> Function(SpotOrderSide side, OrderType orderType, double price, double amount) onSubmitOrder;

  const OrderFormPanel({
    super.key,
    required this.pair,
    this.idrBalance = 0,
    required this.holdingQuantityOf,
    required this.onSubmitOrder,
  });

  @override
  State<OrderFormPanel> createState() => _OrderFormPanelState();
}

class _OrderFormPanelState extends State<OrderFormPanel> {
  OrderType _orderType = OrderType.limit;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NexbitColors.panel,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: OrderType.values.map((type) {
              final active = type == _orderType;
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => setState(() => _orderType = type),
                  child: Container(
                    padding: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
                    ),
                    child: Text(
                      type.label,
                      style: NexbitText.body(
                        fontSize: 13,
                        weight: active ? FontWeight.w600 : FontWeight.w400,
                        color: active ? NexbitColors.text : NexbitColors.muted,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 480;
              final buyForm = _SideForm(
                key: ValueKey('buy-${widget.pair.id}'),
                pair: widget.pair,
                orderType: _orderType,
                isBuy: true,
                maxQuantity: widget.pair.base <= 0 ? 0 : widget.idrBalance / widget.pair.base,
                onSubmit: (price, amount) => widget.onSubmitOrder(SpotOrderSide.buy, _orderType, price, amount),
              );
              final sellForm = _SideForm(
                key: ValueKey('sell-${widget.pair.id}'),
                pair: widget.pair,
                orderType: _orderType,
                isBuy: false,
                maxQuantity: widget.holdingQuantityOf(widget.pair.id),
                onSubmit: (price, amount) => widget.onSubmitOrder(SpotOrderSide.sell, _orderType, price, amount),
              );
              if (narrow) {
                return Column(children: [buyForm, const SizedBox(height: 24), sellForm]);
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: buyForm),
                    const SizedBox(width: 24),
                    Expanded(child: sellForm),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SideForm extends StatefulWidget {
  final TradingPair pair;
  final OrderType orderType;
  final bool isBuy;
  // Buy: how much of `pair` the current IDR balance could afford at the
  // live price. Sell: how much of `pair` is actually held. Either way,
  // this is what the 25/50/75/100% quick-amount row is a fraction of.
  final double maxQuantity;
  final Future<bool> Function(double price, double amount) onSubmit;

  const _SideForm({
    super.key,
    required this.pair,
    required this.orderType,
    required this.isBuy,
    required this.maxQuantity,
    required this.onSubmit,
  });

  @override
  State<_SideForm> createState() => _SideFormState();
}

class _SideFormState extends State<_SideForm> {
  late final _priceController = TextEditingController(text: formatPrice(widget.pair.base, widget.pair.decimals));
  final _amountController = TextEditingController();
  int? _activePct;
  bool _submitting = false;

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;

  // Instant orders always execute at the actual current price, not
  // whatever a stale typed value might say; Limit/Stop-Limit use the
  // typed price.
  double get _price =>
      widget.orderType == OrderType.instant ? widget.pair.base : parsePriceInput(_priceController.text);

  double get _total => _price * _amount;

  void _applyPct(int pct) {
    final qty = widget.maxQuantity * pct / 100;
    setState(() {
      _amountController.text = qty.toStringAsFixed(widget.pair.decimals >= 3 ? 4 : 5);
      _activePct = pct;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!isLoggedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.tradingLoginRequiredSnack),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: S.navLogin,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitLoginPage())),
          ),
        ),
      );
      return;
    }
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.tradingAmountRequired), duration: const Duration(seconds: 2)),
      );
      return;
    }
    setState(() => _submitting = true);
    // widget.onSubmit (see NexbitTradingPage._submitOrder) is the one
    // that actually shows the resulting success/error snackbar, once
    // the real backend result is known — this only decides whether to
    // clear the form afterward.
    final ok = await widget.onSubmit(_price, _amount);
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (ok) {
        _amountController.clear();
        _activePct = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pair = widget.pair;
    final accent = widget.isBuy ? NexbitColors.up : NexbitColors.down;
    final actionLabel = widget.isBuy ? S.buyAction(pair.id) : S.sellAction(pair.id);
    final priceStr = formatPrice(pair.base, pair.decimals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(actionLabel, style: NexbitText.body(fontSize: 14, weight: FontWeight.w700, color: accent)),
        const SizedBox(height: 12),
        ..._fieldsForOrderType(priceStr),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: widget.isBuy ? const Color(0xFF04120E) : const Color(0xFF1A0208),
              disabledBackgroundColor: accent,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              textStyle: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700),
            ),
            child: _submitting
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: widget.isBuy ? const Color(0xFF04120E) : const Color(0xFF1A0208),
                    ),
                  )
                : Text(actionLabel),
          ),
        ),
      ],
    );
  }

  List<Widget> _fieldsForOrderType(String priceStr) {
    switch (widget.orderType) {
      case OrderType.limit:
        return [
          _InputField(label: S.formPrice, unit: widget.pair.quote, controller: _priceController, onChanged: () => setState(() {})),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: widget.pair.id, controller: _amountController, hint: '0.0', onChanged: () => setState(() => _activePct = null)),
          const SizedBox(height: 8),
          _PctRow(active: _activePct, onTap: _applyPct),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotal, quote: widget.pair.quote, total: _total),
          const SizedBox(height: 14),
        ];
      case OrderType.instant:
        return [
          _MarketNote(priceStr: priceStr, quote: widget.pair.quote),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: widget.pair.id, controller: _amountController, hint: '0.0', onChanged: () => setState(() => _activePct = null)),
          const SizedBox(height: 8),
          _PctRow(active: _activePct, onTap: _applyPct),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotalEstimated, quote: widget.pair.quote, total: _total),
          const SizedBox(height: 14),
        ];
      case OrderType.stopLimit:
        return [
          // The Stop Price has no real trigger behind it in this demo —
          // there's no matching engine watching live prices for orders
          // that aren't Instant (see SpotOrder's docstring in
          // backend/app/models.py) — so only the Limit Price below is
          // actually sent to the backend; Stop Price stays a decorative
          // field, same as it effectively already was before this form
          // had any backend behind it at all.
          _InputField(label: S.formStopPrice, unit: widget.pair.quote, initialValue: priceStr),
          const SizedBox(height: 10),
          _InputField(label: S.formLimitPrice, unit: widget.pair.quote, controller: _priceController, onChanged: () => setState(() {})),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: widget.pair.id, controller: _amountController, hint: '0.0', onChanged: () => setState(() => _activePct = null)),
          const SizedBox(height: 8),
          _PctRow(active: _activePct, onTap: _applyPct),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotal, quote: widget.pair.quote, total: _total),
          const SizedBox(height: 14),
        ];
    }
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String unit;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final VoidCallback? onChanged;

  const _InputField({required this.label, required this.unit, this.controller, this.initialValue, this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: NexbitColors.surface2,
            border: Border.all(color: NexbitColors.line),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller ?? (initialValue != null ? TextEditingController(text: initialValue) : null),
                  onChanged: (_) => onChanged?.call(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: NexbitText.mono(fontSize: 13),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: NexbitText.mono(fontSize: 13, color: NexbitColors.muted2),
                  ),
                ),
              ),
              Text(unit, style: NexbitText.mono(fontSize: 11.5, color: NexbitColors.muted2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _MarketNote extends StatelessWidget {
  final String priceStr;
  final String quote;
  const _MarketNote({required this.priceStr, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: NexbitColors.surface2,
        border: Border.all(color: NexbitColors.line),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(S.formCurrentMarketPrice, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
          Text('$priceStr $quote', style: NexbitText.mono(fontSize: 13, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Discrete 25/50/75/100%-of-buying-power quick amounts — replaces the
/// old decorative continuous slider with something that actually sets
/// the amount field, same UX idea as Futures' own %-of-balance row.
class _PctRow extends StatelessWidget {
  final int? active;
  final ValueChanged<int> onTap;
  const _PctRow({required this.active, required this.onTap});

  static const _pcts = [25, 50, 75, 100];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final pct in _pcts) ...[
          if (pct != _pcts.first) const SizedBox(width: 6),
          Expanded(child: _PctButton(pct: pct, active: active == pct, onTap: () => onTap(pct))),
        ],
      ],
    );
  }
}

class _PctButton extends StatelessWidget {
  final int pct;
  final bool active;
  final VoidCallback onTap;
  const _PctButton({required this.pct, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? NexbitColors.accent.withOpacity(0.12) : NexbitColors.surface2,
          border: Border.all(color: active ? NexbitColors.accent : NexbitColors.line),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('$pct%',
            style: NexbitText.mono(
                fontSize: 11, weight: FontWeight.w600, color: active ? NexbitColors.accent : NexbitColors.muted)),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String quote;
  final double total;
  const _TotalRow({required this.label, required this.quote, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
        Text('${formatPrice(total, 0)} $quote', style: NexbitText.mono(fontSize: 12, color: NexbitColors.muted)),
      ],
    );
  }
}
