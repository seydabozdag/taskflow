import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'task_actions_menu.dart';
import 'task_ui_extensions.dart';

class TaskCard extends StatefulWidget {
  final TaskEntity task;

  const TaskCard({super.key, required this.task});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final labelColor = Color(widget.task.labelColor);

    final cardChild = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 150),
        offset: _isHovered ? const Offset(0, -0.015) : Offset.zero,
        child: _Card(task: widget.task, labelColor: labelColor, elevated: _isHovered),
      ),
    );

    if (isMobile) {
      return Dismissible(
        key: ValueKey('dismissible-${widget.task.id}'),
        direction: DismissDirection.horizontal,
        background: const _SwipeBg(
          color: AppColors.statusDone,
          icon: Icons.check_circle_outline_rounded,
          label: 'Tamamla',
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: const _SwipeBg(
          color: AppColors.priorityCritical,
          icon: Icons.delete_outline_rounded,
          label: 'Sil',
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          final bloc = context.read<TaskBloc>();
          if (direction == DismissDirection.endToStart) {
            final confirmed = await _confirmDelete(context);
            if (confirmed == true) bloc.add(TaskDeleted(taskId: widget.task.id));
            return false;
          }
          // startToEnd → complete
          if (widget.task.status != TaskStatus.done) {
            bloc.add(TaskMoved(taskId: widget.task.id, newStatus: TaskStatus.done));
          }
          return false;
        },
        child: cardChild,
      );
    }

    return Draggable<TaskEntity>(
      data: widget.task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: AppSizes.columnWidth - AppSizes.md * 2,
          child: Transform.rotate(
            angle: 0.03,
            child: _Card(task: widget.task, labelColor: labelColor, elevated: true),
          ),
        ),
      ),
      childWhenDragging: _GhostSlot(labelColor: labelColor),
      child: cardChild,
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Görevi sil?'),
      content: Text('"${widget.task.title}" kalıcı olarak silinecek.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Vazgeç'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.priorityCritical),
          child: const Text('Sil'),
        ),
      ],
    ),
  );
}

class _SwipeBg extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final AlignmentGeometry alignment;

  const _SwipeBg({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isRight = alignment == Alignment.centerRight;
    return Container(
      alignment: alignment,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: isRight
            ? [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSizes.xs),
                Icon(icon, color: Colors.white, size: 22),
              ]
            : [
                Icon(icon, color: Colors.white, size: 22),
                const SizedBox(width: AppSizes.xs),
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ],
      ),
    );
  }
}

class _GhostSlot extends StatelessWidget {
  final Color labelColor;

  const _GhostSlot({required this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: labelColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        border: Border.all(color: labelColor.withValues(alpha: 0.3)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final TaskEntity task;
  final Color labelColor;
  final bool elevated;

  const _Card({required this.task, required this.labelColor, required this.elevated});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final priority = task.priority;
    final radius = BorderRadius.circular(AppSizes.cardBorderRadius);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: elevated ? AppShadows.lg : AppShadows.sm,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          decoration: BoxDecoration(color: colors.surface, border: Border.all(color: colors.border)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: labelColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.xs, AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: TaskIconBadge(iconType: task.iconType, color: labelColor, size: 28),
                            ),
                            const SizedBox(width: AppSizes.sm),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            TaskActionsMenu(task: task),
                          ],
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: AppSizes.xs),
                          Padding(
                            padding: const EdgeInsets.only(left: 36),
                            child: Text(
                              task.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSizes.sm),
                        Padding(
                          padding: const EdgeInsets.only(left: 36, right: AppSizes.xs),
                          child: Wrap(
                            spacing: AppSizes.xs,
                            runSpacing: AppSizes.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              _Badge(color: priority.color, label: priority.label, icon: priority.icon),
                              if (task.dueDate != null) _DueDateBadge(task: task),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _Badge({required this.color, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _DueDateBadge extends StatelessWidget {
  final TaskEntity task;

  const _DueDateBadge({required this.task});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = task.isOverdue
        ? const Color(0xFFDE350B)
        : task.isDueToday
            ? const Color(0xFFFFAB00)
            : colors.textTertiary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: (task.isOverdue || task.isDueToday) ? color.withValues(alpha: 0.12) : null,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            DateFormat('d MMM', 'tr_TR').format(task.dueDate!),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }
}
