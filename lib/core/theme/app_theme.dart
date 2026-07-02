import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import 'app_color_tokens.dart';

abstract class AppTheme {
  static final ThemeData light = _build(Brightness.light, AppColorTokens.light);
  static final ThemeData dark = _build(Brightness.dark, AppColorTokens.dark);

  /// Light ve dark tema, tek bir fabrika fonksiyonundan üretilir — sadece
  /// `tokens` değişir. Bu, iki temanın yapısal olarak senkron kalmasını
  /// garanti eder (birini güncelleyip diğerini unutma riski olmaz).
  static ThemeData _build(Brightness brightness, AppColorTokens tokens) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: tokens.primary,
      onPrimary: tokens.textOnPrimary,
      secondary: AppColors.primaryLight,
      onSecondary: tokens.textOnPrimary,
      error: AppColors.priorityCritical,
      onError: tokens.textOnPrimary,
      surface: tokens.surface,
      onSurface: tokens.textPrimary,
    );

    final textTheme = TextTheme(
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
        height: 1.35,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
        height: 1.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        color: tokens.textPrimary,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        color: tokens.textSecondary,
        height: 1.45,
      ),
      bodySmall: TextStyle(
        fontSize: 11.5,
        color: tokens.textTertiary,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: tokens.textPrimary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: tokens.background,
      colorScheme: colorScheme,
      textTheme: textTheme,

      cardTheme: CardThemeData(
        color: tokens.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: BorderSide(color: tokens.border),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: tokens.surface,
        showDragHandle: true,
        dragHandleColor: tokens.borderStrong,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLg)),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: tokens.surfaceMuted,
        side: BorderSide(color: tokens.border),
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: tokens.textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusPill)),
      ),

      dividerTheme: DividerThemeData(color: tokens.border, thickness: 1, space: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: tokens.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: BorderSide(color: tokens.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.priorityCritical),
        ),
        labelStyle: TextStyle(color: tokens.textSecondary),
        hintStyle: TextStyle(color: tokens.textTertiary),
        errorStyle: const TextStyle(color: AppColors.priorityCritical, fontSize: 12),
      ),

      iconTheme: IconThemeData(color: tokens.textSecondary),

      popupMenuTheme: PopupMenuThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          side: BorderSide(color: tokens.border),
        ),
        textStyle: textTheme.bodyLarge,
      ),

      // Tema değiştirmek için custom token'larımızı (AppColorTokens) buraya
      // ekliyoruz — widget'lar `context.colors` ile bunlara erişir.
      extensions: [tokens],
    );
  }
}
