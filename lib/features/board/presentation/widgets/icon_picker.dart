import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../domain/entities/task_icon_type.dart';
import 'task_ui_extensions.dart';

/// Bir ikon seçim grid'i gösterir ve seçileni döndürür.
///
/// `showDialog` her zaman çalışır — çağıran widget bir bottom sheet veya
/// dialog içinde olsa bile (Navigator, mevcut route'un üstüne yenisini
/// ekler), bu yüzden hem mobil form hem masaüstü form için tek bir
/// implementasyon yeterli.
Future<TaskIconType?> pickTaskIcon(BuildContext context, TaskIconType current, Color color) {
  return showDialog<TaskIconType>(
    context: context,
    builder: (context) => _IconPickerDialog(current: current, color: color),
  );
}

class _IconPickerDialog extends StatelessWidget {
  final TaskIconType current;
  final Color color;

  const _IconPickerDialog({required this.current, required this.color});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('İkon Seç', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSizes.md),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                mainAxisSpacing: AppSizes.sm,
                crossAxisSpacing: AppSizes.sm,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final type in TaskIconType.values)
                    _IconOption(
                      type: type,
                      color: color,
                      isSelected: type == current,
                      onTap: () => Navigator.of(context).pop(type),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconOption extends StatelessWidget {
  final TaskIconType type;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconOption({
    required this.type,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: type.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.14) : context.colors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(
              color: isSelected ? color : context.colors.border,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Icon(type.icon, color: isSelected ? color : context.colors.textSecondary),
        ),
      ),
    );
  }
}
