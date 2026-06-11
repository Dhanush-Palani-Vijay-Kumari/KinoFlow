import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();
  @override
  List<Object?> get props => [];
}

class LoadLocale extends LocaleEvent {}

class ChangeLocale extends LocaleEvent {
  final String languageCode;
  const ChangeLocale(this.languageCode);
  @override
  List<Object?> get props => [languageCode];
}

// ─── States ───────────────────────────────────────────────────────────────────

class LocaleState extends Equatable {
  final Locale locale;
  const LocaleState(this.locale);
  @override
  List<Object?> get props => [locale];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc() : super(const LocaleState(Locale('en'))) {
    on<LoadLocale>(_onLoad);
    on<ChangeLocale>(_onChange);
  }

  Future<void> _onLoad(LoadLocale event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.keyLocale) ?? 'en';
    emit(LocaleState(Locale(code)));
  }

  Future<void> _onChange(ChangeLocale event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLocale, event.languageCode);
    emit(LocaleState(Locale(event.languageCode)));
  }
}
