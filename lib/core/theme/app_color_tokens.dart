import 'package:flutter/material.dart';

/// Temaya göre değişen renk token'ları.
///
/// `ThemeExtension` kullanmamızın nedeni: Flutter'ın `ThemeData`'sı sabit
/// bir `ColorScheme` sunar ama bizim ihtiyacımız olan "sütun yüzeyi",
/// "üçüncül metin", "yumuşak kenarlık" gibi tasarım token'ları onun
/// kapsamı dışında. ThemeExtension, bu özel token'ları `Theme.of(context)`
/// üzerinden type-safe şekilde taşımamızı sağlar — widget'lar
/// `AppColors.surface` gibi sabit bir renk yerine `context.colors.surface`
/// çağırır ve tema değişince otomatik olarak doğru rengi alır.
@immutable
class AppColorTokens extends ThemeExtension<AppColorTokens> {
  final Color background;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textOnPrimary;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primarySubtle;

  const AppColorTokens({
    required this.background,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textOnPrimary,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primarySubtle,
  });

  /// Light tema — Tailwind gray-50/500/900 esintili nötr palet.
  static const light = AppColorTokens(
    background: Color(0xFFF8F9FB),
    backgroundEnd: Color(0xFFEEF1F6),
    surface: Color(0xFFFFFFFF),
    surfaceMuted: Color(0xFFF4F5F7),
    textPrimary: Color(0xFF101828),
    textSecondary: Color(0xFF667085),
    textTertiary: Color(0xFF98A2B3),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFE4E7EC),
    borderStrong: Color(0xFFD0D5DD),
    primary: Color(0xFF0052CC),
    primarySubtle: Color(0x140052CC),
  );

  /// Dark tema — düz siyah yerine mavi-gri tonlu yüzeyler (Linear/Notion
  /// dark mode esintili), tam kontrast yorgunluğunu azaltır.
  static const dark = AppColorTokens(
    background: Color(0xFF0B0F17),
    backgroundEnd: Color(0xFF11161F),
    surface: Color(0xFF161B26),
    surfaceMuted: Color(0xFF1E2430),
    textPrimary: Color(0xFFF2F4F7),
    textSecondary: Color(0xFF94A3B8),
    textTertiary: Color(0xFF64748B),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFF283041),
    borderStrong: Color(0xFF38465C),
    primary: Color(0xFF4C9AFF),
    primarySubtle: Color(0x294C9AFF),
  );

  @override
  AppColorTokens copyWith({
    Color? background,
    Color? backgroundEnd,
    Color? surface,
    Color? surfaceMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textOnPrimary,
    Color? border,
    Color? borderStrong,
    Color? primary,
    Color? primarySubtle,
  }) {
    return AppColorTokens(
      background: background ?? this.background,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      primary: primary ?? this.primary,
      primarySubtle: primarySubtle ?? this.primarySubtle,
    );
  }

  @override
  AppColorTokens lerp(ThemeExtension<AppColorTokens>? other, double t) {
    if (other is! AppColorTokens) return this;
    return AppColorTokens(
      background: Color.lerp(background, other.background, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primarySubtle: Color.lerp(primarySubtle, other.primarySubtle, t)!,
    );
  }
}
