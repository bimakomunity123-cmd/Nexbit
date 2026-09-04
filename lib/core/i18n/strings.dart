import 'app_locale.dart';

/// All translatable UI copy in one place. `S.xxx` reads [appLocale]'s
/// current value live, so no rebuild wiring is needed beyond what
/// main.dart already does at the app root.
///
/// Proper nouns (Nexbit, Bitcoin, asset tickers…), formatted numbers, and
/// mock/dummy data values are intentionally left untranslated.
class S {
  S._();

  static bool get _isEn => appLocale.value == AppLocale.en;
  static String _t(String id, String en) => _isEn ? en : id;

  // ---------------------------------------------------------------------
  // Navbar (shared across landing / Harga / login-adjacent pages)
  // ---------------------------------------------------------------------
  static String get navHarga => _t('Harga', 'Price');
  static String get navMarket => _t('Market', 'Market');
  static String get navStaking => _t('Staking', 'Staking');
  static String get navFutures => _t('Futures', 'Futures');
  static String get navSahamAS => _t('Saham AS', 'US Stocks');
  static String get navBlog => _t('Blog', 'Blog');
  static String get navLogin => _t('Masuk', 'Login');
  static String get navRegister => _t('Daftar', 'Sign Up');
  static String get navLogout => _t('Keluar', 'Log Out');
  static String get navLogoutSuccessSnack => _t('Berhasil keluar', 'Logged out successfully');
  static String get navMyProfile => _t('Profil Saya', 'My Profile');
  static String get navSecurity => _t('Keamanan', 'Security');
  static String get navVerification => _t('Verifikasi', 'Verification');
  static String get navPreferences => _t('Preferensi', 'Preferences');
  static String get navHelp => _t('Bantuan', 'Help');
  static String get navComingSoonSnack => _t('Fitur ini segera hadir', 'This feature is coming soon');
  static String get navLangIndonesian => _t('Bahasa Indonesia', 'Bahasa Indonesia');
  static String get navLangEnglish => _t('English', 'English');

  // ---------------------------------------------------------------------
  // Hero (landing page)
  // ---------------------------------------------------------------------
  static String get heroTitleLine1 => _t('Trading aset digital,', 'Trade digital assets,');
  static String get heroTitleLine2 => _t('secepat kamu berpikir.', 'as fast as you think.');
  static String get heroSubtitle => _t(
        'Pantau harga real-time, eksekusi order dalam hitungan milidetik, '
        'dan kelola portofolio kripto kamu dari satu dashboard yang dibuat '
        'untuk trader Indonesia. Mulai dari Rp 25.000.',
        'Track real-time prices, execute orders in milliseconds, and manage '
        'your crypto portfolio from one dashboard built for Indonesian '
        'traders. Start from just Rp 25,000.',
      );
  static String get heroCtaPrimary => _t('Mulai Trading →', 'Start Trading →');
  static String get heroCtaSecondary => _t('Lihat Live Market', 'View Live Market');
  static String get heroStatUsersLabel => _t('Pengguna aktif', 'Active users');
  static String get heroStatAssetsLabel => _t('Aset terdaftar', 'Listed assets');
  static String get heroStatUptimeLabel => _t('Uptime sistem', 'System uptime');

  // ---------------------------------------------------------------------
  // Price ticker card (hero)
  // ---------------------------------------------------------------------
  static String get tickerPeriod => _t('24 jam', '24h');
  static String get tickerViewAll => _t('Lihat semua aset →', 'View all assets →');

  // ---------------------------------------------------------------------
  // Asset showcase section
  // ---------------------------------------------------------------------
  static String get assetShowcaseHeading =>
      _t('700+ Aset Kripto Tersedia\ndengan Spread Rendah', '700+ Crypto Assets Available\nwith Low Spreads');
  static String get assetShowcaseSubheading => _t(
        'Spread jual-beli di Nexbit termasuk salah satu yang terendah di pasar '
        'aset kripto Indonesia — sistem kami memantau pasar dan menyesuaikan '
        'harga secara real-time.',
        'Nexbit\'s buy-sell spread is among the lowest in the Indonesian crypto '
        'market — our system monitors the market and adjusts prices in '
        'real time.',
      );
  static String get assetShowcaseFeature1Title => _t('100% Diasuransikan', '100% Insured');
  static String get assetShowcaseFeature1Desc => _t(
        'Seluruh aset digital di Nexbit diasuransikan lewat kustodian pihak ketiga tepercaya.',
        'All digital assets on Nexbit are insured through a trusted third-party custodian.',
      );
  static String get assetShowcaseFeature2Title => _t('Terdaftar dan Berizin', 'Registered and Licensed');
  static String get assetShowcaseFeature2Desc => _t(
        'Nexbit dirancang mengikuti standar kepatuhan platform aset digital di Indonesia.',
        'Nexbit is designed to follow digital asset platform compliance standards in Indonesia.',
      );
  static String get assetShowcaseCta => _t('Lihat Semua Aset', 'View All Assets');
  static String get assetShowcaseMore => _t('+50 Lainnya', '+50 More');

  // ---------------------------------------------------------------------
  // Payment support section
  // ---------------------------------------------------------------------
  static String get paymentHeading =>
      _t('Support 60+ Bank & E-Wallet\nse-Indonesia', 'Supports 60+ Banks & E-Wallets\nAcross Indonesia');
  static String get paymentSubheading => _t('24/7 Real-time Deposit & Withdrawal', '24/7 Real-time Deposit & Withdrawal');
  static String get paymentParagraph => _t(
        'Seluruh deposit dan penarikan rupiah di Nexbit diproses secara instan '
        'dalam hitungan menit ke berbagai bank dan e-wallet.\n\n'
        'Butuh dana tengah malam? Selesai — tidak perlu menunggu sampai esok hari.\n\n'
        'Berbeda dengan pasar saham dan reksa dana, aset digital tidak mengenal '
        'hari libur — seluruh transaksi diproses 24 jam termasuk akhir pekan.',
        'Every rupiah deposit and withdrawal on Nexbit is processed instantly, '
        'within minutes, to a wide range of banks and e-wallets.\n\n'
        'Need funds at midnight? Done — no need to wait until the next day.\n\n'
        'Unlike stocks and mutual funds, digital assets don\'t observe holidays — '
        'every transaction is processed 24 hours a day, including weekends.',
      );
  static String get paymentChipEwallet => _t('E-Wallet', 'E-Wallet');
  static String get paymentChipQris => _t('QRIS', 'QRIS');
  static String get paymentChipBankTransfer => _t('Transfer Bank', 'Bank Transfer');

  // ---------------------------------------------------------------------
  // Trust section
  // ---------------------------------------------------------------------
  static String get trustHeading => _t(
        'Gunakan platform dengan standar keamanan\nyang jelas untuk ketenangan kamu.',
        'Use a platform with clear security\nstandards for your peace of mind.',
      );
  static String get trustSubtext => _t(
        'Nexbit dirancang mengikuti standar keamanan, asuransi, dan kepatuhan industri.',
        'Nexbit is designed to follow industry security, insurance, and compliance standards.',
      );
  static String get trustCta => _t('Mulai Sekarang', 'Get Started');
  static String get trustCertifiedSecured => _t('Certified. Secured.', 'Certified. Secured.');
  static String get trustBadgeEncryption => _t('Enkripsi End-to-End', 'End-to-End Encryption');
  static String get trustBadgeAudit => _t('Audit Keamanan Berkala', 'Regular Security Audits');
  static String get trustBadgeInsured => _t('Dana Diasuransikan', 'Funds Insured');
  static String get trustBadgeCompliance => _t('Kepatuhan Industri', 'Industry Compliance');

  // ---------------------------------------------------------------------
  // App download section
  // ---------------------------------------------------------------------
  static String get appDownloadHeading => _t(
        'Beli dan Jual Aset Digital di Mana Pun dan Kapan Pun dengan Aplikasi Nexbit.',
        'Buy and Sell Digital Assets Anytime, Anywhere with the Nexbit App.',
      );
  static String get appDownloadSubheading => _t('Transaksi Cepat dan Tepat', 'Fast and Accurate Transactions');
  static String get appDownloadParagraph => _t(
        'Dengan aplikasi Nexbit kamu bisa melakukan seluruh transaksi beli, jual, '
        'dan staking aset kripto di Indonesia dalam satu genggaman. Pantau dan '
        'kelola portofolio aset digitalmu kapan saja.',
        'With the Nexbit app you can buy, sell, and stake crypto assets in '
        'Indonesia all from the palm of your hand. Track and manage your '
        'digital asset portfolio anytime.',
      );
  static String get appDownloadNow => _t('Download dan dapatkan sekarang', 'Download and get it now');
  static String get appDownloadGetItOn => _t('GET IT ON', 'GET IT ON');
  static String get appDownloadOnThe => _t('Download on the', 'Download on the');
  static String get appDownloadGoodMorning => _t('Selamat Pagi,', 'Good Morning,');
  static String get appDownloadBalance => _t('Saldo', 'Balance');
  static String get appDownloadRupiah => _t('Rupiah Indonesia', 'Indonesian Rupiah');
  static String get appDownloadHighlights => _t('Sorotan', 'Highlights');
  static String get appDownloadTopGainer24h => _t('Top Gainer (24j)', 'Top Gainer (24h)');
  static String get appDownloadHighest => _t('Tertinggi', 'Highest');

  // ---------------------------------------------------------------------
  // Footer
  // ---------------------------------------------------------------------
  static String get footerMarketPrice => _t('Harga Pasar', 'Market Price');
  static String get footerLiveRate => _t('Live Rate', 'Live Rate');
  static String get footerNexbitFeatures => _t('Fitur Nexbit', 'Nexbit Features');
  static String get footerAffiliate => _t('Affiliate', 'Affiliate');
  static String get footerGiftCard => _t('Gift Card', 'Gift Card');
  static String get footerProduct => _t('Produk', 'Product');
  static String get footerMobileCredit => _t('Pulsa', 'Mobile Credit');
  static String get footerElectricityToken => _t('Token Listrik', 'Electricity Token');
  static String get footerPayBills => _t('Bayar Tagihan', 'Pay Bills');
  static String get footerCompany => _t('Perusahaan', 'Company');
  static String get footerContactUs => _t('Hubungi Kami', 'Contact Us');
  static String get footerAboutUs => _t('Tentang Kami', 'About Us');
  static String get footerOtherAssets => _t('Kripto & Aset Digital Lain', 'Crypto & Other Digital Assets');
  static String get footerCopyright =>
      _t('© 2022 - 2026 Nexbit — Jual Beli Aset Digital Indonesia', '© 2022 - 2026 Nexbit — Buy & Sell Digital Assets Indonesia');

