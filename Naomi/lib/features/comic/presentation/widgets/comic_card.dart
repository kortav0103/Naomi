import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/comic.dart';

class ComicCard extends StatelessWidget {
  final Comic comic;
  final VoidCallback onTap;

  const ComicCard({
    super.key,
    required this.comic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: comic.coverUrl != null
                    ? CachedNetworkImage(
                        imageUrl: comic.coverUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, url) => Container(
                          color: AppColors.darkSurface,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.darkSurface,
                          child: const Icon(
                            Icons.broken_image_rounded,
                            color: AppColors.darkTextMuted,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.darkSurface,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.darkTextMuted,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            comic.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            comic.genres.isNotEmpty ? comic.genres.take(2).join(', ') : comic.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.darkTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
