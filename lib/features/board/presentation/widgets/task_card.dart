import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../domain/entities/task_entity.dart';
import 'task_actions_menu.dart';
import 'task_ui_extensions.dart';

/// Bir görevi temsil eden kart.
///
/// Draggable ile sarmalanır — KanbanColumn içindeki DragTarget'lar
/// bu kartın taşıdığı TaskEntity'yi (data parametresi) yakalar.
///
/// StatefulWidget: hover durumunu (masaüstünde fare üzerine gelince
/// hafif yükselme efekti) tutmak için local state gerekiyor. Bu state
/// sadece bu kartı ilgilendiriyor — BLoC'a taşınmaz.
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
    final labelColor = Color(widget.task.labelColor);

    return Draggable<TaskEntity>(
      data: widget.task,
      // Sürüklerken imlecin altında görünen, hafif eğik "kaldırılmış kart"
      // hissi veren önizleme — Trello'nun fiziksel kart metaforuna yakın.
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
      // Orijinal konumda kalan, kartın "boşluğunu" işaret eden hayalet yer.
      childWhenDragging: _GhostSlot(labelColor: labelColor),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 150),
          offset: _isHovered ? const Offset(0, -0.015) : Offset.zero,
          child: _Card(task: widget.task, labelColor: labelColor, elevated: _isHovered),
        ),
      ),
    );
  }
}

/// Sürüklenirken kartın eski yerinde kalan, kesik çizgili boş yuva.
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

/// Kartın görsel gövdesi. Draggable'ın hem normal hem feedback
/// görünümünde aynı görsel dili paylaşmaları için ayrı bir widget.
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

    // NOT: Flutter, farklı kalınlıklarda kenarlığa sahip bir `Border` ile
    // `borderRadius`'u AYNI ANDA kullanmaya izin vermez (paint anında
    // FlutterError fırlatır — flutter analyze bunu yakalayamaz, kart
    // sessizce çizilmez). Bu yüzden sol "etiket rengi" şeridini bir border
    // yerine ayrı, dar bir Container olarak Row'un başına ekliyoruz; dış
    // kenarlık tek tip (uniform) kalıyor.
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(borderRadius: radius, boxShadow: elevated ? AppShadows.lg : AppShadows.sm),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.md,
                      AppSizes.sm,
                      AppSizes.xs,
                      AppSizes.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: TaskIconBadge(
                                iconType: task.iconType,
                                color: labelColor,
                                size: 28,
                              ),
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
                              _Badge(
                                color: priority.color,
                                label: priority.label,
                                icon: priority.icon,
                              ),
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

/// Son tarih rozeti — gecikmişse kırmızı, bugünse amber, normalse nötr renkte.
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