  // ---------------------------------------------------------------------
  // Shared asset-category tabs (Harga page + trading pairs panel)
  // ---------------------------------------------------------------------
  static String get tabAll => _t('Semua', 'All');
  static String get tabCrypto => _t('Crypto', 'Crypto');
  static String get tabForex => _t('Forex', 'Forex');
  static String get searchAssetHint => _t('Cari aset...', 'Search assets...');
  static String get noMatchingAssets => _t('Tidak ada aset yang cocok.', 'No matching assets.');

  // ---------------------------------------------------------------------
  // Harga (market price) page
  // ---------------------------------------------------------------------
  static String get priceHeading => _t('Harga Crypto Hari Ini (Cryptocurrency Market)', 'Today\'s Crypto Prices (Cryptocurrency Market)');
  static String get priceSubheading => _t(
        'Lihat pergerakan harga aset favoritmu dengan data real-time. Pantau '
        'perubahan harga dan temukan peluang trading kapan saja.',
        'Track your favorite assets\' price movements with real-time data. '
        'Monitor price changes and spot trading opportunities anytime.',
      );
  static String get priceTopGainer => _t('TOP GAINER (24H)', 'TOP GAINER (24H)');
  static String get priceHighestVolume => _t('HIGHEST VOLUME (24H)', 'HIGHEST VOLUME (24H)');
  static String get priceMostPopular => _t('MOST POPULAR (24H)', 'MOST POPULAR (24H)');
  static String get priceSearchAssetHint => _t('Cari nama aset...', 'Search asset name...');
  static String get priceColAsset => _t('Aset', 'Asset');
  static String get priceColBuy => _t('Beli (IDR)', 'Buy (IDR)');
  static String get priceColSell => _t('Jual (IDR)', 'Sell (IDR)');
  static String get priceColChange => _t('Perubahan', 'Change');
  static String get priceColTrend => _t('Trend', 'Trend');
  static String get priceColAction => _t('Aksi', 'Action');
  static String get priceTradeButton => _t('Trade', 'Trade');
  static String get priceNextButton => _t('Next', 'Next');
  static String get priceWhatIsCryptoHeading => _t('Apa itu Crypto?', 'What is Crypto?');
  static String get priceWhatIsCryptoParagraph => _t(
        'Kripto adalah aset digital yang keamanannya dijaga lewat kriptografi dan '
        'tercatat di jaringan terdesentralisasi (blockchain), sehingga setiap '
        'transaksi tercatat transparan tanpa bergantung pada satu otoritas pusat. '
        'Di Nexbit kamu bisa memantau harga real-time di halaman ini, lalu langsung '
        'mulai trading dengan menekan tombol Trade pada aset yang kamu mau.',
        'Crypto is a digital asset secured through cryptography and recorded on a '
        'decentralized network (blockchain), so every transaction is transparent '
        'and doesn\'t rely on a single central authority. On Nexbit you can track '
        'real-time prices on this page, then start trading right away by tapping '
        'the Trade button on the asset you want.',
      );

  // ---------------------------------------------------------------------
  // Market page — exploration dashboard (cap, volume, ranking)
  // ---------------------------------------------------------------------
  static String get marketHeadingAccent => _t('Market', 'Market');
  static String get marketHeadingRest => _t(' Overview', ' Overview');
  static String get marketSubheading => _t(
        'Pantau pergerakan harga aset kripto favorit secara real-time. '
        'Analisis pasar, temukan peluang, ambil keputusan lebih cerdas.',
        'Track your favorite crypto assets\' price movements in real time. '
        'Analyze the market, spot opportunities, make sharper decisions.',
      );
  static String get marketStatTotalCap => _t('Total Market Cap', 'Total Market Cap');
  static String get marketStatVolume24h => _t('24h Volume', '24h Volume');
  static String get marketStatBtcDominance => _t('BTC Dominance', 'BTC Dominance');
  static String get marketTabAll => _t('Semua', 'All');
  static String get marketTabCrypto => _t('Kripto', 'Crypto');
  static String get marketTabDefi => _t('DeFi', 'DeFi');
  static String get marketTabNft => _t('NFT', 'NFT');
  static String get marketTabGamefi => _t('GameFi', 'GameFi');
  static String get marketTabMore => _t('Lainnya', 'More');
  static String get marketColAsset => _t('Aset', 'Asset');
  static String get marketColPrice => _t('Harga', 'Price');
  static String get marketColChange24h => _t('24h Change', '24h Change');
  static String get marketColMarketCap => _t('Market Cap', 'Market Cap');
  static String get marketColVolume24h => _t('Volume (24h)', 'Volume (24h)');
  static String get marketColChart7d => _t('Grafik (7H)', 'Chart (7D)');
  static String get marketColAction => _t('', '');
  static String get marketSearchHint => _t('Cari aset kripto...', 'Search crypto assets...');
  static String get marketChartHeading => _t('Market Chart', 'Market Chart');
  static String get marketTrendingHeading => _t('Trending', 'Trending');
  static String get marketTabGainers => _t('Gainers', 'Gainers');
  static String get marketTabLosers => _t('Losers', 'Losers');
  static String get marketTopVolumeHeading => _t('Top Volume', 'Top Volume');
  static String get marketTabVolCrypto => _t('Crypto', 'Crypto');
  static String get marketTabVolFiat => _t('Fiat', 'Fiat');
  static String get marketInsightsHeading => _t('Market Insights', 'Market Insights');
  static String get marketTabNews => _t('Berita', 'News');
  static String get marketTabAnalysis => _t('Analisis', 'Analysis');
  static String get marketTabResearch => _t('Riset', 'Research');
  static String marketHoursAgo(int h) => _t('$h jam yang lalu', '$h hours ago');
  static String get marketNews1 =>
      _t('Bitcoin Tembus Rp1,7 Miliar, Pasar Kripto Kembali Menguat', 'Bitcoin Breaks New High as Crypto Market Rallies');
  static String get marketNews2 => _t(
      'Ethereum Siap Upgrade Jaringan, Apa Dampaknya?', 'Ethereum Prepares Network Upgrade, What Are the Effects?');
  static String get marketNews3 =>
      _t('Tren Kripto 2026: Peluang dan Tantangan yang Perlu Diperhatikan', '2026 Crypto Trends: Opportunities and Risks to Watch');
  static String get marketAnalysis1 =>
      _t('Analisis Teknikal: BTC Uji Level Resistance Kunci', 'Technical Analysis: BTC Tests Key Resistance Level');
  static String get marketAnalysis2 =>
      _t('Musim Altcoin Sudah Dekat? Ini Indikatornya', 'Is Altcoin Season Near? Here Are the Signals');
  static String get marketAnalysis3 =>
      _t('Dominasi BTC Melandai, Modal Mulai Rotasi ke Altcoin', 'BTC Dominance Cools as Capital Rotates to Altcoins');
  static String get marketResearch1 =>
      _t('Laporan Riset: Adopsi Stablecoin di Asia Tenggara', 'Research Report: Stablecoin Adoption in Southeast Asia');
  static String get marketResearch2 =>
      _t('Studi On-Chain: Aktivitas Whale BTC Meningkat', 'On-Chain Study: BTC Whale Activity on the Rise');
  static String get marketResearch3 =>
      _t('Outlook Pasar Kripto Kuartal Ini', 'This Quarter\'s Crypto Market Outlook');
  static String get marketFearGreedHeading => _t('Indeks Fear & Greed', 'Fear & Greed Index');
  static String get marketFearGreedExtremeFear => _t('Ketakutan Ekstrem', 'Extreme Fear');
  static String get marketFearGreedFear => _t('Takut', 'Fear');
  static String get marketFearGreedNeutral => _t('Netral', 'Neutral');
  static String get marketFearGreedGreed => _t('Serakah', 'Greed');
  static String get marketFearGreedExtremeGreed => _t('Sangat Serakah', 'Extreme Greed');
  static String get marketFearGreedYesterday => _t('Kemarin', 'Yesterday');
  static String get marketFearGreedLastWeek => _t('Minggu Lalu', 'Last Week');

  // ---------------------------------------------------------------------
  // Trading page — topbar
  // ---------------------------------------------------------------------
  static String get tradingChange24h => _t('24H PERUBAHAN', '24H CHANGE');
  static String get tradingHigh24h => _t('24H TINGGI', '24H HIGH');
  static String get tradingLow24h => _t('24H RENDAH', '24H LOW');
  static String get tradingVolume => _t('VOLUME', 'VOLUME');

  // ---------------------------------------------------------------------
  // Trading page — pairs panel
  // ---------------------------------------------------------------------
  static String get pairsColPair => _t('Pair', 'Pair');
  static String get pairsColPriceChange => _t('Harga / Perubahan', 'Price / Change');

  // ---------------------------------------------------------------------
  // Trading page — order book
  // ---------------------------------------------------------------------
  static String get orderBookTitle => _t('Order Book', 'Order Book');
  static String orderBookPriceCol(String quote) => _t('Harga ($quote)', 'Price ($quote)');
  static String orderBookAmountCol(String id) => _t('Jumlah ($id)', 'Amount ($id)');

  // ---------------------------------------------------------------------
  // Trading page — market trades
  // ---------------------------------------------------------------------
  static String get marketTradesTab => _t('Market Trades', 'Market Trades');
  static String get myTradesTab => _t('Perdaganganku', 'My Trades');
  static String get timeCol => _t('Waktu', 'Time');
  static String get noTradesYet => _t('Belum ada transaksi', 'No trades yet');

