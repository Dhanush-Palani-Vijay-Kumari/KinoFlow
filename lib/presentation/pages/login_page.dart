import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/locale_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            LoginUser(email: _emailCtrl.text.trim(), password: _passwordCtrl.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleBloc>().state.locale.languageCode;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, AppConstants.routeHome);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),
                    // Logo
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.movie_filter_rounded,
                              color: Colors.white, size: 26),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'KinoFlow',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Text(l10n.welcome,
                        style: Theme.of(context).textTheme.displayMedium),
                    const SizedBox(height: 8),
                    Text(l10n.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 40),

                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l10n.email,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppColors.textSecondary),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your email';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: l10n.password,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppColors.textSecondary),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter your password';
                        if (v.length < 6) return 'Min 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Login button
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _submit,
                      child: state is AuthLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.login),
                    ),
                    const SizedBox(height: 16),

                    // Register link
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                            context, AppConstants.routeRegister),
                        child: Text(
                          l10n.dontHaveAccount,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Language toggle
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          final newLocale =
                              locale == 'en' ? 'de' : 'en';
                          context
                              .read<LocaleBloc>()
                              .add(ChangeLocale(newLocale));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(20),
                            border:
                                Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(locale == 'en' ? '🇩🇪' : '🇬🇧',
                                  style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Text(
                                l10n.languageToggle,
                                style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    fontFamily: 'Poppins'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
