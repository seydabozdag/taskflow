import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/board_view_mode.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_state.dart';
import '../widgets/kanban_column.dart';
import '../widgets/priority_list_view.dart';
import '../widgets/task_form_sheet.dart';
import '../widgets/task_ui_extensions.dart';

/// Board'un kendisi tek bir local state (`BoardViewMode`) taşır — bu saf
/// bir navigasyon/UI tercihidir, paylaşılan iş verisi değildir, bu yüzden
/// BLoC'a taşımak gereksiz mimari ağırlık eklerdi.
class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  BoardViewMode _viewMode = BoardViewMode.kanban;

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: _BoardAppBar(
        isMobile: isMobile,
        viewMode: _viewMode,
        onViewModeChanged: (mode) => setState(() => _viewMode = mode),
      ),
      // Sayfa arka planına çok hafif bir gradient veriyoruz; düz tek renkten
      // daha "premium" bir his veriyor ama yine de göz yormuyor. Renkler
      // context.colors'tan geldiği için dark temada otomatik uyumlu olur.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colors.background, colors.backgroundEnd],
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              return switch (state) {
                TaskInitial() || TaskLoading() =>
                  const Center(child: CircularProgressIndicator()),
                TaskError(:final message) => Center(child: Text(message)),
                TaskLoaded() => switch (_viewMode) {
                    BoardViewMode.priorityList => PriorityListView(tasks: state.tasks),
                    BoardViewMode.kanban =>
                      isMobile ? _MobileBoard(state: state) : _DesktopBoard(state: state),
                  },
              };
            },
          ),
        ),
      ),
    );
  }
}

