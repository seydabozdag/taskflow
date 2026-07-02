import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/task_entity.dart';
import '../widgets/task_ui_extensions.dart';

class StatsPage extends StatelessWidget {
  final List<TaskEntity> tasks;

  const StatsPage({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) return const _EmptyStats();

    final padding = Responsive.boardPadding(context);
    final isMobile = Responsive.isMobile(context);

    final total = tasks.length;
    final done = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProgress = tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final todo = tasks.where((t) => t.status == TaskStatus.todo).length;
    final overdue = tasks.where((t) => t.isOverdue).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(total: total, done: done, overdue: overdue),
              const SizedBox(height: AppSizes.md),
              if (isMobile) ...[
                _StatusDonutCard(todo: todo, inProgress: inProgress, done: done),
                const SizedBox(height: AppSizes.md),
                _PriorityCard(tasks: tasks),
              ] else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _StatusDonutCard(todo: todo, inProgress: inProgress, done: done),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(child: _PriorityCard(tasks: tasks)),
                    ],
                  ),
                ),
              const SizedBox(height: AppSizes.md),
              _WeeklyBarCard(tasks: tasks),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Summary row ----------

class _SummaryRow extends StatelessWidget {
  final int total, done, overdue;
  const _SummaryRow({required this.total, required this.done, required this.overdue});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Toplam',
            value: '$total',
            icon: Icons.task_alt_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _StatCard(
            label: 'Tamamlanan',
            value: '$done',
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.statusDone,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: _StatCard(
            label: 'Geciken',
            value: '$overdue',
            icon: Icons.schedule_rounded,
            color: overdue > 0 ? AppColors.priorityCritical : AppColors.statusTodo,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border.all(color: colors.border),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 3, color: color),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 18, color: color),
                      const SizedBox(height: AppSizes.xs),
                      Text(
                        value,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(color: colors.textPrimary),
                      ),
                      Text(
                        label,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Donut chart ----------

class _StatusDonutCard extends StatelessWidget {
  final int todo, inProgress, done;
  const _StatusDonutCard({required this.todo, required this.inProgress, required this.done});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sections = <PieChartSectionData>[
      if (todo > 0)
        PieChartSectionData(
          value: todo.toDouble(),
          title: '$todo',
          color: AppColors.statusTodo,
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      if (inProgress > 0)
        PieChartSectionData(
          value: inProgress.toDouble(),
          title: '$inProgress',
          color: AppColors.statusInProgress,
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      if (done > 0)
        PieChartSectionData(
          value: done.toDouble(),
          title: '$done',
          color: AppColors.statusDone,
          radius: 52,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Durum Dağılımı', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.md),
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(sections: sections, centerSpaceRadius: 46, sectionsSpace: 2),
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Wrap(
            spacing: AppSizes.md,
            runSpacing: AppSizes.xs,
            children: TaskStatus.values.map((s) => _LegendDot(label: s.label, color: s.color)).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

// ---------- Priority breakdown ----------

class _PriorityCard extends StatelessWidget {
  final List<TaskEntity> tasks;
  const _PriorityCard({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = tasks.length;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Öncelik Dağılımı', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.md),
          for (final priority in TaskPriority.values.reversed) ...[
            _PriorityRow(
              priority: priority,
              count: tasks.where((t) => t.priority == priority).length,
              total: total,
            ),
            const SizedBox(height: AppSizes.sm),
          ],
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  final TaskPriority priority;
  final int count, total;
  const _PriorityRow({required this.priority, required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              priority.label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: priority.color, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text('$count', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 7,
              backgroundColor: colors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation(priority.color),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Weekly bar chart ----------

class _WeeklyBarCard extends StatelessWidget {
  final List<TaskEntity> tasks;
  const _WeeklyBarCard({required this.tasks});

  List<int> get _dailyCounts {
    final today = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(today.year, today.month, today.day).subtract(Duration(days: 6 - i));
      return tasks.where((t) {
        final u = t.updatedAt;
        return t.status == TaskStatus.done &&
            DateTime(u.year, u.month, u.day) == day;
      }).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final counts = _dailyCounts;
    final rawMax = counts.reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = rawMax < 1 ? 2.0 : rawMax + 1;

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Son 7 Gün — Tamamlanan Görevler', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.lg),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                barGroups: [
                  for (var i = 0; i < 7; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: counts[i].toDouble(),
                          color: AppColors.statusDone,
                          width: 22,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxY,
                            color: colors.surfaceMuted,
                          ),
                        ),
                      ],
                    ),
                ],
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final i = value.toInt();
                        if (i < 0 || i > 6) return const SizedBox.shrink();
                        final day = DateTime.now().subtract(Duration(days: 6 - i));
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('E', 'tr_TR').format(day),
                            style: TextStyle(color: colors.textTertiary, fontSize: 11),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Empty state ----------

class _EmptyStats extends StatelessWidget {
  const _EmptyStats();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_rounded, size: 64, color: colors.textTertiary),
          const SizedBox(height: AppSizes.md),
          Text('Henüz görev yok', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSizes.xs),
          Text(
            'İstatistikler görev ekledikten sonra burada görünür.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
