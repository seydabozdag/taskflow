import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_icon_type.dart';

part 'task_model.g.dart';

/// Hive'a kaydedilebilen veri modeli.
///
/// TaskEntity'den ayrı tutuyoruz çünkü Hive'ın @HiveType/@HiveField
/// anotasyonları framework'e özgüdür — domain katmanını bundan
/// bağımsız tutmak Dependency Inversion prensibinin gereğidir.
///
/// Alan 6-10 sonradan eklendi; `defaultValue` sayesinde önceki sürümde
/// kaydedilmiş görevler (bu alanlar olmadan) açılırken hata vermez.
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int statusIndex;

  @HiveField(4)
  final int priorityIndex;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6, defaultValue: 0)
  final int iconTypeIndex;

  @HiveField(7, defaultValue: 0xFF6B778C)
  final int labelColorValue;

  @HiveField(8)
  final DateTime? dueDate;

  @HiveField(9)
  final DateTime? updatedAt;

  @HiveField(10)
  final String? note;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.statusIndex,
    required this.priorityIndex,
    required this.createdAt,
    required this.iconTypeIndex,
    required this.labelColorValue,
    required this.dueDate,
    required this.updatedAt,
    required this.note,
  });

  /// Domain entity'den Hive modeline dönüşüm.
  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      statusIndex: entity.status.index,
      priorityIndex: entity.priority.index,
      createdAt: entity.createdAt,
      iconTypeIndex: entity.iconType.index,
      labelColorValue: entity.labelColor,
      dueDate: entity.dueDate,
      updatedAt: entity.updatedAt,
      note: entity.note,
    );
  }

  /// Hive modelinden domain entity'ye dönüşüm.
  /// BLoC ve UI sadece bu metodun ürettiği TaskEntity'lerle çalışır.
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      description: description,
      status: TaskStatus.values[statusIndex],
      priority: TaskPriority.values[priorityIndex],
      iconType: TaskIconType.values[iconTypeIndex],
      labelColor: labelColorValue,
      dueDate: dueDate,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      note: note,
    );
  }
}
