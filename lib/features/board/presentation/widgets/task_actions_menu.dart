import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'task_form_sheet.dart';
import 'task_ui_extensions.dart';

/// Görev kartı ve öncelik listesi satırında ortak kullanılan üç-nokta menü.
///
/// Hem `TaskCard` hem `PriorityListView` aynı aksiyon setine ihtiyaç
/// duyduğu için (düzenle/sil/durum/öncelik değiştir) burada tek bir yerde
/// tanımlanır — kopya kod yerine paylaşılan bir bileşen (DRY).
class TaskActionsMenu extends StatelessWidget {
  final TaskEntity task;

  const TaskActionsMenu({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'İşlemler',
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      style: IconButton.styleFrom(
        minimumSize: const Size(AppSizes.minTouchTarget, AppSizes.minTouchTarget),
      ),
      itemBuilder: (menuContext) => [
        const PopupMenuItem(
          value: 'edit',
          child: _MenuRow(icon: Icons.edit_outlined, label: 'Düzenle'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          height: 28,
          child: Text('DURUM', style: Theme.of(menuContext).textTheme.bodySmall),
        ),
        for (final status in TaskStatus.values)
          PopupMenuItem(
            value: 'status:${status.name}',
            child: _MenuRow(
              icon: status.icon,
              label: status.label,
              iconColor: status.color,
              trailing: task.status == status ? Icons.check_rounded : null,
            ),
          ),
        const PopupMenuDivider(),
        PopupMenuItem(
          enabled: false,
          height: 28,
          child: Text('ÖNCELİK', style: Theme.of(menuContext).textTheme.bodySmall),
        ),
        for (final priority in TaskPriority.values)
          PopupMenuItem(
            value: 'priority:${priority.name}',
            child: _MenuRow(
              icon: priority.icon,
              label: priority.label,
              iconColor: priority.color,
              trailing: task.priority == priority ? Icons.check_rounded : null,
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: _MenuRow(
            icon: Icons.delete_outline_rounded,
            label: 'Sil',
            iconColor: AppColors.priorityCritical,
            labelColor: AppColors.priorityCritical,
          ),
        ),
      ],
      onSelected: (value) => _handleSelection(context, value),
    );
  }

  void _handleSelection(BuildContext context, String value) {
    final bloc = context.read<TaskBloc>();

    if (value == 'edit') {
      showTaskForm(context, editingTask: task);
      return;
    }
    if (value == 'delete') {
      _confirmDelete(context, bloc);
      return;
    }
    if (value.startsWith('status:')) {
      final status = TaskStatus.values.byName(value.substring('status:'.length));
      bloc.add(TaskMoved(taskId: task.id, newStatus: status));
      return;
    }
    if (value.startsWith('priority:')) {
      final priority = TaskPriority.values.byName(value.substring('priority:'.length));
      bloc.add(TaskPriorityChanged(taskId: task.id, priority: priority));
      return;
    }
  }

  Future<void> _confirmDelete(BuildContext context, TaskBloc bloc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Görevi sil?'),
        content: Text(
          '"${task.title}" görevi kalıcı olarak silinecek. Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.priorityCritical),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bloc.add(TaskDeleted(taskId: task.id));
    }
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;
  final IconData? trailing;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? context.colors.textSecondary),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: labelColor),
          ),
        ),
        if (trailing != null)
          Icon(trailing, size: 16, color: context.colors.primary),
      ],
    );
  }
}
