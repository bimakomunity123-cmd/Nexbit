import 'package:flutter/material.dart';
import '../../../../core/auth/session.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../domain/models/futures_contract.dart';
import '../../domain/models/futures_order.dart';
import '../../domain/models/futures_position.dart';

/// The order-entry form — Cross/Isolated margin mode, independent Long/
/// Short leverage (each opens its own picker, same as a real exchange
/// since the two sides can carry different risk), discrete %-of-buying-
/// power quick amounts instead of a vague continuous slider, a live
/// Order Value readout, and per-side liquidation/margin previews that
/// actually recompute as you type — then a real Long/Short action that
/// hands a [FuturesOrderSubmission] back to the page. The order-type
/// tab (Limit/Market/Stop Limit/Stop Market) is sent to the backend now
/// — only Market fills immediately; the rest are just recorded as open
/// orders (see NexbitFuturesPage._submitOrder).
class FuturesOrderFormPanel extends StatefulWidget {
  final FuturesContract contract;
  final double availableBalance;
  /// Returns whether the order actually went through — see
  /// NexbitFuturesPage._submitOrder, which is also the one place that
  /// shows the resulting success/error snackbar, only once the real
  /// backend result is known.
  final Future<bool> Function(FuturesOrderSubmission) onSubmitOrder;

  const FuturesOrderFormPanel({
    super.key,
    required this.contract,
    required this.availableBalance,
    required this.onSubmitOrder,
  });

  @override
  State<FuturesOrderFormPanel> createState() => _FuturesOrderFormPanelState();
}

class _FuturesOrderFormPanelState extends State<FuturesOrderFormPanel> {
  FuturesOrderType _type = FuturesOrderType.limit;
  late final _priceController = TextEditingController(text: formatUsdt(widget.contract.price, widget.contract.decimals));
  final _amountController = TextEditingController();
  int? _activePct;
  int _longLeverage = 10;
  int _shortLeverage = 10;
  MarginMode _marginMode = MarginMode.cross;
  OrderSide? _submittingSide;

  static const _leverageOptions = [1, 2, 3, 5, 10, 20, 25, 50, 75, 100];
  static const _pcts = [10, 25, 50, 75, 100];

