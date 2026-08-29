import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/market_data/live_price_service.dart';
import '../../../../core/market_data/live_pricing.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../domain/models/trading_pair.dart';

class PairsPanel extends StatefulWidget {
  final TradingPair selected;
  final ValueChanged<TradingPair> onSelect;

  const PairsPanel({super.key, required this.selected, required this.onSelect});

  @override
  State<PairsPanel> createState() => _PairsPanelState();
}

class _PairsPanelState extends State<PairsPanel> {
  AssetCategory? _category; // null = "Semua"
  String _search = '';

  @override
  void initState() {
    super.initState();
    LivePriceService.prices.addListener(_onLiveUpdate);
  }

  @override
  void dispose() {
    LivePriceService.prices.removeListener(_onLiveUpdate);
    super.dispose();
  }

  void _onLiveUpdate() {
    if (mounted) setState(() {});
  }

  List<TradingPair> get _filtered {
    final term = _search.trim().toLowerCase();
    return liveTradingPairs().where((p) {
      final matchCat = _category == null || p.category == _category;
      final matchTerm = term.isEmpty ||
          p.id.toLowerCase().contains(term) ||
          p.name.toLowerCase().contains(term);
      return matchCat && matchTerm;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NexbitColors.panel,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: NexbitText.body(fontSize: 12.5, color: NexbitColors.text),
              decoration: InputDecoration(
                hintText: S.searchAssetHint,
                hintStyle: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted),
                filled: true,
                fillColor: NexbitColors.surface2,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: NexbitColors.line),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: NexbitColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                  borderSide: const BorderSide(color: NexbitColors.accent),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: NexbitColors.lineSoft)),
            ),
            child: Row(
              children: [
                _CategoryTab(label: S.tabAll, active: _category == null, onTap: () => setState(() => _category = null)),
                const SizedBox(width: 4),
                _CategoryTab(
                  label: S.tabCrypto,
                  active: _category == AssetCategory.crypto,
                  onTap: () => setState(() => _category = AssetCategory.crypto),
                ),
                const SizedBox(width: 4),
                _CategoryTab(
                  label: S.tabForex,
                  active: _category == AssetCategory.forex,
                  onTap: () => setState(() => _category = AssetCategory.forex),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(S.pairsColPair, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
                Text(S.pairsColPriceChange, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
              ],
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(S.noMatchingAssets,
                        style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
                  )
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (context, i) {
                      final p = _filtered[i];
                      final isActive = p.id == widget.selected.id;
                      return InkWell(
                        onTap: () => widget.onSelect(p),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isActive ? NexbitColors.accent.withOpacity(.06) : null,
                            border: isActive
                                ? const Border(left: BorderSide(color: NexbitColors.accent, width: 2))
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.label, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w500, color: NexbitColors.text)),
                                  Text(p.name, style: NexbitText.body(fontSize: 10.5, color: NexbitColors.muted2)),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(formatPrice(p.base, p.decimals), style: NexbitText.mono(fontSize: 12)),
                                  Text(p.change,
                                      style: NexbitText.mono(fontSize: 11, color: p.isUp ? NexbitColors.up : NexbitColors.down)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CategoryTab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? NexbitColors.accent.withOpacity(.08) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: NexbitText.mono(fontSize: 11, color: active ? NexbitColors.accent : NexbitColors.muted),
        ),
      ),
    );
  }
}
