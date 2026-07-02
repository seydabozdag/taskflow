import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/utils/responsive.dart';

class SkeletonBoard extends StatelessWidget {
  const SkeletonBoard({super.key});

  @override
  Widget build(BuildContext context) =>
      Responsive.isMobile(context) ? const _MobileSkeleton() : const _DesktopSkeleton();
}

class _DesktopSkeleton extends StatelessWidget {
  const _DesktopSkeleton();

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.boardPadding(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ShimmerBox(height: 18, width: 200),
              const SizedBox(height: 4),
              _ShimmerBox(height: 13, width: 130),
              const SizedBox(height: AppSizes.lg),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < 3; i++) ...[
                        const _SkeletonColumn(),
                        if (i < 2) const SizedBox(width: AppSizes.columnGap),
                      ],
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

class _MobileSkeleton extends StatelessWidget {
  const _MobileSkeleton();

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.boardPadding(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: _ShimmerBox(height: AppSizes.minTouchTarget, width: double.infinity),
          ),
          const SizedBox(height: AppSizes.sm),
          for (int i = 0; i < 5; i++) ...[
            const _SkeletonCard(),
            if (i < 4) const SizedBox(height: AppSizes.sm),
          ],
        ],
      ),
    );
  }
}

class _SkeletonColumn extends StatelessWidget {
  const _SkeletonColumn();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: AppSizes.columnWidth,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Row(
                children: [
                  _ShimmerBox(height: 8, width: 8, radius: 4),
                  const SizedBox(width: AppSizes.sm),
                  _ShimmerBox(height: 12, width: 80),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: Column(
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    const _SkeletonCard(),
                    if (i < 2) const SizedBox(height: AppSizes.sm),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.cardBorderRadius),
        child: Container(
          height: 96,
          color: colors.surfaceMuted,
          child: Row(
            children: [
              Container(width: 3, color: colors.border),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 12, width: 150, color: colors.border),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 100, color: colors.border),
                      const SizedBox(height: 10),
                      Container(height: 18, width: 56, color: colors.border),
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

class _ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const _ShimmerBox({
    required this.height,
    required this.width,
    this.radius = AppSizes.radiusSm,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Shimmer.fromColors(
      baseColor: colors.surfaceMuted,
      highlightColor: colors.surface,
      child: Container(
        height: height,
        width: width == double.infinity ? null : width,
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
