import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingBar extends StatelessWidget {
  final double rating; // out of 10
  final double size;
  final bool showLabel;

  const RatingBar({
    super.key,
    required this.rating,
    this.size = 16,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final stars = (rating / 2).clamp(0.0, 5.0); // Convert 10-scale to 5 stars
    final fullStars = stars.floor();
    final hasHalf = (stars - fullStars) >= 0.5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          IconData icon;
          if (i < fullStars) {
            icon = Icons.star_rounded;
          } else if (i == fullStars && hasHalf) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_outline_rounded;
          }
          return Icon(icon, color: AppColors.gold, size: size);
        }),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: size * 0.75,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ],
    );
  }
}
