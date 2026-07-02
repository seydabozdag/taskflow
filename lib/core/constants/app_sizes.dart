abstract class AppSizes {
  // --- Spacing (4px grid) ---
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // --- Corner Radius — tutarlı bir radius skalası kullanmak,
  // her widget'ta farklı bir değer (4, 6, 10, 12...) icat etmeyi önler.
  static const double radiusSm = 6.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusPill = 999.0;

  // --- Kanban Layout ---
  static const double columnWidth = 320.0;
  static const double columnGap = lg;
  static const double cardBorderRadius = radiusMd;

  /// Geniş masaüstü/4K ekranlarda board'un aşırı yayılmasını önler.
  static const double maxContentWidth = 1440.0;

  // --- Erişilebilirlik ---
  /// Apple HIG / Material erişilebilirlik kılavuzlarının önerdiği
  /// minimum dokunma hedefi. Küçük ikon butonları bile bu alanı kaplamalı.
  static const double minTouchTarget = 44.0;
}
