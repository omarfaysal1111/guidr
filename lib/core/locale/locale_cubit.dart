import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../storage/local_storage.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class LocaleState {
  final Locale locale;
  final String units; // 'metric' | 'imperial'

  const LocaleState({required this.locale, required this.units});

  LocaleState copyWith({Locale? locale, String? units}) {
    return LocaleState(
      locale: locale ?? this.locale,
      units: units ?? this.units,
    );
  }

  bool get isArabic => locale.languageCode == 'ar';
  bool get isMetric => units == 'metric';
}

// ─── Cubit ────────────────────────────────────────────────────────────────────

class LocaleCubit extends Cubit<LocaleState> {
  final LocalStorage _localStorage;

  static const _localeKey = 'app_locale';
  static const _unitsKey = 'app_units';

  LocaleCubit(this._localStorage)
      : super(const LocaleState(locale: Locale('en'), units: 'metric'));

  void loadSavedPreferences() {
    final savedLocale = _localStorage.getString(_localeKey);
    final savedUnits = _localStorage.getString(_unitsKey);
    emit(LocaleState(
      locale: Locale(savedLocale ?? 'en'),
      units: savedUnits ?? 'metric',
    ));
  }

  Future<void> setLocale(Locale locale) async {
    await _localStorage.saveString(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  Future<void> setUnits(String units) async {
    await _localStorage.saveString(_unitsKey, units);
    emit(state.copyWith(units: units));
  }
}
