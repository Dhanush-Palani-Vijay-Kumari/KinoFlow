import 'package:flutter/material.dart';
import '../../domain/entities/movie.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class FeaturedMovieBanner extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final String locale;

  const FeaturedMovieBanner({
    super.key,
    required this.movie,
    required this.onTap,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 260,
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Backdrop
              Image.network(
                movie.backdropUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.cardBackground,
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return Container(color: AppColors.cardBackground);
                },
              ),
              // Gradient overlay
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.heroGradient,
                    stops: [0.2, 0.6, 1.0],
                  ),
                ),
              ),
              // Content
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Genre chips
                    Wrap(
                      spacing: 6,
                      children: movie.genres.take(2).map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            g,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      movie.localizedTitle(locale),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Rating + Duration + Language
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time_rounded,
                            color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${movie.durationMinutes} min',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (movie.isGerman)
                          const Text('🇩🇪', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
              // Book button
              Positioned(
                right: 16,
                top: 16,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
