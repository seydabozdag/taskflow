import 'package:flutter/material.dart';
import 'app_color_tokens.dart';

/// `context.colors.surface` gibi kısa, type-safe erişim sağlar.
/// `Theme.of(context).extension<AppColorTokens>()!` tekrarını her widget'ta
/// yazmamak için tek satırlık bir extension.
extension ThemeContextX on BuildContext {
  AppColorTokens get colors => Theme.of(this).extension<AppColorTokens>()!;
}
