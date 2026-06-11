import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_options.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/booking_repository.dart';
import 'data/repositories/movie_repository.dart';
import 'data/services/movie_api_service.dart';
import 'presentation/blocs/auth_bloc.dart';
import 'presentation/blocs/booking_bloc.dart';
import 'presentation/blocs/locale_bloc.dart';
import 'presentation/blocs/movie_bloc.dart';
import 'presentation/pages/onboarding_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/movie_detail_page.dart';
import 'presentation/pages/my_tickets_page.dart';
import 'presentation/pages/profile_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/search_page.dart';
import 'presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialise Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const KinoFlowApp());
}

class KinoFlowApp extends StatelessWidget {
  const KinoFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Repositories — injected via MultiBlocProvider
    final movieRepo = MovieRepository();
    final bookingRepo = BookingRepository();
    final authRepo = AuthRepository();
    final movieApiService = MovieApiService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleBloc>(
          create: (_) => LocaleBloc()..add(LoadLocale()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepo),
        ),
        BlocProvider<MovieBloc>(
          create: (_) => MovieBloc(movieRepo),
        ),
        BlocProvider<BookingBloc>(
          create: (_) => BookingBloc(bookingRepo),
        ),
      ],
      child: BlocBuilder<LocaleBloc, LocaleState>(
        builder: (context, localeState) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            locale: localeState.locale,
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: AppConstants.routeSplash,
            onGenerateRoute: AppRouter.generate,
          );
        },
      ),
    );
  }
}

class AppRouter {
  static Route<dynamic> generate(RouteSettings settings) {
    final name = settings.name ?? '';

    if (name.startsWith('/movie/')) {
      final movieId = name.replaceFirst('/movie/', '');
      return _slide(MovieDetailPage(movieId: movieId), settings);
    }

    switch (name) {
      case AppConstants.routeSplash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );
      case AppConstants.routeOnboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingPage(),
          settings: settings,
        );
      case AppConstants.routeLogin:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppConstants.routeRegister:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case AppConstants.routeHome:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );
      case AppConstants.routeSearch:
        return _slide(const SearchPage(), settings);
      case AppConstants.routeMyTickets:
        return _slide(const MyTicketsPage(), settings);
      case AppConstants.routeProfile:
        return _slide(const ProfilePage(), settings);
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                '404 — Page not found\n$name',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white, fontFamily: 'Poppins'),
              ),
            ),
          ),
        );
    }
  }

  static Route<dynamic> _slide(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
            position: animation.drive(tween), child: child);
      },
      transitionDuration: AppConstants.animMedium,
    );
  }
}

/// Smart initial route based on onboarding + auth state
Future<String> determineInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  final onboarded = prefs.getBool(AppConstants.keyOnboarded) ?? false;
  final userId = prefs.getString(AppConstants.keyUserId);

  if (!onboarded) return AppConstants.routeOnboarding;
  if (userId != null) return AppConstants.routeHome;
  return AppConstants.routeLogin;
}
