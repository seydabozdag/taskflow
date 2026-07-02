import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/board_view_mode.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import 'task_ui_extensions.dart';

// ---------- Data types ----------

class _CmdDef {
  final IconData icon;
  final String label;
  final String hint;
  const _CmdDef(this.icon, this.label, [this.hint = '']);
}

const _kCommands = [
  _CmdDef(Icons.add_rounded, 'Yeni Görev', 'N'),
  _CmdDef(Icons.view_column_rounded, 'Kanban Görünümü'),
  _CmdDef(Icons.sort_rounded, 'Öncelik Listesi'),
  _CmdDef(Icons.bar_chart_rounded, 'İstatistikler'),
  _CmdDef(Icons.dark_mode_rounded, 'Tema Değiştir'),
];

sealed class _PaletteItem {}

class _CmdItem extends _PaletteItem {
  final int index;
  final _CmdDef def;
  _CmdItem(this.index, this.def);
}

class _TaskItem extends _PaletteItem {
  final TaskEntity task;
  _TaskItem(this.task);
}

// ---------- Public API ----------

Future<void> showCommandPalette(
  BuildContext context, {
  required VoidCallback onNewTask,
  required ValueChanged<BoardViewMode> onViewModeChanged,
  required ValueChanged<TaskEntity> onEditTask,
}) {
  final taskBloc = context.read<TaskBloc>();
  final themeCubit = context.read<ThemeCubit>();

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Komut paletini kapat',
    barrierColor: Colors.black45,
    transitionDuration: const Duration(milliseconds: 180),
    transitionBuilder: (_, anim, _, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: child,
      ),
    ),
    pageBuilder: (ctx, _, _) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: taskBloc),
        BlocProvider.value(value: themeCubit),
      ],
      child: _CommandPaletteDialog(
        onNewTask: onNewTask,
        onViewModeChanged: onViewModeChanged,
        onEditTask: onEditTask,
      ),
    ),
  );
}

// ---------- Widget ----------

class _CommandPaletteDialog extends StatefulWidget {
  final VoidCallback onNewTask;
  final ValueChanged<BoardViewMode> onViewModeChanged;
  final ValueChanged<TaskEntity> onEditTask;

  const _CommandPaletteDialog({
    required this.onNewTask,
    required this.onViewModeChanged,
    required this.onEditTask,
  });

  @override
  State<_CommandPaletteDialog> createState() => _CommandPaletteDialogState();
}

class _CommandPaletteDialogState extends State<_CommandPaletteDialog> {
  final _queryController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  int _selectedIndex = 0;

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<_PaletteItem> get _items {
    final q = _query.trim().toLowerCase();

    if (q.isEmpty) {
      return [for (var i = 0; i < _kCommands.length; i++) _CmdItem(i, _kCommands[i])];
    }

    final state = context.read<TaskBloc>().state;
    final tasks = state is TaskLoaded ? state.tasks : <TaskEntity>[];

    return [
      ...tasks.where((t) => t.title.toLowerCase().contains(q)).take(5).map(_TaskItem.new),
      for (var i = 0; i < _kCommands.length; i++)
        if (_kCommands[i].label.toLowerCase().contains(q)) _CmdItem(i, _kCommands[i]),
    ];
  }

  void _moveSelection(int delta) {
    final count = _items.length;
    if (count == 0) return;
    setState(() {
      _selectedIndex = (_selectedIndex + delta + count) % count;
    });
    _scrollToSelected();
  }

