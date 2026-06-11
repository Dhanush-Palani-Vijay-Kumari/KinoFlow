import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final String locale;
  final bool isLarge;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
    required this.locale,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = isLarge ? 160.0 : 130.0;
    final height = width * 1.5;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Stack(
                children: [
                  Image.network(
                    movie.posterUrl,
                    width: width,
                    height: height,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: width,
                      height: height,
                      color: AppColors.cardBackground,
                      child: const Icon(Icons.movie_outlined,
                          color: AppColors.textMuted, size: 40),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: width,
                        height: height,
                        color: AppColors.cardBackground,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                  ),
                  // Rating badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: AppColors.gold, size: 12),
                          const SizedBox(width: 2),
                          Text(
                            movie.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // German flag badge
                  if (movie.isGerman)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('🇩🇪', style: TextStyle(fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              movie.localizedTitle(locale),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // Duration
            Text(
              '${movie.durationMinutes} min',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
