import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class GenreChip extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback? onTap;

  const GenreChip({
    super.key,
    required this.genre,
    this.isSelected = false,
    this.onTap,
  });

  // Map genres to colours for visual distinction
  static Color _colorForGenre(String genre) {
    final g = genre.toLowerCase();
    if (g.contains('action') || g.contains('thriller')) return const Color(0xFFEF4444);
    if (g.contains('comedy') || g.contains('komödie')) return const Color(0xFFF59E0B);
    if (g.contains('drama')) return const Color(0xFF6366F1);
    if (g.contains('sci-fi') || g.contains('fantasy')) return const Color(0xFF0EA5E9);
    if (g.contains('horror')) return const Color(0xFF8B5CF6);
    if (g.contains('romance') || g.contains('liebes')) return const Color(0xFFEC4899);
    if (g.contains('war') || g.contains('krieg') || g.contains('history') || g.contains('geschichte')) return const Color(0xFF78716C);
    if (g.contains('crime') || g.contains('krimi')) return const Color(0xFF374151);
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForGenre(genre);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(isSelected ? 1.0 : 0.4),
            width: 0.5,
          ),
        ),
        child: Text(
          genre,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
