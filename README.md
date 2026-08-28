# Nexbit

Demo aplikasi trading aset digital berbasis Flutter — dibangun sebagai
**portfolio/prototype**, bukan exchange yang beroperasi dengan uang
sungguhan. Semua data harga, order, dan posisi adalah mock deterministik;
tidak ada backend, database, atau koneksi ke exchange nyata di baliknya.

Target utama adalah web (`flutter build web`); Android/Windows ikut
ter-generate dari `flutter create` tapi belum pernah diverifikasi jalan
di platform tersebut.

## Fitur

- **Landing page** — hero, showcase aset, dukungan pembayaran, unduhan app.
- **Trading** — chart TradingView live, order book, market trades, form
  order (Limit/Instant/Stop-Limit) untuk pasangan crypto & forex.
- **Market** — ringkasan pasar, tabel ranking, Fear & Greed index, insight.
- **Futures** — trading kontrak berjangka (Crypto/Forex/Saham), leverage,
  posisi, riwayat order, mirip pengalaman Bybit/Binance.
- **Staking** — landing, marketplace aset, alur staking, riwayat reward.
- **Blog** — artikel berita/analisis/panduan dengan kategori & pencarian.
- **Autentikasi** — login, daftar, lupa password (alur UI saja, tidak ada
  verifikasi/email sungguhan).
- **Akun** — Profil Saya, Keamanan, Preferensi (persisten via
  `shared_preferences`), Bantuan.
- **Dwibahasa penuh** — Indonesia/Inggris lewat `lib/core/i18n/`, tanpa
  paket `intl`.

## Menjalankan

```bash
flutter pub get
flutter run -d chrome        # dev, hot reload
flutter build web --release  # build produksi ke build/web/
```

Catatan chart TradingView: widget-nya dimuat lewat `WebView` dengan
`baseUrl` palsu (`https://nexbit.app`) di
`lib/features/trading/presentation/widgets/tradingview_chart.dart` —
TradingView menolak origin `null`/`file://`. Kalau nanti di-deploy ke
domain sungguhan, ganti `_baseUrl` sesuai domain tersebut.

## Struktur proyek

```
lib/
├── core/               # theme, i18n (S/appLocale), auth session, prefs
└── features/
    ├── landing/        # navbar, footer, halaman utama
    ├── auth/            # login, daftar, lupa password
    ├── trading/         # halaman trading spot
    ├── market/          # Market & Harga
    ├── futures/         # Futures trading
    ├── staking/         # Staking landing/marketplace/detail/portfolio
    ├── blog/            # Blog
    └── account/         # Profil Saya, Keamanan, Preferensi, Bantuan
```

Setiap fitur mengikuti pola `domain/models` + `presentation/{pages,widgets}`.

## Yang perlu diketahui sebelum dianggap "siap pakai"

Ini prototipe frontend murni. Sebelum jadi produk yang benar-benar
menyimpan dana/data pengguna, minimal masih perlu:

- Backend & database nyata (saat ini nol dependency `http`/database).
- Autentikasi asli (saat ini kredensial apa pun diterima).
- Feed data pasar nyata (semua harga adalah mock).
- Kepatuhan regulasi aset kripto di Indonesia (izin OJK, KYC/AML) kalau
  benar-benar akan dioperasikan sebagai exchange.

## Stack

Flutter (web-first), `google_fonts`, `webview_flutter` (+`_web`) untuk
chart TradingView, `shared_preferences` untuk preferensi lokal. Tidak
ada state-management library eksternal — state global memakai
`ValueNotifier` sederhana (`appLocale`, `isLoggedIn`, dst).
