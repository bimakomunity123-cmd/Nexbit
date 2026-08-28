import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// Live TradingView "Advanced Chart" widget rendered through a WebView.
///
/// IMPORTANT: this loads the widget via [loadHtmlString] with an explicit
/// https `baseUrl`. TradingView's embed script refuses to render under a
/// `file://` / null origin — the same issue we hit testing the HTML
/// prototype locally. Giving the WebView a real https-looking base origin
/// avoids that. In production, swap [_baseUrl] for your own domain (or just
/// host this chart.html on your backend and use `loadRequest` instead).
class TradingViewChart extends StatefulWidget {
  final String symbol;
  /// TradingView interval code: "1","5","15","60","240","D","W","M".
  final String interval;

  const TradingViewChart({super.key, required this.symbol, this.interval = '15'});

  @override
  State<TradingViewChart> createState() => _TradingViewChartState();
}

class _TradingViewChartState extends State<TradingViewChart> {
  late final WebViewController _controller;
  static const _baseUrl = 'https://nexbit.app'; // ← replace with your real domain in prod

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {
      // webview_flutter_web (used when this runs in a browser) doesn't
      // implement these two — JS is always on in its <iframe>-based
      // renderer and background color isn't controllable — so they're
      // only needed for the real Android/iOS webviews the README targets.
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(NexbitColors.bg);
    }
    _controller.loadHtmlString(_buildHtml(widget.symbol, widget.interval), baseUrl: _baseUrl);
  }

  @override
  void didUpdateWidget(covariant TradingViewChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.symbol != widget.symbol || oldWidget.interval != widget.interval) {
      // Re-inject the whole widget with the new symbol/interval — the
      // simple embed script reads its config once at load time, so a full
      // reload is the reliable way to switch pairs or timeframes.
      _controller.loadHtmlString(_buildHtml(widget.symbol, widget.interval), baseUrl: _baseUrl);
    }
  }

  String _buildHtml(String symbol, String interval) {
    return '''
<!DOCTYPE html>
<html><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<style>html,body{margin:0;padding:0;height:100%;background:#05070c;}</style>
</head>
<body>
<div class="tradingview-widget-container" style="height:100%;width:100%">
  <div class="tradingview-widget-container__widget" style="height:100%;width:100%"></div>
  <script type="text/javascript" src="https://s3.tradingview.com/external-embedding/embed-widget-advanced-chart.js" async>
  {
    "autosize": true,
    "symbol": "$symbol",
    "interval": "$interval",
    "timezone": "Asia/Jakarta",
    "theme": "dark",
    "style": "1",
    "locale": "id",
    "toolbar_bg": "#0a0f19",
    "enable_publishing": false,
    "hide_top_toolbar": false,
    "hide_legend": false,
    "save_image": false,
    "backgroundColor": "rgba(5, 7, 12, 1)",
    "gridColor": "rgba(255, 255, 255, 0.06)",
    "support_host": "https://www.tradingview.com",
    "overrides": {
      "mainSeriesProperties.candleStyle.upColor": "#2fe6c4",
      "mainSeriesProperties.candleStyle.downColor": "#ff5d7a",
      "mainSeriesProperties.candleStyle.borderUpColor": "#2fe6c4",
      "mainSeriesProperties.candleStyle.borderDownColor": "#ff5d7a",
      "mainSeriesProperties.candleStyle.wickUpColor": "#2fe6c4",
      "mainSeriesProperties.candleStyle.wickDownColor": "#ff5d7a"
    }
  }
  </script>
</div>
</body></html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: NexbitColors.bg,
      child: WebViewWidget(controller: _controller),
    );
  }
}
