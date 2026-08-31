# Nexbit

Aplikasi trading aset digital berbasis Flutter — dibangun sebagai
**portfolio/prototype**, bukan exchange berizin yang beroperasi dengan
uang sungguhan. Sudah ada backend nyata (Flask + database) di balik
autentikasi, saldo, dan order — bukan lagi UI kosong yang menerima
kredensial apa pun — tapi tetap jauh dari siap menyimpan dana pengguna
sungguhan. Lihat [Yang perlu diketahui sebelum dianggap "siap pakai"](#yang-perlu-diketahui-sebelum-dianggap-siap-pakai)
untuk batasannya secara spesifik.

Live demo: https://bimakomunity123-cmd.github.io/Nexbit/

Target utama adalah web (`flutter build web`); Android/Windows ikut
ter-generate dari `flutter create` tapi belum pernah diverifikasi jalan
di platform tersebut.

## Fitur

- **Landing page** — hero, showcase aset, dukungan pembayaran, unduhan app.
- **Autentikasi nyata** — daftar, masuk, ubah password, ubah nama
  tampilan, dan lupa/reset password beneran tersambung ke backend
  (JWT + password ter-hash) — lihat [Backend](#backend) di bawah.
- **Data pasar live** — harga & perubahan 24 jam crypto ditarik dari
  API publik CoinGecko setiap 45 detik (Landing, Market, Harga,
  Trading, Futures), dengan fallback otomatis ke data mock kalau
  fetch gagal. Forex/saham tetap data mock (CoinGecko tidak
  melacaknya).
- **Trading (Spot)** — chart TradingView live, order book, market
  trades, form order (Limit/Instant/Stop-Limit) untuk pasangan
  crypto & forex. Order Instant untuk pengguna yang sudah masuk
  benar-benar dieksekusi ke backend (saldo IDR & aset tersimpan di
  database); tamu melihat riwayat contoh yang tidak tersambung kemana pun.
- **Futures** — trading kontrak berjangka (Crypto/Forex/Saham),
  leverage, posisi, riwayat order. Saldo & posisi pengguna yang sudah
  masuk tersimpan nyata di backend; tamu melihat satu posisi contoh.
- **Market** — ringkasan pasar, tabel ranking, Fear & Greed index, insight.
- **Staking** — landing, marketplace aset, alur staking, riwayat reward
  (UI/mock — belum tersambung ke backend).
- **Blog** — artikel berita/analisis/panduan dengan kategori & pencarian.
- **Akun** — Profil Saya (ubah nama tampilan nyata), Keamanan (ubah
  password nyata), Preferensi (persisten via `shared_preferences`), Bantuan.
- **Dwibahasa penuh** — Indonesia/Inggris lewat `lib/core/i18n/`, tanpa
  paket `intl`.

## Backend

`backend/` adalah API Flask + SQLAlchemy terpisah yang menangani auth,
saldo/posisi Futures, dan dompet/order Spot — live di
`https://morphy.pythonanywhere.com`. Detail lengkap (cara jalankan
lokal, daftar endpoint, cara deploy) ada di [backend/README.md](backend/README.md).

## Menjalankan (frontend)

```bash
flutter pub get
flutter run -d chrome        # dev, hot reload — pakai backend live di atas
flutter build web --release  # build produksi ke build/web/
```

Untuk jalankan melawan backend lokal (lihat backend/README.md dulu):

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8020
```

Catatan chart TradingView: widget-nya dimuat lewat `WebView` dengan
`baseUrl` palsu (`https://nexbit.app`) di
`lib/features/trading/presentation/widgets/tradingview_chart.dart` —
TradingView menolak origin `null`/`file://`. Kalau nanti di-deploy ke
domain sungguhan, ganti `_baseUrl` sesuai domain tersebut.

## Struktur proyek

```
lib/
├── core/               # theme, i18n (S/appLocale), auth session, api client,
│                       # live market data (CoinGecko polling)
└── features/
    ├── landing/        # navbar, footer, halaman utama
    ├── auth/            # login, daftar, lupa/reset password
    ├── trading/         # halaman trading spot
    ├── market/          # Market & Harga
    ├── futures/         # Futures trading
    ├── staking/         # Staking landing/marketplace/detail/portfolio
    ├── blog/            # Blog
    └── account/         # Profil Saya, Keamanan, Preferensi, Bantuan

backend/                 # API Flask + SQLAlchemy terpisah — lihat backend/README.md
```

Setiap fitur Flutter mengikuti pola `domain/models` + `presentation/{pages,widgets}`.

## Yang perlu diketahui sebelum dianggap "siap pakai"

Ini masih prototipe, bukan exchange berizin. Sebelum jadi produk yang
benar-benar menyimpan dana/data pengguna sungguhan, minimal masih perlu:

- **Database produksi nyata** — backend masih pakai SQLite (cocok
  untuk demo skala kecil di satu proses, bukan untuk trafik/konkurensi
  sungguhan) tanpa migrasi terkelola (Alembic) — skema berubah lewat
  `create_all` saat startup, aman untuk demo tapi bukan cara yang aman
  mengubah skema tanpa kehilangan data di produksi.
- **Harga & PnL tepercaya dari server** — beberapa alur (menutup posisi
  Futures, order Instant Spot) menerima harga/PnL yang dihitung di
  klien karena backend belum punya feed data pasarnya sendiri untuk
  memverifikasi — didokumentasikan eksplisit di kode
  (`backend/app/models.py`) sebagai kompromi khusus demo, tidak layak
  untuk buku besar (ledger) trading sungguhan.
- **Layanan email sungguhan** — lupa password mengembalikan token reset
  langsung di response API (bukan dikirim email) karena tidak ada
  layanan email yang dikonfigurasi — didokumentasikan sebagai jalan
  pintas demo di kode & UI, bukan sesuatu yang boleh dilakukan produk
  sungguhan.
- **Rate limiting tingkat produksi** — sudah ada Flask-Limiter, tapi
  penyimpanannya di memori proses (cocok untuk deployment satu proses
  seperti sekarang), bukan Redis — tidak akan konsisten kalau backend
  suatu saat berjalan multi-worker.
- **Mesin pencocokan order (matching engine) sungguhan** — order
  Limit/Stop-Limit (Spot maupun Futures) tersimpan sebagai "terbuka"
  tapi tidak pernah otomatis terisi; hanya order Instant/Market yang
  benar-benar dieksekusi.
- **Kepatuhan regulasi aset kripto di Indonesia** (izin OJK, KYC/AML,
  custody dana nasabah yang diaudit) kalau benar-benar akan
  dioperasikan sebagai exchange — badge "Terverifikasi" di halaman
  Profil masih murni tampilan, bukan hasil verifikasi identitas nyata.

## Stack

**Frontend**: Flutter (web-first), `http` untuk panggilan API,
`google_fonts`, `webview_flutter` (+`_web`) untuk chart TradingView,
`shared_preferences` untuk preferensi lokal. Tidak ada state-management
library eksternal — state global memakai `ValueNotifier` sederhana
(`appLocale`, `isLoggedIn`, `authToken`, dst).

**Backend**: Flask + SQLAlchemy + SQLite, `bcrypt` untuk hash password,
`pyjwt` untuk token, `Flask-Limiter` untuk rate limiting — live di
PythonAnywhere. Detail di [backend/README.md](backend/README.md).
