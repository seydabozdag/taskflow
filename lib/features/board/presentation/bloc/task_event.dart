import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_icon_type.dart';

/// TaskBloc'un alabileceği tüm event'lerin temel sınıfı.
///
/// UI hiçbir zaman state'i doğrudan değiştirmez — sadece "şu oldu"
/// diyerek bir event gönderir. State'i nasıl güncelleyeceğine BLoC karar verir.
/// Bu ayrım, iş mantığını widget'lardan tamamen izole eder.
sealed class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

/// Uygulama açıldığında / board sayfasına girildiğinde tetiklenir.
class TasksLoaded extends TaskEvent {
  const TasksLoaded();
}

/// Kullanıcı yeni bir görev oluşturduğunda tetiklenir (TaskFormSheet).
class TaskAdded extends TaskEvent {
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskIconType iconType;
  final int labelColor;
  final DateTime? dueDate;
  final String? note;

  const TaskAdded({
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.iconType,
    required this.labelColor,
    required this.dueDate,
    required this.note,
  });

  @override
  List<Object?> get props =>
      [title, description, status, priority, iconType, labelColor, dueDate, note];
}

/// Kullanıcı var olan bir görevi düzenleyip kaydettiğinde tetiklenir.
/// Aynı TaskFormSheet, `editingTask` doluyken bu event'i üretir.
class TaskUpdated extends TaskEvent {
  final String taskId;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final TaskIconType iconType;
  final int labelColor;
  final DateTime? dueDate;
  final String? note;

  const TaskUpdated({
    required this.taskId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.iconType,
    required this.labelColor,
    required this.dueDate,
    required this.note,
  });

  @override
  List<Object?> get props =>
      [taskId, title, description, status, priority, iconType, labelColor, dueDate, note];
}

/// Kullanıcı bir görevi sürükleyip başka sütuna bıraktığında VEYA aksiyon
/// menüsünden durumunu değiştirdiğinde tetiklenir — her iki giriş yolu da
/// aynı event'i üretir, BLoC'ta tek bir doğruluk kaynağı kalır.
class TaskMoved extends TaskEvent {
  final String taskId;
  final TaskStatus newStatus;

  const TaskMoved({required this.taskId, required this.newStatus});

  @override
  List<Object?> get props => [taskId, newStatus];
}

/// Kullanıcı aksiyon menüsünden bir görevin önceliğini değiştirdiğinde tetiklenir.
class TaskPriorityChanged extends TaskEvent {
  final String taskId;
  final TaskPriority priority;

  const TaskPriorityChanged({required this.taskId, required this.priority});

  @override
  List<Object?> get props => [taskId, priority];
}

/// Kullanıcı bir görevi sildiğinde tetiklenir.
class TaskDeleted extends TaskEvent {
  final String taskId;

  const TaskDeleted({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}