  // ---------------------------------------------------------------------
  // Trading page — order form
  // ---------------------------------------------------------------------
  static String get formPrice => _t('Harga', 'Price');
  static String get formAmount => _t('Jumlah', 'Amount');
  static String get formTotal => _t('Total', 'Total');
  static String get formTotalEstimated => _t('Total (estimasi)', 'Total (estimated)');
  static String get formStopPrice => _t('Harga Stop', 'Stop Price');
  static String get formLimitPrice => _t('Harga Limit', 'Limit Price');
  static String get formCurrentMarketPrice => _t('Harga Pasar Saat Ini', 'Current Market Price');
  static String buyAction(String id) => _t('Beli $id', 'Buy $id');
  static String sellAction(String id) => _t('Jual $id', 'Sell $id');
  static String get tradingLoginRequiredSnack =>
      _t('Masuk dulu untuk mulai trading', 'Log in first to start trading');
  static String get tradingAmountRequired => _t('Jumlah wajib diisi', 'Amount is required');
  static String get tradingOrderFilledSnack => _t('Order berhasil dieksekusi', 'Order executed successfully');
  static String get tradingOrderPlacedSnack => _t('Order berhasil dipasang', 'Order placed successfully');

  // ---------------------------------------------------------------------
  // Trading page — spot wallet card
  // ---------------------------------------------------------------------
  static String get spotWalletHeading => _t('Dompet Spot', 'Spot Wallet');
  static String get spotWalletBalance => _t('Saldo IDR', 'IDR Balance');
  static String get spotWalletHoldingsHeading => _t('Aset Dimiliki', 'Holdings');
  static String get spotWalletNoHoldings => _t('Belum ada aset', 'No holdings yet');
  static String get spotWalletEstValue => _t('Est. nilai', 'Est. value');
  static String get spotWalletPortfolioValue => _t('Total Nilai Portofolio', 'Total Portfolio Value');

  // ---------------------------------------------------------------------
  // Trading page — open orders / order history panel
  // ---------------------------------------------------------------------
  static String get openOrdersTab => _t('Order Terbuka', 'Open Orders');
  static String get orderHistoryTab => _t('Riwayat Order', 'Order History');
  static String get noOpenOrders => _t('Tidak ada order terbuka', 'No open orders');
  static String get noOrderHistory => _t('Belum ada riwayat order', 'No order history yet');
  static String get ordersColPair => _t('Pair', 'Pair');
  static String get ordersColType => _t('Tipe', 'Type');
  static String get ordersColPrice => _t('Harga', 'Price');
  static String get ordersColAmount => _t('Jumlah', 'Amount');
  static String get ordersColTotal => _t('Total', 'Total');
  static String get ordersColStatus => _t('Status', 'Status');
  static String get ordersColTime => _t('Waktu', 'Time');
  static String get ordersColAction => _t('Aksi', 'Action');
  static String get orderCancelAction => _t('Batalkan', 'Cancel');
  static String get orderStatusFilled => _t('Terisi', 'Filled');
  static String get orderStatusCancelled => _t('Dibatalkan', 'Cancelled');
  static String get orderStatusOpen => _t('Terbuka', 'Open');
  static String get orderCancelledSnack => _t('Order dibatalkan', 'Order cancelled');

  // ---------------------------------------------------------------------
  // Login page
  // ---------------------------------------------------------------------
  static String get loginHello => _t('Halo!', 'Hello!');
  static String get loginSubtitle => _t('Masuk ke akun Anda', 'Sign in to your account');
  static String get loginEmail => _t('Email', 'Email');
  static String get loginPassword => _t('Kata Sandi', 'Password');
  static String get loginRememberMe => _t('Ingat saya di perangkat ini', 'Remember me on this device');
  static String get loginSubmit => _t('Masuk', 'Login');
  static String get loginForgotPassword => _t('Lupa kata sandi?', 'Forgot password?');
  static String get loginNewUser => _t('Pengguna baru? ', 'New user? ');
  static String get loginRegister => _t('Daftar', 'Sign Up');
  static String get loginRequiredFields => _t('Email dan kata sandi wajib diisi', 'Email and password are required');

  // ---------------------------------------------------------------------
  // Login — 2FA step (shown when the account has 2FA enabled; see
  // Keamanan's toggle and backend/app/routers/auth.py's login())
  // ---------------------------------------------------------------------
  static String get loginTwoFactorHeading => _t('Verifikasi Diperlukan', 'Verification Required');
  static String get loginTwoFactorSubtitle =>
      _t('Masukkan kode 6 digit untuk melanjutkan masuk.', 'Enter the 6-digit code to continue logging in.');
  static String get loginTwoFactorCodeLabel => _t('Kode Verifikasi', 'Verification Code');
  static String get loginTwoFactorCodeRequired => _t('Kode verifikasi wajib diisi', 'Verification code is required');
  static String get loginTwoFactorSubmit => _t('Verifikasi', 'Verify');
  static String get loginTwoFactorBack => _t('Kembali ke halaman masuk', 'Back to login');
  static String get loginTwoFactorDemoNoticeBody => _t(
        'Aplikasi ini belum punya layanan SMS/authenticator app sungguhan, jadi kode verifikasi ditampilkan langsung di sini alih-alih dikirim ke perangkat kamu.',
        "This app doesn't have a real SMS/authenticator app service yet, so the verification code is shown here directly instead of being sent to your device.",
      );
  static String get loginWelcomeBack => _t('Selamat Datang Kembali di Nexbit', 'Welcome Back to Nexbit');
  static String get loginWelcomeBackSubtitle => _t(
        'Trader Nexbit, mari kelola portofolio aset digitalmu dari mana saja, kapan saja.',
        'Nexbit trader, manage your digital asset portfolio from anywhere, anytime.',
      );

  // ---------------------------------------------------------------------
  // Forgot password page
  // ---------------------------------------------------------------------
  static String get forgotPasswordHeading => _t('Reset Kata Sandi', 'Reset Password');
  static String get forgotPasswordSubtitle => _t(
        'Masukkan email akunmu, kami akan kirimkan link untuk mengatur ulang kata sandi.',
        "Enter your account's email and we'll send you a link to reset your password.",
      );
  static String get forgotPasswordSubmit => _t('Kirim Link Reset', 'Send Reset Link');
  static String get forgotPasswordEmailRequired => _t('Email wajib diisi', 'Email is required');
  static String get forgotPasswordEmailInvalid => _t('Format email tidak valid', 'Enter a valid email address');
  static String get forgotPasswordBackToLogin => _t('Kembali ke Masuk', 'Back to Login');
  static String get forgotPasswordCheckEmailHeading => _t('Cek Email Kamu', 'Check Your Email');
  static String forgotPasswordCheckEmailBody(String email) => _t(
        'Kami sudah mengirim link reset kata sandi ke $email. Buka email tersebut dan ikuti instruksinya.',
        "We've sent a password reset link to $email. Open it and follow the instructions.",
      );
  static String get forgotPasswordResend => _t('Belum menerima email? Kirim ulang', "Didn't get the email? Resend");
  static String get forgotPasswordResentSnack => _t('Link reset dikirim ulang', 'Reset link resent');
  static String get forgotPasswordDemoNoticeHeading => _t('Mode Demo', 'Demo Mode');
  static String get forgotPasswordDemoNoticeBody => _t(
        'Aplikasi ini belum punya layanan email sungguhan, jadi kode reset ditampilkan langsung di sini alih-alih dikirim ke email kamu.',
        "This app doesn't have a real email service yet, so the reset code is shown here directly instead of being emailed to you.",
      );
  static String get forgotPasswordContinueReset => _t('Lanjutkan Reset Password', 'Continue to Reset Password');
  static String get forgotPasswordManualCodeLink =>
      _t('Sudah punya kode reset? Masukkan manual', 'Already have a reset code? Enter it manually');

  // ---------------------------------------------------------------------
  // Reset password (continuation of the forgot-password flow above)
  // ---------------------------------------------------------------------
  static String get resetPasswordHeading => _t('Buat Password Baru', 'Create New Password');
  static String get resetPasswordSubtitle => _t(
        'Masukkan kode reset dan password baru untuk akunmu.',
        'Enter your reset code and a new password for your account.',
      );
  static String get resetPasswordTokenLabel => _t('Kode Reset', 'Reset Code');
  static String get resetPasswordPrefilledNotice =>
      _t('Kode reset otomatis diisi (mode demo)', 'Reset code auto-filled (demo mode)');
  static String get resetPasswordNewPassword => _t('Password Baru', 'New Password');
  static String get resetPasswordConfirmPassword => _t('Konfirmasi Password Baru', 'Confirm New Password');
  static String get resetPasswordSubmit => _t('Reset Password', 'Reset Password');
  static String get resetPasswordFieldsRequired => _t('Semua kolom wajib diisi', 'All fields are required');
  static String get resetPasswordTooShort =>
      _t('Password baru minimal 8 karakter', 'New password must be at least 8 characters');
  static String get resetPasswordMismatch => _t('Konfirmasi password tidak cocok', "Passwords don't match");
  static String get resetPasswordSuccessHeading => _t('Password Berhasil Direset', 'Password Reset Successful');
  static String get resetPasswordSuccessBody => _t(
        'Password akunmu sudah diperbarui. Silakan masuk dengan password barumu.',
        'Your account password has been updated. Please log in with your new password.',
      );

  // ---------------------------------------------------------------------
  // Register page
  // ---------------------------------------------------------------------
  static String get registerHeading => _t('Buat Akun', 'Create Account');
  static String get registerSubtitle => _t(
        'Mulai trading aset digital bersama Nexbit hari ini.',
        'Start trading digital assets with Nexbit today.',
      );
  static String get registerFullName => _t('Nama Lengkap', 'Full Name');
  static String get registerConfirmPassword => _t('Konfirmasi Kata Sandi', 'Confirm Password');
  static String get registerAgreeTerms => _t(
        'Saya menyetujui Syarat & Ketentuan serta Kebijakan Privasi Nexbit',
        "I agree to Nexbit's Terms of Service and Privacy Policy",
      );
  static String get registerSubmit => _t('Daftar Sekarang', 'Create Account');
  static String get registerHaveAccount => _t('Sudah punya akun? ', 'Already have an account? ');
  static String get registerLoginLink => _t('Masuk', 'Login');
  static String get registerRequiredFields => _t('Semua kolom wajib diisi', 'All fields are required');
  static String get registerEmailInvalid => _t('Format email tidak valid', 'Enter a valid email address');
  static String get registerPasswordTooShort =>
      _t('Kata sandi minimal 8 karakter', 'Password must be at least 8 characters');
  static String get registerPasswordMismatch => _t('Konfirmasi kata sandi tidak cocok', 'Passwords do not match');
  static String get registerMustAgreeTerms =>
      _t('Kamu harus menyetujui Syarat & Ketentuan', 'You must agree to the Terms of Service');
  static String get registerWelcome => _t('Bergabung dengan Nexbit', 'Join Nexbit');
  static String get registerWelcomeSubtitle => _t(
        'Buka akses ke ratusan aset kripto, staking, dan saham AS — semua dalam satu aplikasi.',
        'Unlock access to hundreds of crypto assets, staking, and US stocks — all in one app.',
      );

