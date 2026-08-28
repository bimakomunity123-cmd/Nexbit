import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';

class MarketInsightItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String timeLabel;
  const MarketInsightItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.timeLabel,
  });
}

/// The "Market Insights" side card — tabs (Berita/Analisis/Riset) over a
/// short list of headline-style items, each with a small coloured icon
/// tile standing in for a thumbnail.
class MarketInsightsCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<String> tabs;
  final List<MarketInsightItem> Function(int tabIndex) itemsForTab;

  const MarketInsightsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.tabs,
    required this.itemsForTab,
  });

  @override
  State<MarketInsightsCard> createState() => _MarketInsightsCardState();
}

class _MarketInsightsCardState extends State<MarketInsightsCard> {
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
          const SizedBox(height: 12),
          for (final item in items) _InsightRow(item: item),
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

class _InsightRow extends StatelessWidget {
  final MarketInsightItem item;
  const _InsightRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: item.iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(item.icon, size: 20, color: item.iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w600, height: 1.35)),
                const SizedBox(height: 4),
                Text(item.timeLabel, style: NexbitText.body(fontSize: 11, color: NexbitColors.muted2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
