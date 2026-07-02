import 'package:flutter/material.dart';

/// Tema bağımsız "marka" renkleri.
///
/// Buradaki renkler bilinçli olarak hem light hem dark temada aynı kalır
/// (öncelik/durum renkleri gibi semantik anlamları var — kırmızı her zaman
/// "kritik" demektir). Arka plan/yüzey/metin gibi temaya göre DEĞİŞMESİ
/// gereken renkler için [AppColorTokens] kullanılır (bkz. core/theme).
abstract class AppColors {
  // --- Primary (Brand) ---
  static const Color primary = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFF4C9AFF);

  // --- Priority Colors — düşükten kritiğe artan görsel "alarm" şiddeti ---
  static const Color priorityLow = Color(0xFF36B37E);
  static const Color priorityMedium = Color(0xFFFFAB00);
  static const Color priorityHigh = Color(0xFFFF8B00);
  static const Color priorityCritical = Color(0xFFDE350B);

  // --- Status Accent Renkleri (sütun başlıkları, durum rozetleri) ---
  static const Color statusTodo = Color(0xFF6B778C);
  static const Color statusInProgress = Color(0xFF0065FF);
  static const Color statusDone = Color(0xFF36B37E);

  /// Görev etiketi (label color) seçimi için sabit palet — kullanıcı
  /// serbest renk seçmek yerine bu küratörlü listeden seçer, bu sayede
  /// hem light hem dark temada okunabilirlik garanti edilir.
  static const List<Color> labelPalette = [
    Color(0xFF6B778C), // Nötr gri
    Color(0xFF0052CC), // Mavi
    Color(0xFF00B8D9), // Camgöbeği
    Color(0xFF36B37E), // Yeşil
    Color(0xFFFFAB00), // Amber
    Color(0xFFFF8B00), // Turuncu
    Color(0xFFDE350B), // Kırmızı
    Color(0xFF6554C0), // Mor
    Color(0xFFFF5C8D), // Pembe
  ];
}
