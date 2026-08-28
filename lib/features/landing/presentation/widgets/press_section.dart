import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import 'max_width_box.dart';

/// Generic placeholder wordmarks — not real outlets. Swap these for
/// actual press logos/names once Nexbit has real media coverage to show.
const _kPressPlaceholders = <String>[
  'Koin Media',
  'Finansial Pos',
  'Blok Tekno',
  'Pasar Digital',
  'Warta Kripto',
  'Bisnis Now',
  'Tren Fintech',
  'Investasi Today',
];

/// "As seen on" press bar — a muted band of wordmarks between the hero
/// and the rest of the page, matching the classic trust-bar pattern.
class PressSection extends StatelessWidget {
  final bool isMobile;
  const PressSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 22 : 56, vertical: 56),
      child: MaxWidthBox(
        child: Column(
          children: [
            Text('As seen on',
                style: NexbitText.mono(fontSize: 13, color: NexbitColors.accent, letterSpacing: 1)),
            const SizedBox(height: 28),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 40,
              runSpacing: 20,
              children: [
                for (final name in _kPressPlaceholders)
                  Text(name,
                      style: NexbitText.body(fontSize: 16, weight: FontWeight.w600, color: NexbitColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
