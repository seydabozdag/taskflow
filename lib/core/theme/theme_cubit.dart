import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

/// Açık/koyu tema tercihini tutan ve Hive ile kalıcı hale getiren Cubit.
///
/// Cubit (Bloc'un event'siz, daha sade kuzeni) burada yeterli — tema
/// değişikliği tek bir aksiyon (`toggle`), event/state ayrımına gerek yok.
/// Bu, "gereksiz büyük mimari dönüşüm yapma" prensibine uygun en hafif çözüm.
class ThemeCubit extends Cubit<ThemeMode> {
  static const _storageKey = 'themeMode';

  final Box<String> _settingsBox;

  ThemeCubit(this._settingsBox) : super(_readPersisted(_settingsBox));

  static ThemeMode _readPersisted(Box<String> box) {
    return switch (box.get(_storageKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  void toggle() {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(next);
    _settingsBox.put(_storageKey, next == ThemeMode.dark ? 'dark' : 'light');
  }
}
