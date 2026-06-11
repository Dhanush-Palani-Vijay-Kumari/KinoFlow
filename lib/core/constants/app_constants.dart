class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'KinoFlow';
  static const String appVersion = '1.0.0';
  static const String ownerName = 'Dhanush Palani Vijay Kumari';

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeHome = '/home';
  static const String routeMovieDetail = '/movie/:id';
  static const String routeSeatSelection = '/seats/:showtimeId';
  static const String routeBookingConfirmation = '/booking/confirm';
  static const String routeMyTickets = '/tickets';
  static const String routeProfile = '/profile';
  static const String routeSearch = '/search';

  // Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyLocale = 'locale';
  static const String keyOnboarded = 'onboarded';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';

  // Supported Locales
  static const String localeEn = 'en';
  static const String localeDe = 'de';

  // Movie Filters
  static const String filterAll = 'all';
  static const String filterGerman = 'german';
  static const String filterInternational = 'international';

  // Seat Layout
  static const int seatRows = 8;
  static const int seatsPerRow = 10;
  static const double ticketPriceBase = 12.50;
  static const double ticketPricePremium = 16.00;

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animMedium = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Padding
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 100.0;

  // Image Placeholder (using picsum for demo)
  static const String imagePlaceholderUrl = 'https://picsum.photos/300/450';
}
