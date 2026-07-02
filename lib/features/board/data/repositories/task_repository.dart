import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

/// BLoC'un veriye erişim için kullandığı tek kapı.
///
/// BLoC asla Hive'ı doğrudan bilmez — sadece bu repository'nin
/// metodlarını çağırır. Bu sayede:
/// 1. BLoC'u test ederken Hive'a ihtiyaç duymadan sahte (fake) bir
///    repository enjekte edebiliriz.
/// 2. Hive'dan başka bir veri kaynağına (REST API, Firebase) geçmek
///    istersek sadece bu sınıfı değiştiririz — BLoC hiç değişmez.
class TaskRepository {
  final Box<TaskModel> _box;

  TaskRepository(this._box);

  /// Kutudaki tüm görevleri domain entity olarak döndürür.
  List<TaskEntity> getAllTasks() {
    return _box.values.map((model) => model.toEntity()).toList();
  }

  /// Yeni bir görev ekler.
  Future<void> addTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _box.put(task.id, model);
  }

  /// Var olan bir görevi günceller (örn: sütun değişikliği, düzenleme).
  Future<void> updateTask(TaskEntity task) async {
    final model = TaskModel.fromEntity(task);
    await _box.put(task.id, model);
  }

  /// Bir görevi siler.
  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
  }
}
