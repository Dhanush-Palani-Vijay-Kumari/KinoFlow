import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../blocs/locale_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      emoji: '🎬',
      titleEn: 'Welcome to KinoFlow',
      titleDe: 'Willkommen bei KinoFlow',
      subtitleEn: 'Discover German & international films playing near you.',
      subtitleDe: 'Entdecke deutsche und internationale Filme in deiner Nähe.',
      color: Color(0xFFE50914),
    ),
    _OnboardingData(
      emoji: '🎟️',
      titleEn: 'Book in Seconds',
      titleDe: 'In Sekunden buchen',
      subtitleEn: 'Choose your showtime, pick your seats, and confirm instantly.',
      subtitleDe: 'Vorstellung wählen, Plätze aussuchen, sofort bestätigen.',
      color: Color(0xFF7C3AED),
    ),
    _OnboardingData(
      emoji: '🌐',
      titleEn: 'Deutsch & English',
      titleDe: 'Deutsch & English',
      subtitleEn: 'Switch between English and German at any time — your choice.',
      subtitleDe: 'Wechsle jederzeit zwischen Deutsch und Englisch.',
      color: Color(0xFF0EA5E9),
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboarded, true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, AppConstants.routeLogin);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    locale == 'de' ? 'Überspringen' : 'Skip',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return _OnboardingSlide(
                    data: page,
                    locale: locale,
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingL,
                0,
                AppConstants.paddingL,
                AppConstants.paddingL,
              ),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.cardBorder,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _pageController.nextPage(
                          duration: AppConstants.animMedium,
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      isLast
                          ? (locale == 'de' ? 'Loslegen' : 'Get Started')
                          : (locale == 'de' ? 'Weiter' : 'Next'),
                    ),
                  ),

                  // Language switcher
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      final newLocale = locale == 'en' ? 'de' : 'en';
                      context.read<LocaleBloc>().add(ChangeLocale(newLocale));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          locale == 'en' ? '🇩🇪' : '🇬🇧',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          locale == 'en' ? 'Auf Deutsch wechseln' : 'Switch to English',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final String locale;

  const _OnboardingSlide({required this.data, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji circle
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: data.color.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Text(data.emoji, style: const TextStyle(fontSize: 64)),
            ),
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            locale == 'de' ? data.titleDe : data.titleEn,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            locale == 'de' ? data.subtitleDe : data.subtitleEn,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final String emoji;
  final String titleEn;
  final String titleDe;
  final String subtitleEn;
  final String subtitleDe;
  final Color color;

  const _OnboardingData({
    required this.emoji,
    required this.titleEn,
    required this.titleDe,
    required this.subtitleEn,
    required this.subtitleDe,
    required this.color,
  });
}
