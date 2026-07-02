import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task_entity.dart';
import 'task_event.dart';
import 'task_state.dart';

/// Event → State dönüşümünün tek yapıldığı yer.
///
/// Her `on<EventTipi>` bloğu, o event geldiğinde ne yapılacağını tanımlar.
/// Bloc, repository üzerinden veriye erişir ama HİÇBİR ZAMAN Hive'ı
/// doğrudan bilmez — bu sayede iş mantığı testleri repository'yi
/// sahteleyerek (fake/mock) çalıştırılabilir.
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository _repository;
  final _uuid = const Uuid();

  TaskBloc(this._repository) : super(const TaskInitial()) {
    on<TasksLoaded>(_onTasksLoaded);
    on<TaskAdded>(_onTaskAdded);
    on<TaskUpdated>(_onTaskUpdated);
    on<TaskMoved>(_onTaskMoved);
    on<TaskPriorityChanged>(_onTaskPriorityChanged);
    on<TaskDeleted>(_onTaskDeleted);
  }

  void _onTasksLoaded(TasksLoaded event, Emitter<TaskState> emit) {
    emit(const TaskLoading());
    try {
      final tasks = _repository.getAllTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Görevler yüklenemedi: $e'));
    }
  }

  Future<void> _onTaskAdded(TaskAdded event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final now = DateTime.now();
    final newTask = TaskEntity(
      id: _uuid.v4(),
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      iconType: event.iconType,
      labelColor: event.labelColor,
      dueDate: event.dueDate,
      createdAt: now,
      updatedAt: now,
      note: event.note,
    );

    await _repository.addTask(newTask);
    emit(TaskLoaded([...currentState.tasks, newTask]));
  }

  Future<void> _onTaskUpdated(TaskUpdated event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final index = currentState.tasks.indexWhere((t) => t.id == event.taskId);
    if (index == -1) return;

    final existing = currentState.tasks[index];
    final updated = TaskEntity(
      id: existing.id,
      title: event.title,
      description: event.description,
      status: event.status,
      priority: event.priority,
      iconType: event.iconType,
      labelColor: event.labelColor,
      dueDate: event.dueDate,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
      note: event.note,
    );

    await _repository.updateTask(updated);

    final updatedTasks = List<TaskEntity>.from(currentState.tasks);
    updatedTasks[index] = updated;
    emit(TaskLoaded(updatedTasks));
  }

  Future<void> _onTaskMoved(TaskMoved event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final taskIndex = currentState.tasks.indexWhere((t) => t.id == event.taskId);
    if (taskIndex == -1) return;

    final updatedTask = currentState.tasks[taskIndex].copyWith(
      status: event.newStatus,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTask(updatedTask);

    final updatedTasks = List<TaskEntity>.from(currentState.tasks);
    updatedTasks[taskIndex] = updatedTask;
    emit(TaskLoaded(updatedTasks));
  }

  Future<void> _onTaskPriorityChanged(
    TaskPriorityChanged event,
    Emitter<TaskState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    final index = currentState.tasks.indexWhere((t) => t.id == event.taskId);
    if (index == -1) return;

    final updatedTask = currentState.tasks[index].copyWith(
      priority: event.priority,
      updatedAt: DateTime.now(),
    );
    await _repository.updateTask(updatedTask);

    final updatedTasks = List<TaskEntity>.from(currentState.tasks);
    updatedTasks[index] = updatedTask;
    emit(TaskLoaded(updatedTasks));
  }

  Future<void> _onTaskDeleted(TaskDeleted event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is! TaskLoaded) return;

    await _repository.deleteTask(event.taskId);
    final updatedTasks = currentState.tasks.where((t) => t.id != event.taskId).toList();
    emit(TaskLoaded(updatedTasks));
  }
}