  @override
  void didUpdateWidget(covariant FuturesOrderFormPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.contract.id != widget.contract.id) {
      _priceController.text = formatUsdt(widget.contract.price, widget.contract.decimals);
    }
  }

  @override
  void dispose() {
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
  double get _price =>
      _type == FuturesOrderType.market ? widget.contract.price : (double.tryParse(_priceController.text.replaceAll(',', '')) ?? widget.contract.price);
  double get _notional => _price * _amount;
  double _marginFor(int leverage) => leverage == 0 ? 0 : _notional / leverage;

  double _liqPriceFor(OrderSide side, int leverage) {
    final factor = (_marginMode == MarginMode.cross ? 0.24 : 0.4) / leverage;
    return side == OrderSide.long ? _price * (1 - factor) : _price * (1 + factor);
  }

  /// The quantity 100% of your buying power (available balance × leverage
  /// ÷ price) can afford — the same basis every exchange's %-of-balance
  /// quick-amount buttons use. Long's leverage is the reference; Amount
  /// is shared between both sides either way.
  double get _maxQtyAtFullBuyingPower => _price <= 0 ? 0 : (widget.availableBalance * _longLeverage) / _price;

  void _applyPct(int pct) {
    final qty = _maxQtyAtFullBuyingPower * pct / 100;
    setState(() {
      _amountController.text = qty.toStringAsFixed(widget.contract.decimals >= 3 ? 4 : 3);
      _activePct = pct;
    });
  }

  Future<void> _pickLeverage(bool isLong) async {
    final current = isLong ? _longLeverage : _shortLeverage;
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: NexbitColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => _LeveragePickerSheet(current: current, options: _leverageOptions),
    );
    if (result != null) {
      setState(() {
        if (isLong) {
          _longLeverage = result;
        } else {
          _shortLeverage = result;
        }
      });
    }
  }

  Future<void> _submit(OrderSide side) async {
    if (_submittingSide != null) return; // one in-flight submit at a time
    if (!isLoggedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.futuresLoginRequiredSnack),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: S.navLogin,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NexbitLoginPage()),
            ),
          ),
        ),
      );
      return;
    }
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.futuresAmountRequired), duration: const Duration(seconds: 2)),
      );
      return;
    }
    setState(() => _submittingSide = side);
    // widget.onSubmitOrder (see NexbitFuturesPage._submitOrder) is the
    // one that actually shows the success/error snackbar, only once the
    // real backend result is known — this used to also fire an
    // optimistic "success" snackbar immediately, which meant a request
    // that ended up failing still briefly showed "Order berhasil
    // dibuka" right before the real error appeared.
    final ok = await widget.onSubmitOrder(FuturesOrderSubmission(
      contract: widget.contract,
      side: side,
      orderType: _type,
      price: _price,
      size: _amount,
      leverage: side == OrderSide.long ? _longLeverage : _shortLeverage,
      marginMode: _marginMode,
    ));
    if (!mounted) return;
    setState(() {
      _submittingSide = null;
      if (ok) {
        _amountController.clear();
        _activePct = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final quote = widget.contract.quote;
    final decimals = widget.contract.decimals;
    return Container(
      color: NexbitColors.panel,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _MarginModePill(
                label: S.futuresMarginModeCross,
                active: _marginMode == MarginMode.cross,
                onTap: () => setState(() => _marginMode = MarginMode.cross),
              ),
              const SizedBox(width: 8),
              _MarginModePill(
                label: S.futuresMarginModeIsolated,
                active: _marginMode == MarginMode.isolated,
                onTap: () => setState(() => _marginMode = MarginMode.isolated),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LeveragePill(
                  label: '${S.futuresLong} ${_longLeverage}x',
                  color: NexbitColors.up,
                  onTap: () => _pickLeverage(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LeveragePill(
                  label: '${S.futuresShort} ${_shortLeverage}x',
                  color: NexbitColors.down,
                  onTap: () => _pickLeverage(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (final t in FuturesOrderType.values)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: InkWell(
                    onTap: () => setState(() => _type = t),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: _type == t ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
                      ),
                      child: Text(
                        _typeLabel(t),
                        style: NexbitText.body(
                          fontSize: 12.5,
                          weight: _type == t ? FontWeight.w600 : FontWeight.w400,
                          color: _type == t ? NexbitColors.text : NexbitColors.muted,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_type == FuturesOrderType.limit || _type == FuturesOrderType.stopLimit) ...[
            _field(S.futuresFormPrice, _priceController, quote, onChanged: () => setState(() {})),
            const SizedBox(height: 10),
          ],
          _field(
            S.futuresFormAmount,
            _amountController,
            widget.contract.id,
            onChanged: () => setState(() => _activePct = null),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final pct in _pcts) ...[
                if (pct != _pcts.first) const SizedBox(width: 6),
                Expanded(child: _PctButton(pct: pct, active: _activePct == pct, onTap: () => _applyPct(pct))),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(S.futuresOrderValue, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
              Text('${formatUsdt(_notional, 2)} $quote', style: NexbitText.mono(fontSize: 12.5, weight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _liqPreview(S.futuresLong, formatUsdt(_liqPriceFor(OrderSide.long, _longLeverage), decimals)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _liqPreview(S.futuresShort, formatUsdt(_liqPriceFor(OrderSide.short, _shortLeverage), decimals)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SideButton(
                  color: NexbitColors.up,
                  textColor: const Color(0xFF04120E),
                  label: S.futuresLongBuy(widget.contract.id),
                  sublabel: '${formatUsdt(_marginFor(_longLeverage), 2)} $quote',
                  loading: _submittingSide == OrderSide.long,
                  onTap: _submittingSide != null ? null : () => _submit(OrderSide.long),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SideButton(
                  color: NexbitColors.down,
                  textColor: Colors.white,
                  label: S.futuresShortSell(widget.contract.id),
                  sublabel: '${formatUsdt(_marginFor(_shortLeverage), 2)} $quote',
                  loading: _submittingSide == OrderSide.short,
                  onTap: _submittingSide != null ? null : () => _submit(OrderSide.short),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liqPreview(String sideLabel, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.futuresEstLiqPriceLabel, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
        const SizedBox(height: 1),
        Text('$sideLabel: $value', style: NexbitText.mono(fontSize: 11.5, weight: FontWeight.w600)),
      ],
    );
  }

  String _typeLabel(FuturesOrderType t) => switch (t) {
        FuturesOrderType.limit => S.futuresTabLimit,
        FuturesOrderType.market => S.futuresTabMarket,
        FuturesOrderType.stopLimit => S.futuresTabStopLimit,
        FuturesOrderType.stopMarket => S.futuresTabStopMarket,
      };

  Widget _field(String label, TextEditingController controller, String unit, {VoidCallback? onChanged}) {
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
                  controller: controller,
                  onChanged: (_) => onChanged?.call(),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: NexbitText.mono(fontSize: 13),
                  decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: '0.0'),
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

class _MarginModePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _MarginModePill({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? NexbitColors.surface2 : Colors.transparent,
          border: Border.all(color: active ? NexbitColors.accent : NexbitColors.line),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(label,
            style: NexbitText.body(
                fontSize: 11.5, weight: FontWeight.w600, color: active ? NexbitColors.accent : NexbitColors.muted)),
      ),
    );
  }
}

class _LeveragePill extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _LeveragePill({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: NexbitText.body(fontSize: 12, weight: FontWeight.w700, color: color)),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 15, color: color),
          ],
        ),
      ),
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

class _SideButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final String label;
  final String sublabel;
  final VoidCallback? onTap;
  final bool loading;
  const _SideButton({
    required this.color,
    required this.textColor,
    required this.label,
    required this.sublabel,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: loading
              ? SizedBox(
                  height: 33, // matches the two-line label+sublabel height below, so the button doesn't resize
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: textColor),
                    ),
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(label, style: NexbitText.body(fontSize: 13, weight: FontWeight.w700, color: textColor)),
                    const SizedBox(height: 2),
                    Text('≈ $sublabel', style: NexbitText.mono(fontSize: 10.5, color: textColor.withOpacity(0.75))),
                  ],
                ),
        ),
      ),
    );
  }
}

class _LeveragePickerSheet extends StatelessWidget {
  final int current;
  final List<int> options;
  const _LeveragePickerSheet({required this.current, required this.options});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.futuresSelectLeverage, style: NexbitText.body(fontSize: 15, weight: FontWeight.w700)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final l in options)
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).pop(l),
                    child: Container(
                      width: 64,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: l == current ? NexbitColors.accent : NexbitColors.surface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: l == current ? NexbitColors.accent : NexbitColors.line),
                      ),
                      child: Text('${l}x',
                          style: NexbitText.body(
                              fontSize: 13,
                              weight: FontWeight.w700,
                              color: l == current ? const Color(0xFF04120E) : NexbitColors.text)),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
