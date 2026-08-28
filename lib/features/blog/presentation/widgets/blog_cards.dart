import 'package:flutter/material.dart';
import '../../../../core/theme/nexbit_theme.dart';
import '../../../landing/presentation/widgets/nexbit_buttons.dart';
import '../../domain/models/blog_post.dart';

/// Colored category pill shown on every post banner/card — label + color
/// come from [BlogCategoryX] so every card stays visually consistent.
class BlogCategoryBadge extends StatelessWidget {
  final BlogCategory category;
  const BlogCategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: category.color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category.label,
        style: NexbitText.body(fontSize: 10.5, weight: FontWeight.w700, color: const Color(0xFF04120E)),
      ),
    );
  }
}

/// A gradient placeholder "banner" standing in for a real photo — this
/// app never uses stock photography anywhere, so every post gets an
/// abstract gradient tinted by its category plus a big centered icon,
/// consistent with how the rest of Nexbit represents assets/brands.
class _BlogBanner extends StatelessWidget {
  final BlogCategory category;
  final double height;
  final double iconSize;
  const _BlogBanner({required this.category, required this.height, this.iconSize = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [category.color.withOpacity(0.28), NexbitColors.surface2],
        ),
        border: Border.all(color: NexbitColors.line),
      ),
      alignment: Alignment.center,
      child: Icon(category.icon, size: iconSize, color: category.color.withOpacity(0.85)),
    );
  }
}

/// Small "time · comments · views" meta row shared by every card size.
class _MetaRow extends StatelessWidget {
  final String timeAgo;
  final int comments;
  final int views;
  const _MetaRow({required this.timeAgo, required this.comments, required this.views});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaItem(Icons.access_time, timeAgo),
        _metaItem(Icons.chat_bubble_outline, '$comments'),
        _metaItem(Icons.visibility_outlined, '$views'),
      ],
    );
  }

  Widget _metaItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.5, color: NexbitColors.muted2),
        const SizedBox(width: 4),
        Text(label, style: NexbitText.body(fontSize: 11.5, color: NexbitColors.muted2)),
      ],
    );
  }
}

/// The big featured card — used for the two "hero" slots at the top of
/// the Blog page.
class BlogHeroCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;
  const BlogHeroCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.01,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _BlogBanner(category: post.category, height: 210, iconSize: 72),
                Positioned(top: 12, left: 12, child: BlogCategoryBadge(category: post.category)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.title,
              style: NexbitText.body(fontSize: 17, weight: FontWeight.w700, color: hovered ? NexbitColors.accent : NexbitColors.text, height: 1.3),
            ),
            const SizedBox(height: 8),
            _MetaRow(timeAgo: post.timeAgo, comments: post.comments, views: post.views),
          ],
        ),
      ),
    );
  }
}

/// A compact text-only row — used for the headline list between the two
/// hero cards.
class BlogHeadlineItem extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;
  const BlogHeadlineItem({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: NexbitText.body(fontSize: 13.5, weight: FontWeight.w600, color: hovered ? NexbitColors.accent : NexbitColors.text, height: 1.35),
              ),
              const SizedBox(height: 6),
              _MetaRow(timeAgo: post.timeAgo, comments: post.comments, views: post.views),
            ],
          ),
        ),
      ),
    );
  }
}

/// A medium card — used in the "Artikel Lainnya" grid below the fold.
class BlogGridCard extends StatelessWidget {
  final BlogPost post;
  final VoidCallback onTap;
  const BlogGridCard({super.key, required this.post, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.02,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: NexbitColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hovered ? NexbitColors.accent : NexbitColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  _BlogBanner(category: post.category, height: 120, iconSize: 40),
                  Positioned(top: 8, left: 8, child: BlogCategoryBadge(category: post.category)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: NexbitText.body(fontSize: 13, weight: FontWeight.w700, color: NexbitColors.text, height: 1.3),
              ),
              const SizedBox(height: 8),
              _MetaRow(timeAgo: post.timeAgo, comments: post.comments, views: post.views),
            ],
          ),
        ),
      ),
    );
  }
}

/// An internal cross-promo card slotted into the "Artikel Lainnya" grid —
/// Mercury's reference design uses this slot for partner-exchange ads,
/// but Nexbit is a single product, so it points at Nexbit's own
/// Staking/Futures pages instead of an unrelated third party.
class BlogPromoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;
  final String cta;
  final VoidCallback onTap;
  const BlogPromoCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Hoverable(
      hoverScale: 1.02,
      builder: (context, hovered) => InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.16), NexbitColors.surface2]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: hovered ? color : NexbitColors.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color.withOpacity(0.18), shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: NexbitText.body(fontSize: 14, weight: FontWeight.w700, color: NexbitColors.text)),
              const SizedBox(height: 6),
              Text(description, style: NexbitText.body(fontSize: 12, color: NexbitColors.muted, height: 1.4)),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cta, style: NexbitText.body(fontSize: 12.5, weight: FontWeight.w700, color: color)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14, color: color),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
