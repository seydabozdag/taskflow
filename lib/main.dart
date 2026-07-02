import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';
import 'features/board/data/models/task_model.dart';
import 'features/board/data/repositories/task_repository.dart';

/// Uygulama girişi: Hive'ı başlatır, adapter'ı kaydeder, kutuyu açar.
///
/// main() async olmak zorunda çünkü Hive.initFlutter() ve Box açma
/// işlemleri disk/IndexedDB erişimi gerektirir (Future döner).
void main() async {
  // Flutter widget'ları henüz hazır değilken plugin çağrısı yapacağımız için şart.
  WidgetsFlutterBinding.ensureInitialized();

  // DateFormat('tr_TR') kullanabilmek için Türkçe locale verisini yükler.
  await initializeDateFormatting('tr_TR');

  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelAdapter());

  final taskBox = await Hive.openBox<TaskModel>('tasks');
  final taskRepository = TaskRepository(taskBox);

  // Tema tercihi gibi basit anahtar-değer ayarları için ayrı, küçük bir kutu.
  final settingsBox = await Hive.openBox<String>('settings');

  runApp(App(taskRepository: taskRepository, settingsBox: settingsBox));
}
