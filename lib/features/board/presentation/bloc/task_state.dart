import 'package:equatable/equatable.dart';
import '../../domain/entities/task_entity.dart';

/// TaskBloc'un üretebileceği tüm state'lerin temel sınıfı.
sealed class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

/// Görevler henüz yüklenmedi — ilk açılış anı.
class TaskInitial extends TaskState {
  const TaskInitial();
}

/// Görevler yükleniyor — UI bir loading indicator gösterebilir.
class TaskLoading extends TaskState {
  const TaskLoading();
}

/// Görevler başarıyla yüklendi/güncellendi.
///
/// Tek bir 'tasks' listesi tutuyoruz; UI bu listeyi status'a göre
/// filtreleyerek üç sütuna dağıtır (bkz. KanbanColumn).
/// Bu yaklaşım, "her sütun için ayrı state" tutmaktan daha basittir
/// ve tek bir source of truth sağlar.
class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;

  const TaskLoaded(this.tasks);

  List<TaskEntity> tasksByStatus(TaskStatus status) =>
      tasks.where((t) => t.status == status).toList();

  @override
  List<Object?> get props => [tasks];
}

/// Bir hata oluştu — UI bir hata mesajı gösterebilir.
class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
