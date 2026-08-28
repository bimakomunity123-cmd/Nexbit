import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../auth/presentation/pages/nexbit_login_page.dart';
import '../../../auth/presentation/pages/nexbit_register_page.dart';
import '../../../futures/presentation/pages/nexbit_futures_page.dart';
import '../../../landing/presentation/widgets/max_width_box.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_navbar.dart';
import '../../../market/presentation/pages/nexbit_market_page.dart';
import '../../../market/presentation/pages/nexbit_price_page.dart';
import '../../../staking/presentation/pages/nexbit_staking_landing_page.dart';
import '../../domain/models/blog_post.dart';
import '../widgets/blog_cards.dart';
import 'nexbit_blog_detail_page.dart';

/// "Blog" — the news/analysis/guide hub reached from the navbar's "Blog"
/// link: two featured hero posts flanking a headline list (always the
/// same editorial picks, same convention as the Market page's sidebar
/// staying constant while only its main table is filterable), then a
/// category-filterable grid of the rest, with two cards cross-promoting
/// Nexbit's own Staking/Futures pages instead of an unrelated partner ad.
class NexbitBlogPage extends StatefulWidget {
  const NexbitBlogPage({super.key});

  @override
  State<NexbitBlogPage> createState() => _NexbitBlogPageState();
}

class _NexbitBlogPageState extends State<NexbitBlogPage> {
  BlogCategory? _filter;
  String _search = '';

  void _openPost(BlogPost post) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => NexbitBlogDetailPage(post: post)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        final posts = buildBlogPosts();
        final hero1 = posts[0];
        final headlines = posts.sublist(1, 6);
        final hero2 = posts[6];
        final rest = posts.sublist(7);

        final filtered = rest.where((p) {
          if (_filter != null && p.category != _filter) return false;
          final term = _search.trim().toLowerCase();
          if (term.isEmpty) return true;
          return p.title.toLowerCase().contains(term);
        }).toList();

        return Scaffold(
          backgroundColor: NexbitColors.bg,
          body: Stack(
            children: [
              const Positioned.fill(child: NetworkBackground()),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < kNexbitMobileBreakpoint;
                    final wide = constraints.maxWidth >= 1000;
                    return Column(
                      children: [
                        NexbitNavbar(
                          isMobile: isMobile,
                          activeId: 'blog',
                          onLogoTap: () => Navigator.of(context).popUntil((route) => route.isFirst),
                          onHargaTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitPricePage())),
                          onMarketTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitMarketPage())),
                          onStakingTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitStakingLandingPage())),
                          onFuturesTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitFuturesPage())),
                          onLoginTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitLoginPage())),
                          onRegisterTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitRegisterPage())),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 20 : 32, vertical: 28),
                            child: MaxWidthBox(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(S.blogHeading, style: NexbitText.display(fontSize: isMobile ? 26 : 32)),
                                  const SizedBox(height: 8),
                                  Text(S.blogSubtitle, style: NexbitText.body(fontSize: 14, height: 1.5)),
                                  const SizedBox(height: 28),
                                  _featuredSection(wide, hero1, headlines, hero2),
                                  const SizedBox(height: 36),
                                  _moreArticlesHeader(isMobile),
                                  const SizedBox(height: 16),
                                  filtered.isEmpty
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 24),
                                          child: Text(S.blogNoMatchingPosts, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                        )
                                      : _grid(constraints.maxWidth, filtered),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _featuredSection(bool wide, BlogPost hero1, List<BlogPost> headlines, BlogPost hero2) {
    final headlineColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < headlines.length; i++) ...[
          BlogHeadlineItem(post: headlines[i], onTap: () => _openPost(headlines[i])),
          if (i != headlines.length - 1) const Divider(color: NexbitColors.lineSoft, height: 1),
        ],
      ],
    );

    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlogHeroCard(post: hero1, onTap: () => _openPost(hero1)),
          const SizedBox(height: 20),
          headlineColumn,
          const SizedBox(height: 20),
          BlogHeroCard(post: hero2, onTap: () => _openPost(hero2)),
        ],
      );
    }

    // Deliberately a plain Row (not IntrinsicHeight-wrapped) — the three
    // columns don't need to match heights, and this app has repeatedly
    // hit the "unbounded height inside IntrinsicHeight" release-web crash
    // when that wrapper wasn't actually needed.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: BlogHeroCard(post: hero1, onTap: () => _openPost(hero1))),
        const SizedBox(width: 28),
        Expanded(flex: 4, child: headlineColumn),
        const SizedBox(width: 28),
        Expanded(flex: 5, child: BlogHeroCard(post: hero2, onTap: () => _openPost(hero2))),
      ],
    );
  }

  Widget _moreArticlesHeader(bool isMobile) {
    final tabs = <(BlogCategory?, String)>[
      (null, S.blogTabAll),
      (BlogCategory.bitcoin, BlogCategory.bitcoin.label),
      (BlogCategory.blockchain, BlogCategory.blockchain.label),
      (BlogCategory.market, BlogCategory.market.label),
      (BlogCategory.guide, BlogCategory.guide.label),
    ];
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(S.blogMoreArticles, style: NexbitText.body(fontSize: 18, weight: FontWeight.w700, color: NexbitColors.text)),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tab in tabs) _CategoryTab(label: tab.$2, active: _filter == tab.$1, onTap: () => setState(() => _filter = tab.$1)),
          ],
        ),
        SizedBox(
          width: isMobile ? double.infinity : 240,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: NexbitColors.surface2,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: NexbitColors.line),
            ),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: NexbitText.body(fontSize: 13, color: NexbitColors.text),
              decoration: InputDecoration(
                hintText: S.blogSearchHint,
                hintStyle: NexbitText.body(fontSize: 13, color: NexbitColors.muted),
                prefixIcon: const Icon(Icons.search, size: 17, color: NexbitColors.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _grid(double maxWidth, List<BlogPost> filtered) {
    final columns = maxWidth >= 1000 ? 4 : (maxWidth >= 680 ? 3 : (maxWidth >= 420 ? 2 : 1));
    const spacing = 16.0;
    final cardWidth = (maxWidth - spacing * (columns - 1)) / columns;

    // Two internal cross-promo cards slotted in among the articles —
    // only when there's room for the full grid, so a narrow filtered
    // result (e.g. just 1-2 posts) doesn't get padded out with unrelated
    // promo filler.
    final tiles = <Widget>[
      if (_filter == null && _search.isEmpty)
        BlogPromoCard(
          icon: Icons.savings_outlined,
          color: NexbitColors.accent,
          title: S.blogPromoStakingTitle,
          description: S.blogPromoStakingDesc,
          cta: S.blogPromoStakingCta,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitStakingLandingPage())),
        ),
      for (final post in filtered) BlogGridCard(post: post, onTap: () => _openPost(post)),
      if (_filter == null && _search.isEmpty)
        BlogPromoCard(
          icon: Icons.bolt_outlined,
          color: NexbitColors.accent2,
          title: S.blogPromoFuturesTitle,
          description: S.blogPromoFuturesDesc,
          cta: S.blogPromoFuturesCta,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NexbitFuturesPage())),
        ),
    ];

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [for (final tile in tiles) SizedBox(width: cardWidth, child: tile)],
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
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? NexbitColors.accent : Colors.transparent,
          border: Border.all(color: active ? Colors.transparent : NexbitColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: NexbitText.body(fontSize: 12, weight: FontWeight.w600, color: active ? const Color(0xFF04120E) : NexbitColors.muted),
        ),
      ),
    );
  }
}
