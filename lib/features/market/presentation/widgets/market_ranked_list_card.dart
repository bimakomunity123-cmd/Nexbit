import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// One row in a [MarketRankedListCard] — a rank number, a leading label
/// (symbol/pair), an optional secondary label (full name), and a trailing
/// value with its own colour (used for both % change and volume figures).
class MarketRankedItem {
  final String primary;
  final String? secondary;
  final String trailing;
  final Color trailingColor;
  const MarketRankedItem({
    required this.primary,
    this.secondary,
    required this.trailing,
    required this.trailingColor,
  });
}

/// A titled card with two tabs (e.g. Gainers/Losers, Crypto/Fiat) and a
/// numbered list underneath — shared shape for the Market page's
/// "Trending" and "Top Volume" side-panel cards so they don't duplicate
/// the same layout twice.
class MarketRankedListCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> tabs;
  final List<MarketRankedItem> Function(int tabIndex) itemsForTab;

  const MarketRankedListCard({
    super.key,
    required this.title,
    required this.icon,
    required this.tabs,
    required this.itemsForTab,
  });

  @override
  State<MarketRankedListCard> createState() => _MarketRankedListCardState();
}

class _MarketRankedListCardState extends State<MarketRankedListCard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final items = widget.itemsForTab(_tab);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NexbitColors.panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: NexbitColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(widget.icon, size: 16, color: NexbitColors.accent),
              const SizedBox(width: 8),
              Text(widget.title, style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < widget.tabs.length; i++) ...[
                if (i > 0) const SizedBox(width: 16),
                _Tab(label: widget.tabs[i], active: _tab == i, onTap: () => setState(() => _tab = i)),
              ],
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++) _RankedRow(rank: i + 1, item: items[i]),
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
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          border: active ? const Border(bottom: BorderSide(color: NexbitColors.accent, width: 2)) : null,
        ),
        child: Text(
          label,
          style: NexbitText.body(
            fontSize: 12,
            weight: active ? FontWeight.w600 : FontWeight.w400,
            color: active ? NexbitColors.text : NexbitColors.muted,
          ),
        ),
      ),
    );
  }
}

class _RankedRow extends StatelessWidget {
  final int rank;
  final MarketRankedItem item;
  const _RankedRow({required this.rank, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 18,
            child: Text('$rank', style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
          ),
          const SizedBox(width: 4),
          Text(item.primary, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700)),
          if (item.secondary != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(item.secondary!,
                  overflow: TextOverflow.ellipsis, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted2)),
            ),
          ] else
            const Spacer(),
          Text(item.trailing,
              style: NexbitText.mono(fontSize: 12, weight: FontWeight.w600, color: item.trailingColor)),
        ],
      ),
    );
  }
}
