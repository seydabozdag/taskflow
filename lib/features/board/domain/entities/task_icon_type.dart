/// Görevi kategorize eden ikon tipi.
///
/// Bilinçli olarak saf bir enum — hangi `IconData`/etiket ile gösterileceği
/// burada değil, presentation katmanındaki `TaskIconTypeUi` extension'ında
/// tanımlanır. Domain katmanı Flutter'dan habersiz kalır.
enum TaskIconType {
  general,
  shopping,
  study,
  work,
  home,
  health,
  fitness,
  pet,
  finance,
  travel,
  food,
}
