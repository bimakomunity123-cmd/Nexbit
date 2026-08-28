import 'package:flutter/material.dart';
import '../../../../core/i18n/app_locale.dart';
import '../../../../core/i18n/strings.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/max_width_box.dart';
import '../../../landing/presentation/widgets/network_background.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/blog_post.dart';
import '../widgets/blog_cards.dart';

/// A single blog post's full page — a simple "← Title" drill-down (same
/// pattern as the account-menu pages) rather than the full navbar, since
/// this is reached by tapping into an article, not a primary nav
/// destination. The body is generic, category-level commentary (see
/// [categoryBody]) rather than a unique hand-written article per post.
class NexbitBlogDetailPage extends StatelessWidget {
  final BlogPost post;
  const NexbitBlogDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        final related = buildBlogPosts().where((p) => p.category == post.category && p.id != post.id).take(3).toList();

        return Scaffold(
          backgroundColor: NexbitColors.bg,
          body: Stack(
            children: [
              const Positioned.fill(child: NetworkBackground()),
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: NexbitColors.line))),
                      child: Row(
                        children: [
                          Hoverable(
                            hoverScale: 1.06,
                            builder: (context, hovered) => InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: hovered ? NexbitColors.surface2 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.arrow_back, size: 20, color: NexbitColors.muted),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              S.blogBackToList,
                              style: NexbitText.body(fontSize: 14, weight: FontWeight.w600, color: NexbitColors.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 780),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                BlogCategoryBadge(category: post.category),
                                const SizedBox(height: 14),
                                Text(post.title, style: NexbitText.display(fontSize: 28, height: 1.25)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 13, color: NexbitColors.muted2),
                                    const SizedBox(width: 5),
                                    Text(post.timeAgo, style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.chat_bubble_outline, size: 13, color: NexbitColors.muted2),
                                    const SizedBox(width: 5),
                                    Text('${post.comments}', style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                    const SizedBox(width: 16),
                                    Icon(Icons.visibility_outlined, size: 13, color: NexbitColors.muted2),
                                    const SizedBox(width: 5),
                                    Text('${post.views}', style: NexbitText.body(fontSize: 12.5, color: NexbitColors.muted2)),
                                  ],
                                ),
                                const SizedBox(height: 22),
                                Container(
                                  height: 320,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [post.category.color.withOpacity(0.3), NexbitColors.surface2],
                                    ),
                                    border: Border.all(color: NexbitColors.line),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(post.category.icon, size: 110, color: post.category.color.withOpacity(0.85)),
                                ),
                                const SizedBox(height: 26),
                                for (final paragraph in categoryBody(post.category)) ...[
                                  Text(paragraph, style: NexbitText.body(fontSize: 14.5, height: 1.7, color: NexbitColors.text)),
                                  const SizedBox(height: 16),
                                ],
                                if (related.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Divider(color: NexbitColors.line),
                                  const SizedBox(height: 20),
                                  Text(S.blogRelatedHeading, style: NexbitText.body(fontSize: 17, weight: FontWeight.w700, color: NexbitColors.text)),
                                  const SizedBox(height: 16),
                                  MaxWidthBox(
                                    maxWidth: 780,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final columns = constraints.maxWidth >= 680 ? 3 : (constraints.maxWidth >= 420 ? 2 : 1);
                                        const spacing = 14.0;
                                        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                                        return Wrap(
                                          spacing: spacing,
                                          runSpacing: spacing,
                                          children: [
                                            for (final r in related)
                                              SizedBox(
                                                width: cardWidth,
                                                child: BlogGridCard(
                                                  post: r,
                                                  onTap: () => Navigator.of(context).pushReplacement(
                                                    MaterialPageRoute(builder: (_) => NexbitBlogDetailPage(post: r)),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
