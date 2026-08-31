import 'futures_contract.dart';

enum OrderSide { long, short }

/// Cross margin shares the whole account's equity as a buffer against
/// liquidation; Isolated caps the risk (and the buffer) to just this
/// position's own margin — the same distinction every real exchange's
/// order form exposes, and it actually changes the liquidation estimate
/// here, not just the label.
enum MarginMode { cross, isolated }

/// One open futures position. PnL/liquidation math here is a simplified,
/// illustrative model (no funding-fee accrual, no shared cross-margin
/// pool across positions) — good enough for a demo, not a real risk engine.
class FuturesPosition {
  /// Backend row id (see backend/app/models.py's Position) once this
  /// position has been persisted for a logged-in user — null for the
  /// guest-mode seeded demo position, which never touches the backend.
  final String? id;
  final FuturesContract contract;
  final OrderSide side;
  final double size; // in base asset, e.g. BTC
  final double entryPrice;
  final int leverage;
  final MarginMode marginMode;

  FuturesPosition({
    this.id,
    required this.contract,
    required this.side,
    required this.size,
    required this.entryPrice,
    required this.leverage,
    this.marginMode = MarginMode.isolated,
  });

  double get notional => entryPrice * size;
  double get margin => notional / leverage;

  double pnl(double markPrice) {
    final diff = markPrice - entryPrice;
    return (side == OrderSide.long ? diff : -diff) * size;
  }

  double pnlPercent(double markPrice) => notional == 0 ? 0 : pnl(markPrice) / notional * 100;

  /// A simplified liquidation-price estimate: entry moved against the
  /// position by roughly 40% of "1/leverage" for Isolated margin (loosely
  /// modelling the maintenance-margin cushion real exchanges apply on top
  /// of the raw 1/leverage distance), or a wider ~24% for Cross — backed
  /// by the whole account, a Cross position can absorb more adverse
  /// movement before it's liquidated.
  double liqPriceFor({MarginMode? mode}) {
    final effectiveMode = mode ?? marginMode;
    final factor = (effectiveMode == MarginMode.cross ? 0.24 : 0.4) / leverage;
    return side == OrderSide.long ? entryPrice * (1 - factor) : entryPrice * (1 + factor);
  }

  double get liqPrice => liqPriceFor();
}
