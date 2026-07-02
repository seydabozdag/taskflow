import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/task_entity.dart';
import 'task_actions_menu.dart';
import 'task_ui_extensions.dart';

/// Tüm görevleri tek bir listede, önceliğe göre sıralayarak gösteren
/// alternatif görünüm. Kanban'ın aksine sürükle-bırak içermez — bu görünümün
/// amacı "şimdi neye odaklanmalıyım?" sorusuna hızlı cevap vermek.
///
/// Sıralama: önce öncelik (Kritik → Düşük), eşit öncelikte ise son tarihi
/// daha yakın olan üstte (tarihi olmayanlar en sona).
class PriorityListView extends StatelessWidget {
  final List<TaskEntity> tasks;

  const PriorityListView({super.key, required this.tasks});

  List<TaskEntity> get _sortedTasks {
    final sorted = [...tasks];
    sorted.sort((a, b) {
      final priorityCompare = b.priority.sortWeight.compareTo(a.priority.sortWeight);
      if (priorityCompare != 0) return priorityCompare;

      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      return a.dueDate!.compareTo(b.dueDate!);
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sortedTasks;
    final padding = Responsive.boardPadding(context);

    if (sorted.isEmpty) {
      return const _PriorityListEmptyState();
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView.separated(
          padding: EdgeInsets.all(padding),
          itemCount: sorted.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
          itemBuilder: (context, index) => _PriorityListItem(task: sorted[index]),
        ),
      ),
    );
  }
}

class _PriorityListItem extends StatefulWidget {
  final TaskEntity task;

  const _PriorityListItem({required this.task});

  @override
  State<_PriorityListItem> createState() => _PriorityListItemState();
}

class _PriorityListItemState extends State<_PriorityListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final task = widget.task;
    final labelColor = Color(task.labelColor);
    final priority = task.priority;

    // NOT: Flutter, farklı kalınlıklarda kenarlığa sahip bir `Border` ile
    // `borderRadius`'u aynı anda kullanmaya izin vermez (paint anında
    // FlutterError fırlatır, flutter analyze bunu yakalayamaz — satır
    // sessizce çizilmez). Sol "öncelik rengi" şeridini bir Container olarak
    // Row'un başına ekliyoruz; dış kenarlık tek tip (uniform) kalıyor.
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: _isHovered
              ? [BoxShadow(color: colors.border, blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          child: Container(
            decoration: BoxDecoration(color: colors.surface, border: Border.all(color: colors.border)),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 3, color: priority.color),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      child: Row(
                        children: [
                          TaskIconBadge(iconType: task.iconType, color: labelColor, size: 36),
                          const SizedBox(width: AppSizes.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: Theme.of(context).textTheme.titleLarge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (task.description.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      task.description,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                const SizedBox(height: AppSizes.xs),
                                Wrap(
                                  spacing: AppSizes.xs,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    _Pill(
                                      color: priority.color,
                                      icon: priority.icon,
                                      label: priority.label,
                                    ),
                                    _Pill(
                                      color: task.status.color,
                                      icon: task.status.icon,
                                      label: task.status.label,
                                    ),
                                    if (task.dueDate != null)
                                      _Pill(
                                        color: task.isOverdue
                                            ? const Color(0xFFDE350B)
                                            : task.isDueToday
                                                ? const Color(0xFFFFAB00)
                                                : colors.textTertiary,
                                        icon: Icons.schedule_rounded,
                                        label: DateFormat('d MMM', 'tr_TR').format(task.dueDate!),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSizes.sm),
                          TaskActionsMenu(task: task),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _Pill({required this.color, required this.icon, required this.label});

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

class _PriorityListEmptyState extends StatelessWidget {
  const _PriorityListEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: colors.surfaceMuted, shape: BoxShape.circle),
              child: Icon(Icons.checklist_rtl_rounded, size: 28, color: colors.textTertiary),
            ),
            const SizedBox(height: AppSizes.md),
            Text('Henüz görev yok', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSizes.xs),
            Text(
              'Sağ üstteki "Yeni Görev" butonuyla ilk görevini ekle.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
