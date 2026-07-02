import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'task_card.dart';
import 'task_form_sheet.dart';
import 'task_ui_extensions.dart';

/// Tek bir Kanban sütunu (Todo / In Progress / Done).
///
/// `DragTarget<TaskEntity>` ile sarılır: bir TaskCard bu sütuna bırakıldığında
/// onAcceptWithDetails tetiklenir ve TaskMoved event'i gönderilir.
/// Sütun, hangi TaskEntity'nin kabul edilebileceğini generic tip üzerinden
/// derleme zamanında garanti eder — yanlış tipte veri kabul edilemez.
class KanbanColumn extends StatelessWidget {
  final TaskStatus status;
  final List<TaskEntity> tasks;

  /// Sütun genişliği. Masaüstünde sabit (AppSizes.columnWidth), mobilde
  /// ekranı dolduracak şekilde (double.infinity) dışarıdan verilir.
  /// Bu sayede aynı widget hem yatay scroll hem de tam genişlik
  /// senaryosunda değişiklik gerekmeden çalışır.
  final double width;

  /// Mobil PageView içinde kullanılırken sağ margin gerekmiyor.
  final bool showMargin;

  const KanbanColumn({
    super.key,
    required this.status,
    required this.tasks,
    this.width = AppSizes.columnWidth,
    this.showMargin = true,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = status.color;

    return DragTarget<TaskEntity>(
      onWillAcceptWithDetails: (details) => details.data.status != status,
      onAcceptWithDetails: (details) {
        context.read<TaskBloc>().add(
              TaskMoved(taskId: details.data.id, newStatus: status),
            );
      },
      builder: (context, candidateData, rejectedData) {
        // Sürüklenen bir kart bu sütunun üzerine gelince hafif vurgula.
        final isHighlighted = candidateData.isNotEmpty;
        final colors = context.colors;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: width,
          margin: showMargin ? const EdgeInsets.only(right: AppSizes.columnGap) : null,
          decoration: BoxDecoration(
            color: isHighlighted ? accentColor.withValues(alpha: 0.05) : colors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: isHighlighted ? accentColor : colors.border,
              width: isHighlighted ? 1.5 : 1,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ColumnHeader(status: status, count: tasks.length),
              Divider(height: 1, color: colors.border),
              Expanded(
                child: tasks.isEmpty
                    ? _EmptyState(accentColor: accentColor, isHighlighted: isHighlighted)
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSizes.md),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSizes.sm),
                        itemBuilder: (context, index) => TaskCard(task: tasks[index]),
                      ),
              ),
              _AddTaskButton(status: status),
            ],
          ),
        );
      },
    );
  }
}

/// Sütun başlığı: renkli durum noktası + isim + görev sayısı rozeti.
class _ColumnHeader extends StatelessWidget {
  final TaskStatus status;
  final int count;

  const _ColumnHeader({required this.status, required this.count});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final accentColor = status.color;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.sm, AppSizes.md),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.sm),
          Expanded(
            child: Text(
              status.label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 0.6,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSizes.sm),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            ),
            child: Text(
              '$count',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sütun boşken gösterilen, sürükle-bırak hedefini netleştiren durum.
/// Üzerine bir kart sürüklenince ikon ve metin renk değiştirip büyür —
/// "buraya bırakabilirsin" geri bildirimini netleştirir.
class _EmptyState extends StatelessWidget {
  final Color accentColor;
  final bool isHighlighted;

  const _EmptyState({required this.accentColor, required this.isHighlighted});

  @override
  Widget build(BuildContext context) {
    final color = isHighlighted ? accentColor : context.colors.textTertiary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              scale: isHighlighted ? 1.15 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.inbox_outlined, size: 20, color: color),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              isHighlighted ? 'Bırakmak için serbest bırak' : 'Henüz görev yok',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sütunun altındaki hızlı ekleme butonu — Trello'nun "+ Add a card"
/// deseni. Tıklanınca form, bu sütunun durumu önceden seçili olarak açılır.
class _AddTaskButton extends StatelessWidget {
  final TaskStatus status;

  const _AddTaskButton({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSizes.sm, 0, AppSizes.sm, AppSizes.sm),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          onPressed: () => showTaskForm(context, initialStatus: status),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: const Text('Görev ekle'),
          style: TextButton.styleFrom(
            foregroundColor: context.colors.textSecondary,
            alignment: Alignment.centerLeft,
            minimumSize: const Size(double.infinity, AppSizes.minTouchTarget),
          ),
        ),
      ),
    );
  }
}
