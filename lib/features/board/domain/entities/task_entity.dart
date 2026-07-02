import 'package:equatable/equatable.dart';
import 'task_icon_type.dart';

/// Bir görevin hangi sütunda olduğunu temsil eder.
/// String yerine enum kullanıyoruz — typo'ya karşı tip güvenliği sağlar.
enum TaskStatus { todo, inProgress, done }

/// Görev önceliği — kart üzerinde renk kodlaması ve öncelik listesi
/// sıralaması için kullanılır. Sıralama: critical > high > medium > low.
enum TaskPriority { low, medium, high, critical }

/// `copyWith` içinde "bu alana dokunma" ile "bu alanı null yap" arasındaki
/// farkı ayırt etmek için kullanılan sentinel değer (bkz. TaskEntity.copyWith).
const Object _unset = Object();

/// Saf iş nesnesi (domain entity).
///
/// Bu sınıf Hive'dan, Flutter'dan, hiçbir framework'ten haberdar değildir —
/// sadece "bir görev nedir?" sorusunu cevaplar. `labelColor` bilinçli olarak
/// `Color` değil `int` (ARGB) tutulur — `Color` Flutter'a ait bir tip,
/// onu domain katmanına sızdırmamak için presentation katmanı `Color(value)`
/// ile dönüştürür.
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskIconType iconType;
  final int labelColor;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? note;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.iconType,
    required this.labelColor,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.note,
  });

  /// Var olan bir görevin bazı alanlarını değiştirerek yeni bir kopya üretir.
  ///
  /// `dueDate` ve `note` nullable olduğu için "parametre verilmedi" (eski
  /// değeri koru) ile "parametre olarak null verildi" (alanı temizle)
  /// durumlarını ayırt etmemiz gerekir. Bunun için `_unset` sentinel'ı
  /// kullanılır: varsayılan değer `_unset` ise dokunulmaz, açıkça `null`
  /// (veya bir değer) verilirse o kullanılır.
  TaskEntity copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    TaskPriority? priority,
    TaskIconType? iconType,
    int? labelColor,
    Object? dueDate = _unset,
    Object? note = _unset,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      iconType: iconType ?? this.iconType,
      labelColor: labelColor ?? this.labelColor,
      dueDate: identical(dueDate, _unset) ? this.dueDate : dueDate as DateTime?,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: identical(note, _unset) ? this.note : note as String?,
    );
  }

  /// Son tarihi geçmiş ve henüz tamamlanmamış görevler için true döner.
  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    final today = DateTime.now();
    final dueDay = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final currentDay = DateTime(today.year, today.month, today.day);
    return dueDay.isBefore(currentDay);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final today = DateTime.now();
    return dueDate!.year == today.year &&
        dueDate!.month == today.month &&
        dueDate!.day == today.day;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        status,
        priority,
        iconType,
        labelColor,
        dueDate,
        createdAt,
        updatedAt,
        note,
      ];
}