  // ---------------------------------------------------------------------
  // Staking — landing page
  // ---------------------------------------------------------------------
  static String get stakingHeroLine1 => _t('Kembangkan Kripto Kamu.', 'Grow Your Crypto.');
  static String get stakingHeroLine2 => _t('Raih Reward.', 'Earn Rewards.');
  static String get stakingHeroSubtitle => _t(
        'Staking aset crypto kamu dan dapatkan reward secara berkala dengan aman dan mudah.',
        'Stake your crypto assets and earn rewards regularly, safely and easily.',
      );
  static String get stakingCtaPrimary => _t('Mulai Staking', 'Start Staking');
  static String get stakingCtaSecondary => _t('Pelajari Staking', 'Learn About Staking');
  static String get stakingFeatureSafe => _t('Aman & Terpercaya', 'Safe & Trusted');
  static String get stakingFeatureApy => _t('APY Kompetitif', 'Competitive APY');
  static String get stakingFeatureDaily => _t('Reward Harian', 'Daily Rewards');
  static String get stakingAvailableAssets => _t('Aset Staking Tersedia', 'Available Staking Assets');
  static String get stakingSeeAll => _t('Lihat Semua', 'See All');
  static String get stakingApyLabel => _t('APY', 'APY');
  static String get stakingMinimumLabel => _t('Minimum Staking', 'Minimum Staking');
  static String get stakingStakeNow => _t('Stake Now', 'Stake Now');
  static String get stakingFlexible => _t('Flexible', 'Flexible');
  static String stakingDaysBadge(int days) => _t('$days Hari', '$days Days');

  // ---------------------------------------------------------------------
  // Staking — marketplace page
  // ---------------------------------------------------------------------
  static String get stakingMarketplaceHeading => _t('Pilih Aset untuk Staking', 'Choose an Asset to Stake');
  static String get stakingMarketplaceSubheading => _t(
        'Pilih aset yang ingin kamu staking dan dapatkan reward menarik.',
        'Pick the asset you want to stake and earn attractive rewards.',
      );
  static String get stakingColAsset => _t('Aset', 'Asset');
  static String get stakingColApy => _t('APY', 'APY');
  static String get stakingColMinimum => _t('Minimum', 'Minimum');
  static String get stakingColPeriode => _t('Periode', 'Period');
  static String get stakingWhatIsHeading => _t('Apa itu Staking?', 'What is Staking?');
  static String get stakingWhatIsParagraph => _t(
        'Staking adalah cara mendapatkan reward dengan menyimpan aset crypto tertentu dalam '
        'jaringan blockchain untuk mendukung operasionalnya.',
        'Staking is a way to earn rewards by holding certain crypto assets in a blockchain '
        'network to support its operation.',
      );
  static String get stakingLearnMore => _t('Pelajari Lebih Lanjut →', 'Learn More →');

  // ---------------------------------------------------------------------
  // Staking — detail page
  // ---------------------------------------------------------------------
  static String get stakingBack => _t('← Kembali', '← Back');
  static String stakingPageTitle(String id) => _t('$id Staking', '$id Staking');
  static String stakingEarnUpTo(double apy, String id) =>
      _t('Dapatkan hingga ${apy.toStringAsFixed(2)}% APY dengan staking $id.',
          'Earn up to ${apy.toStringAsFixed(2)}% APY by staking $id.');
  static String get stakingAmountLabel => _t('Jumlah yang ingin di-stake', 'Amount you want to stake');
  static String stakingAvailable(String amount, String id) => _t('Tersedia: $amount $id', 'Available: $amount $id');
  static String get stakingMax => _t('Maks', 'Max');
  static String get stakingChooseDuration => _t('Pilih Durasi', 'Choose Duration');
  static String get stakingSummaryHeading => _t('Ringkasan Staking', 'Staking Summary');
  static String get stakingSummaryAmount => _t('Jumlah Stake', 'Stake Amount');
  static String get stakingSummaryApy => _t('APY', 'APY');
  static String get stakingSummaryDuration => _t('Durasi', 'Duration');
  static String get stakingSummaryReward => _t('Estimasi Reward', 'Estimated Reward');
  static String get stakingSummaryRewardDate => _t('Tanggal Reward', 'Reward Date');
  static String get stakingSummaryRewardDaily => _t('Setiap hari', 'Every day');
  static String get stakingSummaryTotal => _t('Total setelah periode', 'Total after period');
  static String get stakingConfirmButton => _t('Konfirmasi Staking', 'Confirm Staking');
  static String get stakingLoginRequiredSnack =>
      _t('Masuk dulu untuk mulai staking', 'Log in first to start staking');

  // ---------------------------------------------------------------------
  // Staking — confirm dialog
  // ---------------------------------------------------------------------
  static String get stakingConfirmTitle => _t('Konfirmasi Staking', 'Confirm Staking');
  static String get stakingConfirmSubtitle =>
      _t('Kamu akan melakukan staking dengan detail sebagai berikut:', 'You are about to stake with the following details:');
  static String get stakingConfirmNote => _t(
        'Reward akan dikirimkan setiap hari ke akun kamu secara otomatis.',
        'Rewards will be sent to your account automatically every day.',
      );
  static String get stakingCancel => _t('Batal', 'Cancel');
  static String get stakingConfirm => _t('Konfirmasi', 'Confirm');

  // ---------------------------------------------------------------------
  // Staking — portfolio page
  // ---------------------------------------------------------------------
  static String get stakingSidebarDashboard => _t('Dashboard', 'Dashboard');
  static String get stakingSidebarMyStaking => _t('My Staking', 'My Staking');
  static String get stakingSidebarTxHistory => _t('Riwayat Transaksi', 'Transaction History');
  static String get stakingSidebarSettings => _t('Pengaturan', 'Settings');
  static String get stakingPortfolioHeading => _t('My Staking Portfolio', 'My Staking Portfolio');
  static String get stakingPortfolioSubheading => _t('Kelola semua staking kamu di satu tempat.', 'Manage all your stakes in one place.');
  static String get stakingStatTotalStaked => _t('Total Staked', 'Total Staked');
  static String get stakingStatTotalRewards => _t('Total Rewards', 'Total Rewards');
  static String get stakingStatEstimatedApy => _t('Estimated APY', 'Estimated APY');
  static String get stakingStatActiveStakes => _t('Active Stakes', 'Active Stakes');
  static String get stakingActiveListHeading => _t('Daftar Staking Aktif', 'Active Stakes');
  static String get stakingColStakeAmount => _t('Jumlah Stake', 'Stake Amount');
  static String get stakingColRewardRunning => _t('Reward Berjalan', 'Running Reward');
  static String get stakingColRewardDate => _t('Tanggal Reward', 'Reward Date');
  static String get stakingColStatus => _t('Status', 'Status');
  static String get stakingColAction => _t('Aksi', 'Action');
  static String get stakingStatusActive => _t('Aktif', 'Active');
  static String get stakingDetailButton => _t('Detail', 'Detail');
  static String get stakingUnstakeButton => _t('Unstake', 'Unstake');
  static String stakingDaysLeft(int days) => _t('$days Hari lagi', '$days days left');
  static String get stakingRewardThisMonth => _t('Reward Bulan Ini', 'Reward This Month');
  static String get stakingTotal => _t('Total', 'Total');
  static String get stakingWallet => _t('Wallet', 'Wallet');

  // ---------------------------------------------------------------------
  // Staking — dashboard page
  // ---------------------------------------------------------------------
  static String get stakingDashboardHeading => _t('Dashboard', 'Dashboard');
  static String stakingWelcomeBack(String name) => _t('Selamat datang kembali, $name 👋', 'Welcome back, $name 👋');
  static String get stakingStatTotalBalance => _t('Total Balance', 'Total Balance');
  static String get stakingStatThisMonth => _t('bulan ini', 'this month');
  static String get stakingStatOfTotalAssets => _t('dari total aset', 'of total assets');
  static String get stakingStatToday => _t('Hari Ini', 'Today');
  static String get stakingStatActiveContracts => _t('Kontrak aktif', 'Active contracts');
  static String get stakingStatActiveStakingLabel => _t('Staking Aktif', 'Active Staking');
  static String get stakingActiveStakingSectionHeading => _t('Staking Aktif', 'Active Staking');
  static String get stakingColJumlah => _t('Jumlah', 'Amount');
  static String get stakingColRewardShort => _t('Reward', 'Reward');
  static String get stakingRewardEarningsHeading => _t('Reward Earnings', 'Reward Earnings');
  static String get stakingLast7Days => _t('7 Hari Terakhir', 'Last 7 Days');
  static String get stakingPortfolioChartHeading => _t('Portofolio Staking', 'Staking Portfolio');
  static String get stakingRecentActivityHeading => _t('Aktivitas Terbaru', 'Recent Activity');
  static String get stakingActivityRewardReceived => _t('Reward Received', 'Reward Received');
  static String stakingActivityFromStaking(String id) => _t('Dari $id Staking', 'From $id Staking');
  static String get stakingActivityStakingStarted => _t('Staking Started', 'Staking Started');
  static String get stakingActivityStakingCompleted => _t('Staking Completed', 'Staking Completed');
  static String get stakingReferralHeading => _t('Ajak Teman', 'Invite Friends');
  static String get stakingReferralSubtitle => _t('Dapatkan reward hingga \$10', 'Earn rewards up to \$10');
  static String get stakingReferralButton => _t('Undang Sekarang →', 'Invite Now →');

