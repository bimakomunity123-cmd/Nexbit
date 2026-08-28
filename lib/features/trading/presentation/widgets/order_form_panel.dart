import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

class OrderFormPanel extends StatefulWidget {
  final TradingPair pair;
  const OrderFormPanel({super.key, required this.pair});

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
              final buyForm = _SideForm(pair: widget.pair, orderType: _orderType, isBuy: true);
              final sellForm = _SideForm(pair: widget.pair, orderType: _orderType, isBuy: false);
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

class _SideForm extends StatelessWidget {
  final TradingPair pair;
  final OrderType orderType;
  final bool isBuy;

  const _SideForm({required this.pair, required this.orderType, required this.isBuy});

  @override
  Widget build(BuildContext context) {
    final accent = isBuy ? NexbitColors.up : NexbitColors.down;
    final actionLabel = isBuy ? S.buyAction(pair.id) : S.sellAction(pair.id);
    final priceStr = formatPrice(pair.base, pair.decimals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          actionLabel,
          style: NexbitText.body(fontSize: 14, weight: FontWeight.w700, color: accent),
        ),
        const SizedBox(height: 12),
        ..._fieldsForOrderType(priceStr),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: isBuy ? const Color(0xFF04120E) : const Color(0xFF1A0208),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
              textStyle: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700),
            ),
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }

  List<Widget> _fieldsForOrderType(String priceStr) {
    switch (orderType) {
      case OrderType.limit:
        return [
          _InputField(label: S.formPrice, unit: pair.quote, initialValue: priceStr),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: pair.id, hint: '0.0'),
          const SizedBox(height: 8),
          _AmountSlider(isBuy: isBuy),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotal, quote: pair.quote),
          const SizedBox(height: 14),
        ];
      case OrderType.instant:
        return [
          _MarketNote(priceStr: priceStr, quote: pair.quote),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: pair.id, hint: '0.0'),
          const SizedBox(height: 8),
          _AmountSlider(isBuy: isBuy),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotalEstimated, quote: pair.quote),
          const SizedBox(height: 14),
        ];
      case OrderType.stopLimit:
        return [
          _InputField(label: S.formStopPrice, unit: pair.quote, initialValue: priceStr),
          const SizedBox(height: 10),
          _InputField(label: S.formLimitPrice, unit: pair.quote, initialValue: priceStr),
          const SizedBox(height: 10),
          _InputField(label: S.formAmount, unit: pair.id, hint: '0.0'),
          const SizedBox(height: 8),
          _AmountSlider(isBuy: isBuy),
          const SizedBox(height: 6),
          _TotalRow(label: S.formTotal, quote: pair.quote),
          const SizedBox(height: 14),
        ];
    }
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String unit;
  final String? initialValue;
  final String? hint;

  const _InputField({required this.label, required this.unit, this.initialValue, this.hint});

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
                  controller: initialValue != null ? TextEditingController(text: initialValue) : null,
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

class _AmountSlider extends StatefulWidget {
  final bool isBuy;
  const _AmountSlider({required this.isBuy});

  @override
  State<_AmountSlider> createState() => _AmountSliderState();
}

class _AmountSliderState extends State<_AmountSlider> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.isBuy ? NexbitColors.up : NexbitColors.down;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: color,
        inactiveTrackColor: NexbitColors.line,
        thumbColor: color,
        overlayColor: color.withOpacity(.15),
        trackHeight: 3,
      ),
      child: Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String quote;
  const _TotalRow({required this.label, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted)),
        Text('0 $quote', style: NexbitText.mono(fontSize: 12, color: NexbitColors.muted)),
      ],
    );
  }
}
