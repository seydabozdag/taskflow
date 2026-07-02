import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/board/data/repositories/task_repository.dart';
import 'features/board/presentation/bloc/task_bloc.dart';
import 'features/board/presentation/bloc/task_event.dart';
import 'features/board/presentation/pages/board_page.dart';

/// Uygulamanın kök widget'ı.
///
/// TaskRepository ve settingsBox'u main.dart'tan burada constructor
/// üzerinden alıyoruz (dependency injection). Bu sayede App widget'ı,
/// bunların nasıl oluşturulduğundan habersiz — test yazarken sahte
/// bağımlılıklar kolayca enjekte edilebilir.
class App extends StatelessWidget {
  final TaskRepository taskRepository;
  final Box<String> settingsBox;

  const App({super.key, required this.taskRepository, required this.settingsBox});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: taskRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          // BlocProvider, TaskBloc'u widget ağacına enjekte eder.
          // Alt widget'lar context.read<TaskBloc>() ile erişebilir.
          BlocProvider(
            create: (context) => TaskBloc(taskRepository)..add(const TasksLoaded()),
          ),
          BlocProvider(create: (context) => ThemeCubit(settingsBox)),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'TaskFlow',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              home: const BoardPage(),
            );
          },
        ),
      ),
    );
  }
}
