import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:taskflow/app.dart';
import 'package:taskflow/core/theme/app_theme.dart';
import 'package:taskflow/features/board/data/models/task_model.dart';
import 'package:taskflow/features/board/data/repositories/task_repository.dart';
import 'package:taskflow/features/board/domain/entities/task_entity.dart';
import 'package:taskflow/features/board/domain/entities/task_icon_type.dart';
import 'package:taskflow/features/board/presentation/bloc/task_bloc.dart';
import 'package:taskflow/features/board/presentation/widgets/task_card.dart';

void main() {
  late Directory tempDir;
  late Box<TaskModel> taskBox;
  late Box<String> settingsBox;

  // Testlerde gerçek Hive kullanıyoruz (mock yerine) — geçici bir dizine
  // yazıp testler bitince siliyoruz. Bu sayede repository'nin gerçek
  // davranışını doğrularız, sahte bir implementasyonu değil.
  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('taskflow_test');
    Hive.init(tempDir.path);
    Hive.registerAdapter(TaskModelAdapter());
    taskBox = await Hive.openBox<TaskModel>('test_tasks');
    settingsBox = await Hive.openBox<String>('test_settings');
  });

  // Her testten önce kutuyu temizle → testler birbirinden bağımsız.
  setUp(() async {
    await taskBox.clear();
  });

  tearDownAll(() async {
    // Hive.close() tüm açık kutuları güvenli şekilde kapatır.
    await Hive.close();
    tempDir.deleteSync(recursive: true);
  });

  testWidgets('Board sayfası açılır ve üç sütunu gösterir', (tester) async {
    final repository = TaskRepository(taskBox);

    await tester.pumpWidget(App(taskRepository: repository, settingsBox: settingsBox));
    // İlk pump: widget ağacı inşa edilir (TaskLoading → CircularProgressIndicator).
    await tester.pump();
    // İkinci pump: BLoC'un senkron _onTasksLoaded'ı işlemesi ve rebuild için süre.
    // pumpAndSettle() kullanmıyoruz — CircularProgressIndicator sonsuz döner.
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('YAPILACAK'), findsOneWidget);
    expect(find.text('DEVAM EDIYOR'), findsOneWidget);
    expect(find.text('TAMAMLANDI'), findsOneWidget);
    expect(find.text('Yeni Görev'), findsOneWidget);
  });

  testWidgets('TaskCard hatasız çizilir ve görev başlığı görünür', (tester) async {
    // Regresyon testi: önceki bir sürümde TaskCard'daki non-uniform Border +
    // borderRadius kombinasyonu paint anında sessizce hata fırlatıyor,
    // kart sayaçta görünüyor ama hiç çizilmiyordu.
    //
    // TaskCard'ı doğrudan render ediyoruz (tam App yerine) — Bu sayede
    // CircularProgressIndicator'ın sonsuz Ticker'ı pumpAndSettle/pump'ı
    // engellemez ve test anında tamamlanır.
    final task = TaskEntity(
      id: 'test-render-1',
      title: 'Kediye mama al',
      description: 'Akşam eve dönerken al',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      iconType: TaskIconType.pet,
      labelColor: 0xFF36B37E,
      dueDate: null,
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
      note: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        // AppTheme.light: AppColorTokens extension'ını da taşır,
        // context.colors'ın çalışması için zorunlu.
        theme: AppTheme.light,
        home: Scaffold(
          body: BlocProvider(
            // TaskActionsMenu context.read<TaskBloc>() kullandığı için
            // ağaçta bir BLoC Provider bulunmak zorunda.
            create: (_) => TaskBloc(TaskRepository(taskBox)),
            child: TaskCard(task: task),
          ),
        ),
      ),
    );

    // Tek bir frame yeterli — TaskCard animasyonları implicit (AnimatedSlide,
    // AnimatedContainer) ve başlangıçta statik konumda.
    await tester.pump();

    expect(find.text('Kediye mama al'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