  // Day-of-week abbreviations for the reward-earnings chart's x-axis.
  static String get dayMon => _t('Sen', 'Mon');
  static String get dayTue => _t('Sel', 'Tue');
  static String get dayWed => _t('Rab', 'Wed');
  static String get dayThu => _t('Kam', 'Thu');
  static String get dayFri => _t('Jum', 'Fri');
  static String get daySat => _t('Sab', 'Sat');
  static String get daySun => _t('Min', 'Sun');

  // Month abbreviations, used by the transaction-history page's date labels.
  static const _monthsId = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
  static const _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static String monthShort(int month) => _isEn ? _monthsEn[month - 1] : _monthsId[month - 1];

  // ---------------------------------------------------------------------
  // Staking — transaction history page
  // ---------------------------------------------------------------------
  static String get stakingTxHistoryHeading => _t('Riwayat Transaksi', 'Transaction History');
  static String get stakingTxHistorySubheading => _t(
        'Semua transaksi staking dan wallet kamu dalam satu tempat.',
        'All your staking and wallet transactions in one place.',
      );
  static String get stakingTxOverviewHeading => _t('Ringkasan', 'Overview');
  static String get stakingTxCountLabel => _t('Transaksi', 'Transactions');
  static String get stakingTxFrom => _t('Dari', 'From');
  static String get stakingTxTo => _t('Sampai', 'To');
  static String get stakingTxAvgTimeHeading => _t('Rata-rata Waktu Transaksi', 'Average Transaction Time');
  static String get stakingTxLastTransaction => _t('Transaksi terakhir', 'Last transaction');
  static String get stakingTxTabAll => _t('Semua Transaksi', 'All transactions');
  static String get stakingTxTabSend => _t('Kirim', 'Send');
  static String get stakingTxTabReceive => _t('Terima', 'Receive');
  static String get stakingTxColDate => _t('Tanggal', 'Date');
  static String get stakingTxColAsset => _t('Aset', 'Assets');
  static String get stakingTxColType => _t('Jenis', 'Type');
  static String get stakingTxSentTo => _t('Kirim ke', 'Sent to');
  static String get stakingTxReceivedFrom => _t('Terima dari', 'Received from');
  static String get stakingTxStatusCompleted => _t('Selesai', 'Completed');
  static String get stakingTxStatusPending => _t('Tertunda', 'Pending');
  static String get stakingTxEmpty => _t('Belum ada transaksi.', 'No transactions yet.');

  // ---------------------------------------------------------------------
  // Staking — active-stake Detail / Unstake dialogs
  // ---------------------------------------------------------------------
  static String get stakingDetailClose => _t('Tutup', 'Close');
  static String get stakingUnstakeConfirmTitle => _t('Konfirmasi Unstake', 'Confirm Unstake');
  static String get stakingUnstakeConfirmSubtitle =>
      _t('Kamu akan melakukan unstake untuk aset berikut:', 'You are about to unstake the following asset:');
  static String stakingUnstakeWarningLocked(int days) => _t(
        'Staking ini masih terkunci selama $days hari lagi. Unstake sekarang akan mengurangi reward sebesar 50%.',
        'This stake is still locked for $days more days. Unstaking now will reduce your reward by 50%.',
      );
  static String get stakingUnstakeInfoFlexible => _t(
        'Dana pokok dan reward akan langsung dikembalikan ke wallet utama kamu.',
        'Your principal and reward will be returned to your main wallet right away.',
      );
  static String get stakingUnstakeConfirmCta => _t('Ya, Unstake', 'Yes, Unstake');
  static String stakingUnstakeSuccessMessage(String amount, String id) => _t(
        'Berhasil unstake $amount $id. Dana telah dikembalikan ke wallet kamu.',
        'Successfully unstaked $amount $id. Funds have been returned to your wallet.',
      );
  static String get stakingEmptyActiveStakes => _t('Belum ada staking aktif.', 'No active stakes yet.');

  // ---------------------------------------------------------------------
  // Staking — settings page
  // ---------------------------------------------------------------------
  static String get stakingSettingsHeading => _t('Pengaturan', 'Settings');
  static String get stakingSettingsSubheading =>
      _t('Kelola keamanan dan preferensi akun kamu.', 'Manage your account security and preferences.');
  static String get stakingChangePasswordHeading => _t('Ubah Kata Sandi', 'Change Password');
  static String get stakingOldPassword => _t('Kata Sandi Lama', 'Old Password');
  static String get stakingNewPassword => _t('Kata Sandi Baru', 'New Password');
  static String get stakingConfirmPassword => _t('Konfirmasi Kata Sandi', 'Confirm Password');
  static String get stakingPasswordRequirementsHeading => _t('Kata sandi baru harus mengandung :', 'New password must contain :');
  static String get stakingReqMinLength => _t('Minimal 8 karakter', 'At least 8 characters');
  static String get stakingReqLower => _t('Minimal 1 huruf kecil (a-z)', 'At least 1 lower letter (a-z)');
  static String get stakingReqUpper => _t('Minimal 1 huruf besar (A-Z)', 'At least 1 uppercase letter (A-Z)');
  static String get stakingReqNumber => _t('Minimal 1 angka (0-9)', 'At least 1 number (0-9)');
  static String get stakingReqSpecial => _t('Minimal 1 karakter spesial', 'At least 1 special character');
  static String get stakingSaveChange => _t('Simpan Perubahan', 'Save Change');
  static String get stakingOldPasswordRequired => _t('Kata sandi lama wajib diisi', 'Old password is required');
  static String get stakingConfirmPasswordMismatch => _t('Konfirmasi kata sandi tidak cocok', 'Confirm password does not match');
  static String get stakingPasswordRequirementsNotMet =>
      _t('Kata sandi baru belum memenuhi semua syarat', 'New password does not meet all requirements');
  static String get stakingPasswordChangedSuccess => _t('Kata sandi berhasil diubah.', 'Password successfully changed.');
  static String get staking2faHeading => _t('Autentikasi Dua Faktor', 'Two-Factor Authentication');
  static String get staking2faAuthApp => _t('Aplikasi Autentikasi', 'Authentication app');
  static String get staking2faAuthAppDesc => _t('Aplikasi autentikator Google', 'Google auth app');
  static String get staking2faPrimaryEmail => _t('Email Utama', 'Primary email');
  static String get staking2faPrimaryEmailDesc => _t('Email untuk mengirim notifikasi', 'E-mail used to send notifications');
  static String get staking2faSmsRecovery => _t('Pemulihan SMS', 'SMS Recovery');
  static String get staking2faSmsRecoveryDesc => _t('Nomor telepon kamu atau lainnya', 'Your phone number or something');

  // ---------------------------------------------------------------------
  // Futures page
  // ---------------------------------------------------------------------
  static String get futuresHeading => _t('Futures Trading', 'Futures Trading');
  static String get futuresSubtitle1 => _t('Perdagangan kontrak berjangka dengan leverage fleksibel', 'Trade perpetual contracts with flexible leverage');
  static String get futuresSubtitle2 => _t('Long / Short · Leverage hingga 100x · Likuiditas Tinggi', 'Long / Short · Leverage up to 100x · High Liquidity');
  static String get futuresStatVolume24h => _t('Total Volume (24h)', 'Total Volume (24h)');
  static String get futuresStatOpenInterest => _t('Open Interest', 'Open Interest');
  static String get futuresStatFundingRate => _t('Funding Rate', 'Funding Rate');
  static String futuresNextFunding(String time) => _t('Next Funding: $time', 'Next Funding: $time');
  static String get futuresAssetCrypto => _t('Crypto', 'Crypto');
  static String get futuresAssetForex => _t('Forex', 'Forex');
  static String get futuresAssetSaham => _t('Saham', 'Stocks');
  static String get futuresSearchHint => _t('Cari pasangan futures...', 'Search futures pairs...');
  static String get futuresPerpetual => _t('Perpetual', 'Perpetual');
  static String get futuresMarkPrice => _t('Mark Price', 'Mark Price');
  static String get futures24hHigh => _t('24h High', '24h High');
  static String get futures24hLow => _t('24h Low', '24h Low');
  static String get futures24hVolume => _t('24h Volume', '24h Volume');
  static String get futuresOrderBook => _t('Order Book', 'Order Book');
  static String get futuresColPrice => _t('Price (USDT)', 'Price (USDT)');
  static String get futuresColSize => _t('Size', 'Size');
  static String get futuresColTotal => _t('Total', 'Total');
  static String get futuresRecentTrades => _t('Recent Trades', 'Recent Trades');
  static String get futuresColTime => _t('Time', 'Time');
  static String futuresTabPositions(int n) => _t('Posisi ($n)', 'Positions ($n)');
  static String futuresTabOpenOrders(int n) => _t('Order Terbuka ($n)', 'Open Orders ($n)');
  static String get futuresTabOrderHistory => _t('Riwayat Order', 'Order History');
  static String get futuresTabTradeHistory => _t('Riwayat Transaksi', 'Trade History');
  static String get futuresColContract => _t('Kontrak', 'Contract');
  static String get futuresColSide => _t('Side', 'Side');
  static String get futuresColEntryPrice => _t('Entry Price', 'Entry Price');
  static String get futuresColMarkPrice => _t('Mark Price', 'Mark Price');
  static String get futuresColPnl => _t('PnL', 'PnL');
  static String get futuresColLiqPrice => _t('Liq. Price', 'Liq. Price');
  static String get futuresColSymbol => _t('Simbol', 'Symbol');
  static String get futuresColType => _t('Tipe', 'Type');
  static String get futuresColAmount => _t('Jumlah', 'Amount');
  static String get futuresColStatus => _t('Status', 'Status');
  static String get futuresColFee => _t('Fee', 'Fee');
  static String get futuresClose => _t('Close', 'Close');
  static String get futuresLong => _t('Long', 'Long');
  static String get futuresShort => _t('Short', 'Short');
  static String get futuresNoPositions => _t('Tidak ada posisi terbuka', 'No open positions');
  static String get futuresNoOpenOrders => _t('Tidak ada order terbuka', 'No open orders');
  static String get futuresNoHistory => _t('Belum ada riwayat', 'No history yet');
  static String get futuresPositionClosedSnack => _t('Posisi ditutup', 'Position closed');
  static String get futuresOrderPlacedSnack => _t('Order berhasil dibuka', 'Order opened successfully');
  static String get futuresOrderQueuedSnack => _t('Order berhasil dipasang', 'Order placed successfully');
  static String get futuresTabLimit => _t('Limit', 'Limit');
  static String get futuresTabMarket => _t('Market', 'Market');
  static String get futuresTabStopLimit => _t('Stop Limit', 'Stop Limit');
  static String get futuresTabStopMarket => _t('Stop Market', 'Stop Market');
  static String get futuresFormPrice => _t('Price', 'Price');
  static String get futuresFormAmount => _t('Amount', 'Amount');
  static String get futuresFormLeverage => _t('Leverage', 'Leverage');
  static String get futuresMarginModeCross => _t('Cross', 'Cross');
  static String get futuresMarginModeIsolated => _t('Isolated', 'Isolated');
  static String get futuresSelectLeverage => _t('Pilih Leverage', 'Select Leverage');
  static String get futuresOrderValue => _t('Order Value', 'Order Value');
  static String get futuresEstLiqPriceLabel => _t('Est. Liq. Price', 'Est. Liq. Price');
  static String futuresLongBuy(String id) => _t('Long / Buy $id', 'Long / Buy $id');
  static String futuresShortSell(String id) => _t('Short / Sell $id', 'Short / Sell $id');
  static String get futuresAmountRequired => _t('Jumlah wajib diisi', 'Amount is required');
  static String get futuresLoginRequiredSnack =>
      _t('Masuk dulu untuk mulai trading futures', 'Log in first to start trading futures');
  static String get futuresAccountInfo => _t('Account Info', 'Account Info');
  static String get futuresBalance => _t('Futures Balance', 'Futures Balance');
  static String get futuresAvailableBalance => _t('Available Balance', 'Available Balance');
  static String get futuresMarginBalance => _t('Margin Balance', 'Margin Balance');
  static String get futuresUsedMargin => _t('Used Margin', 'Used Margin');
  static String get futuresUnrealizedPnl => _t('Unrealized PnL', 'Unrealized PnL');
  static String get futuresRealizedPnl => _t('Realized PnL', 'Realized PnL');
  static String get futuresMarginRatio => _t('Margin Ratio', 'Margin Ratio');
  static String get futuresDeposit => _t('Deposit', 'Deposit');
  static String get futuresExchange => _t('Tukar', 'Exchange');
  static String get futuresBuy => _t('Beli', 'Buy');
  static String get futuresComingSoonSnack => _t('Fitur ini segera hadir', 'This feature is coming soon');

