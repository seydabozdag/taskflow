import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';
import '../constants/app_sizes.dart';

/// Ekran boyutuna göre layout kararları vermek için tek yardımcı sınıf.
///
/// Tüm breakpoint mantığı burada toplanır; widget'lar `MediaQuery` ile
/// doğrudan ilgilenmez, sadece bu sınıfın anlamlı isimli metodlarını
/// çağırır (`isMobile`, `isTablet`...). Bu, "700px ne demek?" sorusunu
/// widget kodundan tamamen kaldırır.
abstract class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppBreakpoints.mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppBreakpoints.mobile && width < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppBreakpoints.tablet;

  /// Board'un yatay kenar boşluğu — dar ekranda sıkı, geniş ekranda ferah.
  static double boardPadding(BuildContext context) {
    if (isMobile(context)) return AppSizes.md;
    if (isTablet(context)) return AppSizes.lg;
    return AppSizes.xl;
  }

  /// Sütunlar arası boşluk — mobilde tek sütun olduğu için kullanılmaz,
  /// masaüstünde ekran büyüdükçe biraz daha ferah hissettirir.
  static double columnGap(BuildContext context) =>
      isTablet(context) ? AppSizes.md : AppSizes.columnGap;
}
