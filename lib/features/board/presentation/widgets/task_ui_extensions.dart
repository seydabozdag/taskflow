import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_icon_type.dart';

/// `TaskStatus`, `TaskPriority` ve `TaskIconType` saf domain enum'ları —
/// hangi etiket/renk/ikonla gösterilecekleri tek bir yerde (burada)
/// tanımlanır. Board başlıkları, kart rozetleri, aksiyon menüsü ve
/// öncelik listesi hepsi bu extension'ları kullanır; "Yapılacak" yazısı
/// 4 farklı dosyada tekrar tekrar yazılmaz (DRY).
extension TaskStatusUi on TaskStatus {
  String get label => switch (this) {
        TaskStatus.todo => 'Yapılacak',
        TaskStatus.inProgress => 'Devam Ediyor',
        TaskStatus.done => 'Tamamlandı',
      };

  Color get color => switch (this) {
        TaskStatus.todo => AppColors.statusTodo,
        TaskStatus.inProgress => AppColors.statusInProgress,
        TaskStatus.done => AppColors.statusDone,
      };

  IconData get icon => switch (this) {
        TaskStatus.todo => Icons.radio_button_unchecked_rounded,
        TaskStatus.inProgress => Icons.autorenew_rounded,
        TaskStatus.done => Icons.check_circle_rounded,
      };
}

extension TaskPriorityUi on TaskPriority {
  String get label => switch (this) {
        TaskPriority.low => 'Düşük',
        TaskPriority.medium => 'Orta',
        TaskPriority.high => 'Yüksek',
        TaskPriority.critical => 'Kritik',
      };

  Color get color => switch (this) {
        TaskPriority.low => AppColors.priorityLow,
        TaskPriority.medium => AppColors.priorityMedium,
        TaskPriority.high => AppColors.priorityHigh,
        TaskPriority.critical => AppColors.priorityCritical,
      };

  IconData get icon => switch (this) {
        TaskPriority.low => Icons.south_rounded,
        TaskPriority.medium => Icons.remove_rounded,
        TaskPriority.high => Icons.north_rounded,
        TaskPriority.critical => Icons.priority_high_rounded,
      };

  /// Öncelik listesinde sıralama ağırlığı — büyük değer önce gösterilir.
  int get sortWeight => switch (this) {
        TaskPriority.critical => 3,
        TaskPriority.high => 2,
        TaskPriority.medium => 1,
        TaskPriority.low => 0,
      };
}

extension TaskIconTypeUi on TaskIconType {
  IconData get icon => switch (this) {
        TaskIconType.general => Icons.task_alt_rounded,
        TaskIconType.shopping => Icons.shopping_cart_rounded,
        TaskIconType.study => Icons.menu_book_rounded,
        TaskIconType.work => Icons.work_rounded,
        TaskIconType.home => Icons.home_rounded,
        TaskIconType.health => Icons.medical_services_rounded,
        TaskIconType.fitness => Icons.fitness_center_rounded,
        TaskIconType.pet => Icons.pets_rounded,
        TaskIconType.finance => Icons.account_balance_wallet_rounded,
        TaskIconType.travel => Icons.flight_takeoff_rounded,
        TaskIconType.food => Icons.restaurant_rounded,
      };

  String get label => switch (this) {
        TaskIconType.general => 'Genel',
        TaskIconType.shopping => 'Alışveriş',
        TaskIconType.study => 'Okul / Ders',
        TaskIconType.work => 'İş',
        TaskIconType.home => 'Ev İşleri',
        TaskIconType.health => 'Sağlık',
        TaskIconType.fitness => 'Spor',
        TaskIconType.pet => 'Evcil Hayvan',
        TaskIconType.finance => 'Finans',
        TaskIconType.travel => 'Seyahat',
        TaskIconType.food => 'Yemek',
      };
}

/// Görev ikonunu renkli, yuvarlak bir rozet (avatar) içinde gösterir.
/// `TaskCard`, ikon seçici ve öncelik listesinde aynı görsel dili
/// paylaşmaları için ortak bir widget olarak çıkarıldı.
class TaskIconBadge extends StatelessWidget {
  final TaskIconType iconType;
  final Color color;
  final double size;

  const TaskIconBadge({
    super.key,
    required this.iconType,
    required this.color,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Icon(iconType.icon, size: size * 0.52, color: color),
    );
  }
}