  // ---------------------------------------------------------------------
  // Deposit dialog (Futures balance / Spot wallet top-up)
  // ---------------------------------------------------------------------
  static String get depositFuturesTitle => _t('Deposit Saldo Futures', 'Deposit Futures Balance');
  static String get depositSpotTitle => _t('Deposit Saldo Spot', 'Deposit Spot Balance');
  static String get depositAmountRequired => _t('Jumlah harus lebih dari 0', 'Amount must be greater than 0');
  static String get depositDemoNotice => _t(
        'Mode Demo: ini menambah saldo virtual secara langsung, bukan pembayaran sungguhan.',
        "Demo Mode: this adds virtual balance directly, it's not a real payment.",
      );
  static String get depositSuccessSnack => _t('Deposit berhasil', 'Deposit successful');
  static String get depositLoginRequiredSnack =>
      _t('Masuk dulu untuk melakukan deposit', 'Log in first to make a deposit');

  // ---------------------------------------------------------------------
  // Withdraw (same dialog as Deposit, via the direction toggle)
  // ---------------------------------------------------------------------
  static String get withdrawLabel => _t('Tarik', 'Withdraw');
  static String get withdrawFuturesTitle => _t('Tarik Saldo Futures', 'Withdraw Futures Balance');
  static String get withdrawSpotTitle => _t('Tarik Saldo Spot', 'Withdraw Spot Balance');
  static String get withdrawDemoNotice => _t(
        'Mode Demo: ini mengurangi saldo virtual secara langsung, uangnya tidak benar-benar ditransfer ke mana pun.',
        "Demo Mode: this removes virtual balance directly, it's not a real payout.",
      );
  static String get withdrawSuccessSnack => _t('Penarikan berhasil', 'Withdrawal successful');
  static String get withdrawLoginRequiredSnack =>
      _t('Masuk dulu untuk melakukan penarikan', 'Log in first to make a withdrawal');

  // ---------------------------------------------------------------------
  // Exchange dialog (move balance between Spot wallet and Futures margin)
  // ---------------------------------------------------------------------
  static String get exchangeTitle => _t('Tukar Saldo', 'Exchange Balance');
  static String get exchangeToFutures => _t('Spot → Futures', 'Spot → Futures');
  static String get exchangeToSpot => _t('Futures → Spot', 'Futures → Spot');
  static String get exchangeFrom => _t('Dari', 'From');
  static String get exchangeTo => _t('Ke', 'To');
  static String get exchangeYouReceive => _t('Anda menerima', 'You receive');
  static String get exchangeRateNotice => _t(
        'Kurs mengikuti harga USDT/IDR yang berjalan (live).',
        'Rate follows the live USDT/IDR price.',
      );
  static String get exchangeAmountRequired => _t('Jumlah harus lebih dari 0', 'Amount must be greater than 0');
  static String get exchangeSuccessSnack => _t('Tukar saldo berhasil', 'Exchange successful');
  static String get exchangeLoginRequiredSnack =>
      _t('Masuk dulu untuk menukar saldo', 'Log in first to exchange balance');
  static String get futuresContractDetails => _t('Detail Kontrak', 'Contract Details');
  static String get futuresExpirationDate => _t('Tanggal Kedaluwarsa', 'Expiration Date');
  static String get futuresPerpetualValue => _t('Perpetual', 'Perpetual');
  static String get futuresIndexPrice => _t('Index Price', 'Index Price');
  static String get futuresContractSize => _t('Ukuran Kontrak', 'Contract Size');
  static String get futuresMaintenanceMargin => _t('Margin Maintenance', 'Maintenance Margin');
  static String get futuresShowMore => _t('Tampilkan', 'Show');
  static String get futuresShowLess => _t('Sembunyikan', 'Hide');
  static String get futuresFeatureLeverageTitle => _t('Leverage Fleksibel', 'Flexible Leverage');
  static String get futuresFeatureLeverageDesc => _t('Trading dengan leverage hingga 100x', 'Trade with up to 100x leverage');
  static String get futuresFeatureLiquidityTitle => _t('Likuiditas Tinggi', 'High Liquidity');
  static String get futuresFeatureLiquidityDesc => _t('Eksekusi cepat dengan harga terbaik', 'Fast execution at the best price');
  static String get futuresFeatureSecurityTitle => _t('Keamanan Terjamin', 'Guaranteed Security');
  static String get futuresFeatureSecurityDesc => _t('Sistem risk management profesional', 'Professional risk management system');

  // ---------------------------------------------------------------------
  // Account pages — Profil Saya / Keamanan / Preferensi / Bantuan
  // (reached from the navbar's account menu)
  // ---------------------------------------------------------------------
  static String get accountCancel => _t('Batal', 'Cancel');
  static String get accountConfirm => _t('Konfirmasi', 'Confirm');
  static String get accountComingSoonSnack => _t('Fitur ini segera hadir', 'This feature is coming soon');

  // Profil Saya
  static String get profileHeading => _t('Profil Saya', 'My Profile');
  static String get profileVerifiedBadge => _t('Terverifikasi', 'Verified');
  static String get profileUnverifiedBadge => _t('Belum Terverifikasi', 'Unverified');
  static String get profilePendingBadge => _t('Diproses', 'Pending');
  static String get profileVerifyNowButton => _t('Verifikasi Sekarang', 'Verify Now');
  static String profileMemberSince(String date) => _t('Member sejak $date', 'Member since $date');
  static String get profilePersonalInfoHeading => _t('Informasi Pribadi', 'Personal Information');
  static String get profileFullName => _t('Nama Lengkap', 'Full Name');
  static String get profileUsername => _t('Username', 'Username');
  static String get profilePhoneNumber => _t('Nomor Telepon', 'Phone Number');
  static String get profileCountry => _t('Negara', 'Country');
  static String get profileUserId => _t('ID Pengguna', 'User ID');
  static String get profileAccountVerificationHeading => _t('Verifikasi Akun', 'Account Verification');
  static String get profileIdentity => _t('Identitas', 'Identity');

