import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../blocs/booking_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.profile),
        backgroundColor: AppColors.background,
        actions: [
          // Language toggle in app bar
          GestureDetector(
            onTap: () {
              final newLocale = locale == 'en' ? 'de' : 'en';
              context.read<LocaleBloc>().add(ChangeLocale(newLocale));
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(locale == 'en' ? '🇩🇪' : '🇬🇧',
                      style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    locale == 'en' ? 'DE' : 'EN',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user =
              authState is AuthAuthenticated ? authState.user : null;

          return ListView(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            children: [
              // ── Avatar & Name ──────────────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.primaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.name.isNotEmpty == true
                              ? user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? 'Guest',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // ── Stats row ──────────────────────────────────────────────
              BlocBuilder<BookingBloc, BookingState>(
                builder: (context, bookingState) {
                  int ticketCount = 0;
                  if (bookingState is MyBookingsLoaded) {
                    ticketCount = bookingState.bookings.length;
                  }
                  return _StatsRow(
                      ticketCount: ticketCount, locale: locale);
                },
              ),
              const SizedBox(height: 24),

              // ── Account section ────────────────────────────────────────
              _SectionHeader(
                  title: locale == 'de' ? 'Konto' : 'Account'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.person_outline_rounded,
                title: l10n.editProfile,
                onTap: () => _showComingSoon(context, locale),
              ),
              _ProfileTile(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                onTap: () => _showComingSoon(context, locale),
                trailing: Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: AppColors.primary,
                ),
              ),

              // ── Language section ───────────────────────────────────────
              const SizedBox(height: 16),
              _SectionHeader(
                  title: locale == 'de' ? 'Sprache' : 'Language'),
              const SizedBox(height: 8),
              _LanguageTile(locale: locale),

              // ── App section ────────────────────────────────────────────
              const SizedBox(height: 16),
              _SectionHeader(title: locale == 'de' ? 'App' : 'App'),
              const SizedBox(height: 8),
              _ProfileTile(
                icon: Icons.settings_outlined,
                title: l10n.settings,
                onTap: () => _showComingSoon(context, locale),
              ),
              _ProfileTile(
                icon: Icons.info_outline_rounded,
                title: l10n.aboutApp,
                subtitle: '${l10n.version}  •  ${AppConstants.ownerName}',
                onTap: () => _showAboutDialog(context, l10n, locale),
              ),
              _ProfileTile(
                icon: Icons.star_outline_rounded,
                title: locale == 'de' ? 'App bewerten' : 'Rate the App',
                onTap: () => _showComingSoon(context, locale),
              ),

              // ── Logout ─────────────────────────────────────────────────
              const SizedBox(height: 8),
              const Divider(color: AppColors.cardBorder),
              _ProfileTile(
                icon: Icons.logout_rounded,
                title: l10n.logout,
                isDestructive: true,
                onTap: () async {
                  final confirmed = await _showLogoutConfirm(
                      context, l10n, locale);
                  if (confirmed == true && context.mounted) {
                    context.read<AuthBloc>().add(LogoutUser());
                    Navigator.pushReplacementNamed(
                        context, AppConstants.routeLogin);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Footer
              Center(
                child: Text(
                  l10n.madeBy,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }

  void _showComingSoon(BuildContext context, String locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(locale == 'de'
            ? 'Demnächst verfügbar'
            : 'Coming soon!'),
      ),
    );
  }

  void _showAboutDialog(
      BuildContext context, AppLocalizations l10n, String locale) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.movie_filter_rounded,
            color: Colors.white, size: 28),
      ),
      children: [
        Text(
          locale == 'de'
              ? 'Entwickelt von ${AppConstants.ownerName}.\n\nEine Flutter-App zur Buchung von Kinokarten für deutsche und internationale Filme.'
              : 'Developed by ${AppConstants.ownerName}.\n\nA Flutter cinema ticket booking app for German and international films.',
        ),
      ],
    );
  }

  Future<bool?> _showLogoutConfirm(
      BuildContext context, AppLocalizations l10n, String locale) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL)),
        title: Text(l10n.logout,
            style: const TextStyle(
                color: AppColors.textPrimary, fontFamily: 'Poppins')),
        content: Text(
          locale == 'de'
              ? 'Möchtest du dich wirklich abmelden?'
              : 'Are you sure you want to log out?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              locale == 'de' ? 'Abbrechen' : 'Cancel',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logout,
                style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int ticketCount;
  final String locale;

  const _StatsRow({required this.ticketCount, required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            value: '$ticketCount',
            label: locale == 'de' ? 'Tickets' : 'Tickets',
            icon: Icons.confirmation_number_outlined,
          ),
          Container(width: 0.5, height: 40, color: AppColors.cardBorder),
          _StatItem(
            value: '🇩🇪🌍',
            label: locale == 'de' ? 'Sprachen' : 'Languages',
            icon: null,
          ),
          Container(width: 0.5, height: 40, color: AppColors.cardBorder),
          _StatItem(
            value: '4',
            label: locale == 'de' ? 'Kinos' : 'Cinemas',
            icon: Icons.theater_comedy_outlined,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData? icon;

  const _StatItem(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.error.withOpacity(0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: color, size: 19),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontFamily: 'Poppins'))
            : null,
        trailing: trailing ??
            Icon(Icons.chevron_right_rounded,
                color: AppColors.textMuted, size: 20),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM)),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String locale;
  const _LanguageTile({required this.locale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.language_rounded,
                  color: AppColors.textSecondary, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                locale == 'de' ? 'Sprache' : 'Language',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Toggle pills
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _LangPill(
                    label: '🇬🇧 EN',
                    isActive: locale == 'en',
                    onTap: () => context
                        .read<LocaleBloc>()
                        .add(const ChangeLocale('en')),
                  ),
                  _LangPill(
                    label: '🇩🇪 DE',
                    isActive: locale == 'de',
                    onTap: () => context
                        .read<LocaleBloc>()
                        .add(const ChangeLocale('de')),
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

class _LangPill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _LangPill(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
