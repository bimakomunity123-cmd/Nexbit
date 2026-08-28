import 'package:flutter/foundation.dart';

enum AppLocale { id, en }

/// App-wide current language. A plain [ValueNotifier] (no extra package,
/// same "keep dependencies light" spirit as the rest of this app) —
/// flipping [appLocale.value] triggers the [ValueListenableBuilder]
/// wrapping [MaterialApp] in main.dart to rebuild the whole widget tree,
/// so every screen (including already-pushed ones) picks up the change.
final ValueNotifier<AppLocale> appLocale = ValueNotifier(AppLocale.id);