  // ---------------------------------------------------------------------
  // Verifikasi Identitas (KYC-lite) — reached from the account menu and
  // from Profil Saya's Account Verification section.
  // ---------------------------------------------------------------------
  static String get kycHeading => _t('Verifikasi Identitas', 'Identity Verification');
  static String get kycFormHeading => _t('Ajukan Verifikasi', 'Submit Verification');
  static String get kycDemoNotice => _t(
        'Mode Demo: verifikasi ini tidak dicek ke database resmi manapun, hanya simulasi. Jangan masukkan data pribadi asli — isi dengan data contoh saja.',
        "Demo Mode: this isn't checked against any real database, it's a simulation only. Don't enter real personal information — sample data is fine.",
      );
  static String get kycFullNameLabel => _t('Nama Lengkap', 'Full Name');
  static String get kycFullNameHint => _t('Masukkan nama lengkap', 'Enter your full name');
  static String get kycIdNumberLabel => _t('Nomor KTP (16 digit)', 'ID Number (16 digits)');
  static String get kycIdNumberHint => _t('mis. 3271000000000001', 'e.g. 3271000000000001');
  static String get kycNameRequired => _t('Nama lengkap wajib diisi', 'Full name is required');
  static String get kycIdNumberInvalid => _t('Nomor KTP harus 16 digit angka', 'ID number must be 16 digits');
  static String get kycSubmitButton => _t('Ajukan Verifikasi', 'Submit for Verification');
  static String get kycPendingTitle => _t('Sedang Diproses', 'Under Review');
  static String get kycPendingSubtitle => _t(
        'Verifikasi kamu sedang ditinjau. Biasanya selesai dalam beberapa saat — coba muat ulang halaman ini nanti.',
        'Your verification is being reviewed. Usually done within moments — try reloading this page again shortly.',
      );
  static String get kycVerifiedTitle => _t('Terverifikasi', 'Verified');
  static String get kycVerifiedSubtitle =>
      _t('Identitas kamu sudah terverifikasi.', 'Your identity has been verified.');
  static String get profileSettingsHeading => _t('Pengaturan Profil', 'Profile Settings');
  static String get profilePhoto => _t('Foto Profil', 'Profile Photo');
  static String get profileDisplayName => _t('Nama Tampilan', 'Display Name');
  static String get profileDisplayNameRequired => _t('Nama tidak boleh kosong', 'Name cannot be empty');
  static String get profileDisplayNameUpdatedSnack => _t('Nama tampilan berhasil diubah', 'Display name updated');
  static String get profileLanguageLabel => _t('Bahasa', 'Language');
  static String get profileDangerZoneHeading => _t('Zona Bahaya', 'Danger Zone');
  static String get profileLogoutAllDevices => _t('Logout semua perangkat', 'Log out of all devices');
  static String get profileDeactivateAccount => _t('Nonaktifkan akun', 'Deactivate account');
  static String get profileDeleteAccount => _t('Hapus akun', 'Delete account');
  static String get profileDeactivateConfirmTitle => _t('Nonaktifkan akun?', 'Deactivate account?');
  static String get profileDeactivateConfirmMessage => _t(
        'Akun kamu akan dinonaktifkan sementara dan kamu akan keluar dari sesi ini. Kamu bisa mengaktifkannya kembali dengan masuk lagi.',
        'Your account will be temporarily deactivated and you will be signed out. You can reactivate it by logging back in.',
      );
  static String get profileDeleteConfirmTitle => _t('Hapus akun secara permanen?', 'Permanently delete account?');
  static String get profileDeleteConfirmMessage => _t(
        'Tindakan ini tidak dapat dibatalkan. Semua data akun kamu akan dihapus secara permanen.',
        'This action cannot be undone. All of your account data will be permanently deleted.',
      );
  static String get profileLogoutAllSnack => _t('Berhasil keluar dari semua perangkat', 'Logged out of all devices');
  static String get profileAccountDeactivatedSnack => _t('Akun telah dinonaktifkan', 'Account has been deactivated');
  static String get profileAccountDeletedSnack => _t('Akun telah dihapus', 'Account has been deleted');

  // Keamanan
  static String get securityHeading => _t('Keamanan', 'Security');
  static String get securityScoreHeading => _t('Skor Keamanan', 'Security Score');
  static String get securityScoreDesc => _t(
        'Akun Anda cukup aman. Aktifkan 2FA untuk meningkatkan keamanan akun Anda.',
        'Your account is fairly secure. Enable 2FA to further strengthen your account security.',
      );
  static String get securityImproveButton => _t('Tingkatkan Keamanan', 'Improve Security');
  static String get securityLoginAuthHeading => _t('Login & Authentication', 'Login & Authentication');
  static String get securityPassword => _t('Password', 'Password');
  static String securityPasswordLastChanged(int days) =>
      _t('Terakhir diubah $days hari lalu', 'Last changed $days days ago');
  static String get securityChangeButton => _t('Ubah', 'Change');
  static String get security2fa => _t('Two-Factor Authentication', 'Two-Factor Authentication');
  static String get security2faDesc => _t('Tambahkan lapisan keamanan tambahan', 'Add an extra layer of security');
  static String get securityActive => _t('Aktif', 'Active');
  static String get securityInactive => _t('Nonaktif', 'Inactive');
  static String get securityBiometric => _t('Biometric Login', 'Biometric Login');
  static String get securityBiometricDesc =>
      _t('Gunakan fingerprint / Face ID untuk login', 'Use fingerprint / Face ID to log in');
  static String get securityActiveDevicesHeading => _t('Perangkat Aktif', 'Active Devices');
  static String get securityCurrentDevice => _t('Perangkat Saat Ini', 'Current Device');
  static String get securityLogOutDevice => _t('Keluar dari perangkat ini', 'Log out of this device');
  static String securityViewAllDevices(int n) => _t('Lihat semua perangkat ($n)', 'View all devices ($n)');
  static String get securityDeviceLoggedOutSnack => _t('Perangkat berhasil dikeluarkan', 'Device logged out');
  static String get securityActivityHeading => _t('Aktivitas Keamanan', 'Security Activity');
  static String get securityViewAll => _t('Lihat semua', 'View all');
  static String get securityLoginSuccess => _t('Login berhasil', 'Successful login');
  static String get securityPasswordChangedActivity => _t('Password diubah', 'Password changed');
  static String get securityLoginFailedActivity => _t('Percobaan login gagal', 'Failed login attempt');
  static String get securityChangePasswordTitle => _t('Ubah Password', 'Change Password');
  static String get securityOldPassword => _t('Password Lama', 'Old Password');
  static String get securityNewPassword => _t('Password Baru', 'New Password');
  static String get securityConfirmNewPassword => _t('Konfirmasi Password Baru', 'Confirm New Password');
  static String get securityPasswordChangedSnack => _t('Password berhasil diubah', 'Password changed successfully');
  static String get securityPasswordFieldsRequired => _t('Semua kolom wajib diisi', 'All fields are required');
  static String get securityPasswordTooShort =>
      _t('Password baru minimal 8 karakter', 'New password must be at least 8 characters');
  static String get securityPasswordMismatch => _t('Konfirmasi password tidak cocok', "Passwords don't match");

  // Preferensi
  static String get preferencesHeading => _t('Preferensi', 'Preferences');
  static String get preferencesDisplayHeading => _t('Tampilan', 'Display');
  static String get preferencesTheme => _t('Tema', 'Theme');
  static String get preferencesThemeDesc => _t('Pilih tema aplikasi', 'Choose the app theme');
  static String get preferencesThemeDark => _t('Dark', 'Dark');
  static String get preferencesThemeLight => _t('Light', 'Light');
  static String get preferencesThemeSystem => _t('System', 'System');
  static String get preferencesThemeNotAvailableSnack =>
      _t('Tema ini akan segera hadir — Dark tetap aktif untuk sekarang', 'This theme is coming soon — Dark stays active for now');
  static String get preferencesLanguageDesc => _t('Pilih bahasa aplikasi', 'Choose the app language');
  static String get preferencesTradingHeading => _t('Trading', 'Trading');
  static String get preferencesDefaultTimeframe => _t('Default Timeframe', 'Default Timeframe');
  static String get preferencesDefaultChart => _t('Default Chart', 'Default Chart');
  static String get preferencesNotificationsHeading => _t('Notifikasi', 'Notifications');
  static String get preferencesPriceNotif => _t('Notifikasi Harga', 'Price Notifications');
  static String get preferencesPriceAlert => _t('Price Alert', 'Price Alert');
  static String get preferencesOrderFilled => _t('Order Filled', 'Order Filled');
  static String get preferencesOrderCancelled => _t('Order Cancelled', 'Order Cancelled');
  static String get preferencesMarketNews => _t('Berita Market', 'Market News');
  static String get preferencesPromotions => _t('Promosi', 'Promotions');
  static String get preferencesCurrencyHeading => _t('Mata Uang', 'Currency');
  static String get preferencesCurrency => _t('Mata Uang', 'Currency');
  static String get preferencesCurrencyDesc => _t('Pilih mata uang utama', 'Choose your primary currency');
  static String get preferencesDashboardHeading => _t('Tampilan Dashboard', 'Dashboard Display');
  static String get preferencesCompactMode => _t('Compact Mode', 'Compact Mode');
  static String get preferencesShowBalance => _t('Show Balance', 'Show Balance');
  static String get preferencesShowPnl => _t('Show P&L', 'Show P&L');
  static String get preferencesShowPortfolio => _t('Show Portfolio', 'Show Portfolio');
  static String get preferencesSavedSnack => _t('Preferensi disimpan', 'Preference saved');

  // Bantuan
  static String get helpHeading => _t('Bantuan', 'Help');
  static String get helpSearchHint => _t('Cari bantuan atau pertanyaan...', 'Search for help or a question...');
  static String get helpQuickHelp => _t('Quick Help', 'Quick Help');
  static String get helpGettingStarted => _t('Panduan Pemula', 'Getting Started');
  static String get helpGettingStartedDesc => _t('Pelajari dasar-dasar trading', 'Learn the basics of trading');
  static String get helpDepositWithdraw => _t('Deposit & Withdraw', 'Deposit & Withdraw');
  static String get helpDepositWithdrawDesc => _t('Masalah terkait transaksi', 'Issues related to transactions');
  static String get helpTrading => _t('Trading', 'Trading');
  static String get helpTradingDesc => _t('Order, chart, dan posisi', 'Orders, charts, and positions');
  static String get helpSecurity => _t('Keamanan', 'Security');
  static String get helpSecurityDesc => _t('Password, 2FA, dan akun', 'Password, 2FA, and account');
  static String get helpFaqHeading => _t('FAQ', 'FAQ');
  static String get helpFaqQ1 => _t('Bagaimana cara mengubah password?', 'How do I change my password?');
  static String get helpFaqA1 => _t(
        'Buka menu akun → Keamanan → Login & Authentication, lalu tekan tombol "Ubah" di samping Password.',
        'Open the account menu → Security → Login & Authentication, then tap "Change" next to Password.',
      );
  static String get helpFaqQ2 => _t('Bagaimana cara mengaktifkan 2FA?', 'How do I enable 2FA?');
  static String get helpFaqA2 => _t(
        'Buka menu akun → Keamanan → Login & Authentication, lalu aktifkan Two-Factor Authentication.',
        'Open the account menu → Security → Login & Authentication, then turn on Two-Factor Authentication.',
      );
  static String get helpFaqQ3 => _t('Kenapa saldo saya belum berubah?', "Why hasn't my balance updated?");
  static String get helpFaqA3 => _t(
        'Saldo diperbarui otomatis setiap kali posisi dibuka/ditutup. Coba refresh halaman jika belum muncul.',
        'Balance updates automatically whenever a position opens/closes. Try refreshing the page if it hasn\'t appeared yet.',
      );
  static String get helpFaqQ4 => _t('Bagaimana cara melakukan withdrawal?', 'How do I make a withdrawal?');
  static String get helpFaqA4 => _t(
        'Buka menu Deposit di halaman Futures atau Spot, lalu pilih tab "Tarik". Ingat, ini masih mode demo — saldo yang ditarik adalah saldo virtual, bukan uang sungguhan.',
        'Open the Deposit dialog on the Futures or Spot page, then switch to the "Withdraw" tab. Note this is still demo mode — the balance withdrawn is virtual, not real money.',
      );
  static String get helpViewAllFaq => _t('Lihat semua FAQ', 'View all FAQ');
  static String get helpContactUs => _t('Hubungi Kami', 'Contact Us');
  static String get helpContactUsDesc =>
      _t('Masih membutuhkan bantuan? Tim support kami siap membantu.', 'Still need help? Our support team is ready to assist.');
  static String get helpChatSupport => _t('Chat dengan Support', 'Chat with Support');
  static String get helpOrEmail => _t('atau kirim email ke', 'or send an email to');
  static String get helpSystemStatus => _t('Status Sistem', 'System Status');
  static String get helpStatusTrading => _t('Trading', 'Trading');
  static String get helpStatusDeposit => _t('Deposit', 'Deposit');
  static String get helpStatusWithdrawal => _t('Withdrawal', 'Withdrawal');
  static String get helpStatusMarketData => _t('Market Data', 'Market Data');
  static String get helpStatusApi => _t('API', 'API');
  static String get helpStatusOperational => _t('Operational', 'Operational');

