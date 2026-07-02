/// Responsive layout kararlarının dayandığı tek kaynak.
///
/// Önceden `AppSizes.mobileBreakpoint` tek başınaydı; tablet ara katmanı
/// eklenince bunu ayrı bir dosyaya çıkarmak, "responsive mantığı nerede?"
/// sorusuna tek bir cevap vermeyi sağlıyor (Single Source of Truth).
abstract class AppBreakpoints {
  /// Bu genişliğin altı: tek sütun + sekme/swipe (telefon).
  static const double mobile = 700;

  /// Bu genişliğin altı ama mobile üstü: dar masaüstü/tablet — sütunlar
  /// görünür ama spacing daha sıkı tutulur.
  static const double tablet = 1100;
}
