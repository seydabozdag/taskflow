import 'package:flutter/material.dart';

/// Gölge token'ları — "elevation" kavramını sabit bir BoxShadow listesi
/// seti üzerinden tutarlı hale getirir. Her widget kendi gölgesini icat
/// etmek yerine bu üç seviyeden birini kullanır.
abstract class AppShadows {
  /// En hafif gölge — sütun yüzeyleri gibi büyük, sakin alanlar için.
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A101828), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// Orta gölge — görev kartlarının varsayılan (hover öncesi) durumu.
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0F101828), blurRadius: 6, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x08101828), blurRadius: 1, offset: Offset(0, 1)),
  ];

  /// Belirgin gölge — hover'da yükselen kart veya sürüklenen kartın önizlemesi.
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1A101828), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0F101828), blurRadius: 4, offset: Offset(0, 2)),
  ];
}
