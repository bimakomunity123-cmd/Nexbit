import 'package:flutter/material.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';

/// The editorial sections a post can belong to — mirrors a typical
/// crypto-news site's nav (Bitcoin/Blockchain/Market/Guide) so the
/// category pills on the Blog page have real, distinct groups to filter.
enum BlogCategory { bitcoin, blockchain, market, guide }

extension BlogCategoryX on BlogCategory {
  String get label {
    switch (this) {
      case BlogCategory.bitcoin:
        return S.blogCategoryBitcoin;
      case BlogCategory.blockchain:
        return S.blogCategoryBlockchain;
      case BlogCategory.market:
        return S.blogCategoryMarket;
      case BlogCategory.guide:
        return S.blogCategoryGuide;
    }
  }

  Color get color {
    switch (this) {
      case BlogCategory.bitcoin:
        return const Color(0xFFF7931A); // Bitcoin orange
      case BlogCategory.blockchain:
        return NexbitColors.accent2; // indigo
      case BlogCategory.market:
        return NexbitColors.accent; // teal-mint
      case BlogCategory.guide:
        return const Color(0xFFE0B04C); // amber
    }
  }

  IconData get icon {
    switch (this) {
      case BlogCategory.bitcoin:
        return Icons.currency_bitcoin;
      case BlogCategory.blockchain:
        return Icons.hub_outlined;
      case BlogCategory.market:
        return Icons.query_stats;
      case BlogCategory.guide:
        return Icons.menu_book_outlined;
    }
  }
}

/// One mock blog post. There's no real CMS/backend behind this — content
/// is a fixed, hand-written, bilingual seed list (see [buildBlogPosts]),
/// same "deterministic mock data" convention as the rest of the app.
class BlogPost {
  final String id;
  final BlogCategory category;
  final String title;
  final String timeAgo;
  final int comments;
  final int views;

  const BlogPost({
    required this.id,
    required this.category,
    required this.title,
    required this.timeAgo,
    required this.comments,
    required this.views,
  });
}

/// Built inside `build()` (like the Market page's insight lists) so it
/// always reflects the current [appLocale] rather than being captured
/// once at import time.
List<BlogPost> buildBlogPosts() => [
      BlogPost(id: 'p1', category: BlogCategory.bitcoin, title: S.blogPost1, timeAgo: S.blogMonthsAgo(11), comments: 0, views: 369),
      BlogPost(id: 'p2', category: BlogCategory.bitcoin, title: S.blogPost2, timeAgo: S.blogMonthsAgo(11), comments: 0, views: 106),
      BlogPost(id: 'p3', category: BlogCategory.bitcoin, title: S.blogPost3, timeAgo: S.blogMonthsAgo(11), comments: 0, views: 154),
      BlogPost(id: 'p4', category: BlogCategory.bitcoin, title: S.blogPost4, timeAgo: S.blogMonthsAgo(10), comments: 0, views: 58),
      BlogPost(id: 'p5', category: BlogCategory.bitcoin, title: S.blogPost5, timeAgo: S.blogMonthsAgo(10), comments: 0, views: 149),
      BlogPost(id: 'p6', category: BlogCategory.blockchain, title: S.blogPost6, timeAgo: S.blogMonthsAgo(10), comments: 0, views: 213),
      BlogPost(id: 'p7', category: BlogCategory.market, title: S.blogPost7, timeAgo: S.blogMonthsAgo(9), comments: 2, views: 88),
      BlogPost(id: 'p8', category: BlogCategory.guide, title: S.blogPost8, timeAgo: S.blogMonthsAgo(9), comments: 1, views: 121),
      BlogPost(id: 'p9', category: BlogCategory.market, title: S.blogPost9, timeAgo: S.blogMonthsAgo(9), comments: 0, views: 97),
      BlogPost(id: 'p10', category: BlogCategory.guide, title: S.blogPost10, timeAgo: S.blogMonthsAgo(8), comments: 3, views: 176),
      BlogPost(id: 'p11', category: BlogCategory.blockchain, title: S.blogPost11, timeAgo: S.blogMonthsAgo(8), comments: 4, views: 264),
      BlogPost(id: 'p12', category: BlogCategory.market, title: S.blogPost12, timeAgo: S.blogMonthsAgo(8), comments: 0, views: 73),
    ];

/// Two generic paragraphs per category, reused by every post in that
/// category's detail page. There's no real article backend behind this
/// demo, so rather than hand-writing 12 unique full-length articles, the
/// body reads as plausible category commentary — honest about being a
/// mock while still giving the detail page something real to show.
List<String> categoryBody(BlogCategory category) {
  switch (category) {
    case BlogCategory.bitcoin:
      return [S.blogBodyBitcoin1, S.blogBodyBitcoin2, S.blogBodyBitcoin3];
    case BlogCategory.blockchain:
      return [S.blogBodyBlockchain1, S.blogBodyBlockchain2, S.blogBodyBlockchain3];
    case BlogCategory.market:
      return [S.blogBodyMarket1, S.blogBodyMarket2, S.blogBodyMarket3];
    case BlogCategory.guide:
      return [S.blogBodyGuide1, S.blogBodyGuide2, S.blogBodyGuide3];
  }
}