/// Üst bar: marka rozeti + başlık, sağda görünüm anahtarı + tema anahtarı +
/// görev ekleme aksiyonu. Dar ekranda metin etiketleri ikon-only'e düşer.
class _BoardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isMobile;
  final BoardViewMode viewMode;
  final ValueChanged<BoardViewMode> onViewModeChanged;

  const _BoardAppBar({
    required this.isMobile,
    required this.viewMode,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return AppBar(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(bottom: BorderSide(color: colors.border)),
      titleSpacing: AppSizes.lg,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colors.primarySubtle,
              borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            ),
            child: Icon(Icons.view_kanban_rounded, size: 18, color: colors.primary),
          ),
          const SizedBox(width: AppSizes.sm),
          Text('TaskFlow', style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
      actions: [
        _ViewModeSwitch(viewMode: viewMode, onChanged: onViewModeChanged),
        const SizedBox(width: AppSizes.xs),
        const _ThemeToggleButton(),
        const SizedBox(width: AppSizes.xs),
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.lg),
          child: isMobile
              ? IconButton.filled(
                  onPressed: () => showTaskForm(context),
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: colors.primary),
                )
              : FilledButton.icon(
                  onPressed: () => showTaskForm(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Yeni Görev'),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Kanban ↔ Öncelik Listesi geçişi için ikon-only segmented control.
class _ViewModeSwitch extends StatelessWidget {
  final BoardViewMode viewMode;
  final ValueChanged<BoardViewMode> onChanged;

  const _ViewModeSwitch({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<BoardViewMode>(
      showSelectedIcon: false,
      style: const ButtonStyle(visualDensity: VisualDensity.compact),
      segments: const [
        ButtonSegment(
          value: BoardViewMode.kanban,
          icon: Icon(Icons.view_column_rounded, size: 18),
          tooltip: 'Kanban görünümü',
        ),
        ButtonSegment(
          value: BoardViewMode.priorityList,
          icon: Icon(Icons.sort_rounded, size: 18),
          tooltip: 'Öncelik listesi',
        ),
      ],
      selected: {viewMode},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

/// Açık/koyu tema anahtarı — `ThemeCubit`'in mevcut değerine göre
/// güneş/ay ikonu arasında geçiş yapar.
class _ThemeToggleButton extends StatelessWidget {
  const _ThemeToggleButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          tooltip: isDark ? 'Açık temaya geç' : 'Koyu temaya geç',
          onPressed: () => context.read<ThemeCubit>().toggle(),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
          ),
        );
      },
    );
  }
}

/// Masaüstü: üstte özet başlık + ilerleme çubuğu, altında yatay scroll
/// ile yan yana sütunlar. Çok geniş ekranlarda board'un aşırı yayılmasını
/// `maxContentWidth` ile sınırlandırıyoruz.
class _DesktopBoard extends StatelessWidget {
  final TaskLoaded state;

  const _DesktopBoard({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.tasks.length;
    final done = state.tasksByStatus(TaskStatus.done).length;
    final padding = Responsive.boardPadding(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BoardSummary(total: total, done: done),
              const SizedBox(height: AppSizes.lg),
              // KanbanColumn içindeki Expanded(ListView), sınırlı bir
              // yükseklik gerektirir. SingleChildScrollView bunu sağlamadığı
              // için Expanded + LayoutBuilder ile mevcut alanın tam
              // yüksekliğini Row'a açıkça veriyoruz.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SizedBox(
                        height: constraints.maxHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final status in TaskStatus.values)
                              KanbanColumn(
                                status: status,
                                tasks: state.tasksByStatus(status),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Board'un üstündeki özet şeridi: toplam/tamamlanan görev sayısı + ince
/// bir ilerleme çubuğu. Sade ama "gerçek bir SaaS panosu" hissini güçlendirir.
class _BoardSummary extends StatelessWidget {
  final int total;
  final int done;

  const _BoardSummary({required this.total, required this.done});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final progress = total == 0 ? 0.0 : done / total;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Görev Panosu', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 2),
            Text(
              total == 0 ? 'Henüz görev eklenmedi' : '$total görev · $done tamamlandı',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(width: AppSizes.lg),
        if (total > 0)
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusPill),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: colors.border,
                  valueColor: AlwaysStoppedAnimation(TaskStatus.done.color),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Mobil: tek seferde bir sütun, üstte pill-style sekme + swipe ile geçiş.
/// Trello/Jira mobil uygulamalarının izlediği yaklaşım — dar ekranda
/// 3 sütunu yan yana sıkıştırmak yerine odağı tek sütuna verir.
class _MobileBoard extends StatefulWidget {
  final TaskLoaded state;

  const _MobileBoard({required this.state});

  @override
  State<_MobileBoard> createState() => _MobileBoardState();
}

class _MobileBoardState extends State<_MobileBoard> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.sm, AppSizes.md, AppSizes.xs),
          child: _SegmentedTabBar(
            currentIndex: _currentIndex,
            counts: [
              for (final s in TaskStatus.values) widget.state.tasksByStatus(s).length,
            ],
            onTap: _goToPage,
          ),
        ),
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            children: [
              for (final status in TaskStatus.values)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.md,
                    AppSizes.xs,
                    AppSizes.md,
                    AppSizes.md,
                  ),
                  child: KanbanColumn(
                    status: status,
                    tasks: widget.state.tasksByStatus(status),
                    width: double.infinity,
                    showMargin: false,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// iOS tarzı, kayan arka planlı segmented control. Aktif sekme dolgu
/// renkli bir "pill" ile vurgulanır ve seçim değiştiğinde bu pill
/// yumuşakça kayar.
class _SegmentedTabBar extends StatelessWidget {
  final int currentIndex;
  final List<int> counts;
  final ValueChanged<int> onTap;

  const _SegmentedTabBar({
    required this.currentIndex,
    required this.counts,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statuses = TaskStatus.values;
    final segmentCount = statuses.length;

    return Container(
      height: AppSizes.minTouchTarget,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: colors.border),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final segmentWidth = constraints.maxWidth / segmentCount;

          return Stack(
            children: [
              // Kayan, aktif sekmeyi işaretleyen dolgu pill.
              AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  segmentCount == 1 ? 0 : -1 + (2 * currentIndex / (segmentCount - 1)),
                  0,
                ),
                child: Container(
                  width: segmentWidth,
                  decoration: BoxDecoration(
                    color: statuses[currentIndex].color,
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < segmentCount; i++)
                    Expanded(
                      child: _SegmentLabel(
                        label: statuses[i].label,
                        count: counts[i],
                        isSelected: currentIndex == i,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentLabel extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentLabel({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: double.infinity,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: isSelected ? colors.textOnPrimary : colors.textSecondary,
                  fontSize: 12,
                ),
            child: Text(
              count > 0 ? '$label  $count' : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