  void _scrollToSelected() {
    const itemH = 52.0;
    final offset = _selectedIndex * itemH;
    _scrollController.animateTo(
      offset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 80),
      curve: Curves.easeOut,
    );
  }

  void _select(_PaletteItem item) {
    final nav = Navigator.of(context);
    final themeCubit = context.read<ThemeCubit>();
    nav.pop();

    switch (item) {
      case _TaskItem(:final task):
        widget.onEditTask(task);
      case _CmdItem(:final index):
        switch (index) {
          case 0:
            widget.onNewTask();
          case 1:
            widget.onViewModeChanged(BoardViewMode.kanban);
          case 2:
            widget.onViewModeChanged(BoardViewMode.priorityList);
          case 3:
            widget.onViewModeChanged(BoardViewMode.stats);
          case 4:
            themeCubit.toggle();
        }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _moveSelection(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _moveSelection(-1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter) {
      final items = _items;
      if (_selectedIndex < items.length) _select(items[_selectedIndex]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).pop();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = (screenWidth - AppSizes.md * 2).clamp(0.0, 560.0);
    final topPadding = MediaQuery.viewPaddingOf(context).top + AppSizes.xl + AppSizes.md;
    final items = _items;

    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(AppSizes.md, topPadding, AppSizes.md, 0),
        child: Material(
          elevation: 16,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          color: colors.surface,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: SizedBox(
              width: dialogWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Focus(
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _queryController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Görev ara veya komut çalıştır…',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _queryController.clear();
                                  setState(() {
                                    _query = '';
                                    _selectedIndex = 0;
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                          vertical: AppSizes.md,
                        ),
                      ),
                      onChanged: (v) => setState(() {
                        _query = v;
                        _selectedIndex = 0;
                      }),
                    ),
                  ),
                  if (items.isNotEmpty) ...[
                    Divider(height: 1, color: colors.border),
                    if (_query.isEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.md,
                          AppSizes.sm,
                          AppSizes.md,
                          AppSizes.xs,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'HIZLI KOMUTLAR',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.textTertiary,
                                  letterSpacing: 0.8,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      )
                    else if (items.any((e) => e is _TaskItem))
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.md,
                          AppSizes.sm,
                          AppSizes.md,
                          AppSizes.xs,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'GÖREVLER',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: colors.textTertiary,
                                  letterSpacing: 0.8,
                                  fontSize: 10,
                                ),
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.builder(
                        controller: _scrollController,
                        shrinkWrap: true,
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          final isSelected = i == _selectedIndex;
                          return _PaletteRow(
                            item: item,
                            isSelected: isSelected,
                            onTap: () => _select(item),
                          );
                        },
                      ),
                    ),
                  ],
                  Divider(height: 1, color: colors.border),
                  _Footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PaletteRow extends StatelessWidget {
  final _PaletteItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaletteRow({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 80),
          color: isSelected ? colors.primarySubtle : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 14),
          child: Row(
            children: switch (item) {
              _CmdItem(:final def) => [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                      border: Border.all(color: colors.border),
                    ),
                    child: Icon(def.icon, size: 15, color: colors.textSecondary),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Text(
                      def.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  if (def.hint.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: colors.border),
                      ),
                      child: Text(
                        def.hint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colors.textTertiary,
                              fontFamily: 'monospace',
                              fontSize: 11,
                            ),
                      ),
                    ),
                ],
              _TaskItem(:final task) => [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(task.labelColor).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Icon(task.status.icon, size: 14, color: Color(task.labelColor)),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          task.status.label,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: colors.textTertiary,
                                fontSize: 11,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
            },
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: AppSizes.xs),
      child: Row(
        children: [
          _KeyChip('↑↓'),
          const SizedBox(width: AppSizes.xs),
          Text('Gezin', style: TextStyle(color: colors.textTertiary, fontSize: 11)),
          const SizedBox(width: AppSizes.md),
          _KeyChip('↵'),
          const SizedBox(width: AppSizes.xs),
          Text('Seç', style: TextStyle(color: colors.textTertiary, fontSize: 11)),
          const SizedBox(width: AppSizes.md),
          _KeyChip('Esc'),
          const SizedBox(width: AppSizes.xs),
          Text('Kapat', style: TextStyle(color: colors.textTertiary, fontSize: 11)),
        ],
      ),
    );
  }
}

class _KeyChip extends StatelessWidget {
  final String label;
  const _KeyChip(this.label);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(color: colors.textSecondary, fontSize: 10, fontFamily: 'monospace'),
      ),
    );
  }
}