  // ---------------------------------------------------------------------
  // Blog page — reached from the navbar's "Blog" link
  // ---------------------------------------------------------------------
  static String get blogHeading => _t('Blog Nexbit', 'Nexbit Blog');
  static String get blogSubtitle =>
      _t('Berita, analisis, dan panduan seputar dunia aset digital', 'News, analysis, and guides from the world of digital assets');
  static String get blogSearchHint => _t('Cari artikel...', 'Search articles...');
  static String get blogMoreArticles => _t('Artikel Lainnya', 'More Articles');
  static String get blogTabAll => _t('Semua', 'All');
  static String get blogCategoryBitcoin => _t('Berita Bitcoin', 'Bitcoin News');
  static String get blogCategoryBlockchain => _t('Berita Blockchain', 'Blockchain News');
  static String get blogCategoryMarket => _t('Market', 'Market');
  static String get blogCategoryGuide => _t('Panduan', 'Guide');
  static String blogMonthsAgo(int months) => _t('$months bulan lalu', '$months months ago');
  static String get blogNoMatchingPosts => _t('Tidak ada artikel yang cocok', 'No matching articles');
  static String get blogBackToList => _t('Kembali ke Blog', 'Back to Blog');
  static String get blogRelatedHeading => _t('Artikel Terkait', 'Related Articles');
  static String get blogPromoHeading => _t('Jelajahi Nexbit', 'Explore Nexbit');
  static String get blogPromoStakingTitle => _t('Nexbit Staking', 'Nexbit Staking');
  static String get blogPromoStakingDesc =>
      _t('Kunci aset kripto kamu dan dapatkan reward pasif setiap hari', 'Lock up your crypto and earn passive rewards every day');
  static String get blogPromoStakingCta => _t('Pelajari Staking', 'Explore Staking');
  static String get blogPromoFuturesTitle => _t('Nexbit Futures', 'Nexbit Futures');
  static String get blogPromoFuturesDesc =>
      _t('Trading kontrak berjangka dengan leverage hingga 100x', 'Trade perpetual contracts with leverage up to 100x');
  static String get blogPromoFuturesCta => _t('Buka Futures', 'Open Futures');

  // Post titles — a fixed, hand-written bilingual seed list (see
  // domain/models/blog_post.dart), not a real CMS feed.
  static String get blogPost1 => _t('Apa yang Terjadi Jika Bitcoin Mencapai All-Time High?', 'What Happens if Bitcoin Reaches an All-Time High?');
  static String get blogPost2 =>
      _t('Disesuaikan dengan Inflasi, Bitcoin Belum Capai ATH Sesungguhnya', "Adjusted for Inflation, Bitcoin Hasn't Topped Its All-Time High");
  static String get blogPost3 =>
      _t('Cadangan Bitcoin ETF Bertambah 12,4 Ribu BTC dalam Sehari', 'Bitcoin ETF Reserves Added 12.4K BTC in a Single Day');
  static String get blogPost4 => _t(
      'ATH Bitcoin Bisa Lebih Cepat Terjadi Tanpa Aliran Dana ETF', "Bitcoin's ATH Could've Arrived Sooner Without ETF Flows");
  static String get blogPost5 => _t(
      'Apakah Tesla Membeli Bitcoin Lagi? Data Wallet Memicu Spekulasi', 'Is Tesla Buying Bitcoin Again? Wallet Data Sparks Speculation');
  static String get blogPost6 => _t(
      'Fase Akumulasi Berlanjut Seiring ETF Dorong Harga ke \$100K', 'Accumulation Phase Continues as ETFs Push Price Toward \$100K');
  static String get blogPost7 => _t(
      'Sebuah Negara Bagian AS Kaji Proposal ETF Bitcoin untuk Dana Pensiun', 'A US State Weighs Bitcoin ETF Proposal for Pension Funds');
  static String get blogPost8 => _t(
      'Transfer Token Native: Evolusi Interoperabilitas Berikutnya', 'Native Token Transfers: The Next Evolution of Interoperability');
  static String get blogPost9 => _t(
      'Inovasi Digital Perlu Menyeimbangkan Desentralisasi dan Keamanan', 'Digital Innovation Needs to Balance Decentralization and Security');
  static String get blogPost10 => _t('Tokenisasi: Aset Nyata, Manfaat Nyata', 'Tokenization: Real World Assets, Real World Benefits');
  static String get blogPost11 => _t(
      'Cara Mengubah Aset Kripto Menjadi Kartu Hadiah untuk Hemat', 'How to Turn Crypto Holdings Into Gift Cards to Save Money');
  static String get blogPost12 => _t(
      'Ethereum Bergerak ke Masa Depan Berbasis Rollup Usai Hard Fork Dencun',
      'Ethereum Leans Into a Rollup-Centric Future as the Dencun Hard Fork Looms');

  // Detail-page body copy — two generic, category-level paragraphs reused
  // across every post in that category (see domain/models/blog_post.dart
  // for why: no real article backend behind this demo).
  static String get blogBodyBitcoin1 => _t(
      'Bitcoin tetap menjadi aset yang paling banyak diperhatikan di pasar aset digital, dengan pergerakan harganya sering dijadikan acuan arah pasar secara keseluruhan.',
      "Bitcoin remains the most closely watched asset in digital markets, with its price action often treated as a bellwether for the broader market.");
  static String get blogBodyBitcoin2 => _t(
      'Aliran dana institusional lewat produk seperti ETF spot terus menjadi salah satu faktor yang memengaruhi likuiditas dan sentimen jangka pendek.',
      'Institutional flows through products like spot ETFs continue to be one of the factors shaping short-term liquidity and sentiment.');
  static String get blogBodyBitcoin3 => _t(
      'Seperti biasa, pergerakan harga jangka pendek tidak selalu mencerminkan fundamental jangka panjang — selalu lakukan riset mandiri sebelum mengambil keputusan.',
      'As always, short-term price action doesn\'t necessarily reflect long-term fundamentals — always do your own research before making a decision.');
  static String get blogBodyBlockchain1 => _t(
      'Perkembangan infrastruktur blockchain terus bergerak cepat, dari peningkatan skalabilitas hingga solusi interoperabilitas antar-jaringan.',
      'Blockchain infrastructure keeps evolving quickly, from scalability upgrades to cross-network interoperability solutions.');
  static String get blogBodyBlockchain2 => _t(
      'Upgrade jaringan besar biasanya membawa dampak berantai ke biaya transaksi, throughput, dan pengalaman developer di ekosistem terkait.',
      'Major network upgrades typically ripple outward into transaction costs, throughput, and the developer experience across the ecosystem.');
  static String get blogBodyBlockchain3 => _t(
      'Bagi pengguna, perubahan ini sering kali terasa sebagai transaksi yang lebih cepat dan murah tanpa perlu memahami detail teknis di baliknya.',
      'For everyday users, these changes often just show up as faster, cheaper transactions without needing to understand the technical details behind them.');
  static String get blogBodyMarket1 => _t(
      'Dinamika pasar aset digital dipengaruhi banyak faktor sekaligus — mulai dari data makroekonomi, regulasi, hingga sentimen komunitas.',
      'Digital-asset market dynamics are shaped by many factors at once — macroeconomic data, regulation, and community sentiment among them.');
  static String get blogBodyMarket2 => _t(
      'Tren adopsi di sektor-sektor baru, seperti tokenisasi aset dunia nyata, mulai menarik perhatian pemain institusional maupun ritel.',
      'Adoption trends in newer sectors, like real-world asset tokenization, are starting to draw attention from both institutional and retail players.');
  static String get blogBodyMarket3 => _t(
      'Memahami konteks di balik sebuah pergerakan pasar membantu trader membuat keputusan yang lebih terukur, bukan sekadar bereaksi terhadap harga.',
      'Understanding the context behind a market move helps traders make more measured decisions instead of just reacting to price.');
  static String get blogBodyGuide1 => _t(
      'Panduan praktis membantu pengguna baru memahami konsep dasar sebelum terjun ke fitur yang lebih kompleks.',
      'Practical guides help new users grasp the basics before diving into more complex features.');
  static String get blogBodyGuide2 => _t(
      'Langkah-langkah sederhana, dijelaskan dengan bahasa yang mudah dipahami, biasanya jauh lebih berguna daripada penjelasan teknis yang rumit.',
      'Simple steps explained in plain language are usually far more useful than a dense technical explanation.');
  static String get blogBodyGuide3 => _t(
      'Selalu sesuaikan langkah-langkah ini dengan kondisi akun dan preferensi keamanan kamu sendiri.',
      'Always adapt these steps to your own account setup and security preferences.');
}
