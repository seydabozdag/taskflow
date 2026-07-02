import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/theme_context_ext.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/entities/task_icon_type.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import 'icon_picker.dart';
import 'task_ui_extensions.dart';

/// Görev ekleme/düzenleme formunu, ekrana göre uygun şekilde açar.
///
/// Mobilde bottom sheet (tek elle kullanım, klavye doğal olarak içeriği
/// yukarı iter), masaüstünde dialog (fare ile odaklanmış bir pencere hissi)
/// — aynı `_TaskFormContent` widget'ı, sadece "kabuk" değişir.
///
/// `editingTask` verilirse form o görevin bilgileriyle dolu açılır ve
/// kaydedince `TaskUpdated` gönderir; verilmezse boş açılır ve `TaskAdded`
/// gönderir. `initialStatus`, bir sütunun altındaki "+ Görev ekle"
/// butonundan açıldığında o sütunun durumunu varsayılan seçili getirir.
Future<void> showTaskForm(
  BuildContext context, {
  TaskEntity? editingTask,
  TaskStatus? initialStatus,
}) {
  final taskBloc = context.read<TaskBloc>();

  if (Responsive.isMobile(context)) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => BlocProvider.value(
        value: taskBloc,
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
            ),
            child: _TaskFormContent(editingTask: editingTask, initialStatus: initialStatus),
          ),
        ),
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: taskBloc,
      child: Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
          child: _TaskFormContent(editingTask: editingTask, initialStatus: initialStatus),
        ),
      ),
    ),
  );
}

class _TaskFormContent extends StatefulWidget {
  final TaskEntity? editingTask;
  final TaskStatus? initialStatus;

  const _TaskFormContent({this.editingTask, this.initialStatus});

  @override
  State<_TaskFormContent> createState() => _TaskFormContentState();
}

class _TaskFormContentState extends State<_TaskFormContent> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _noteController;

  late TaskStatus _status;
  late TaskPriority _priority;
  late TaskIconType _iconType;
  late Color _labelColor;
  DateTime? _dueDate;

  bool get _isEditing => widget.editingTask != null;

  @override
  void initState() {
    super.initState();
    final task = widget.editingTask;

    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _noteController = TextEditingController(text: task?.note ?? '');

    _status = task?.status ?? widget.initialStatus ?? TaskStatus.todo;
    _priority = task?.priority ?? TaskPriority.medium;
    _iconType = task?.iconType ?? TaskIconType.general;
    _labelColor = task != null ? Color(task.labelColor) : AppColors.labelPalette[1];
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final note = _noteController.text.trim();
    final bloc = context.read<TaskBloc>();

    if (_isEditing) {
      bloc.add(TaskUpdated(
        taskId: widget.editingTask!.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
        iconType: _iconType,
        labelColor: _labelColor.toARGB32(),
        dueDate: _dueDate,
        note: note.isEmpty ? null : note,
      ));
    } else {
      bloc.add(TaskAdded(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: _status,
        priority: _priority,
        iconType: _iconType,
        labelColor: _labelColor.toARGB32(),
        dueDate: _dueDate,
        note: note.isEmpty ? null : note,
      ));
    }

    Navigator.of(context).pop();
  }

  Future<void> _pickIcon() async {
    final selected = await pickTaskIcon(context, _iconType, _labelColor);
    if (selected != null) setState(() => _iconType = selected);
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSizes.lg, AppSizes.lg, AppSizes.sm, AppSizes.md),
          child: Row(
            children: [
              TaskIconBadge(iconType: _iconType, color: _labelColor, size: 36),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Text(
                  _isEditing ? 'Görevi Düzenle' : 'Yeni Görev',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.border),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    autofocus: !_isEditing,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Görev başlığı',
                      hintText: 'Örn. Kediye mama al',
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Başlık zorunludur, lütfen bir görev adı yaz'
                        : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'Açıklama (opsiyonel)'),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  _FieldLabel('Durum'),
                  const SizedBox(height: AppSizes.sm),
                  SegmentedButton<TaskStatus>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: [
                      for (final s in TaskStatus.values)
                        ButtonSegment(value: s, label: Text(s.label)),
                    ],
                    selected: {_status},
                    onSelectionChanged: (s) => setState(() => _status = s.first),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  _FieldLabel('Öncelik'),
                  const SizedBox(height: AppSizes.sm),
                  SegmentedButton<TaskPriority>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(visualDensity: VisualDensity.compact),
                    segments: [
                      for (final p in TaskPriority.values)
                        ButtonSegment(value: p, label: Text(p.label)),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (p) => setState(() => _priority = p.first),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  _FieldLabel('İkon ve Etiket Rengi'),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    children: [
                      InkWell(
                        onTap: _pickIcon,
                        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                        child: TaskIconBadge(iconType: _iconType, color: _labelColor, size: 40),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: Wrap(
                          spacing: AppSizes.sm,
                          runSpacing: AppSizes.sm,
                          children: [
                            for (final swatch in AppColors.labelPalette)
                              _ColorSwatch(
                                color: swatch,
                                isSelected: swatch.toARGB32() == _labelColor.toARGB32(),
                                onTap: () => setState(() => _labelColor = swatch),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.lg),

                  _FieldLabel('Son Tarih'),
                  const SizedBox(height: AppSizes.sm),
                  InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm + 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                        border: Border.all(color: colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 16, color: colors.textSecondary),
                          const SizedBox(width: AppSizes.sm),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'Son tarih seçilmedi'
                                  : _formatDate(_dueDate!),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              tooltip: 'Tarihi temizle',
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () => setState(() => _dueDate = null),
                              style: IconButton.styleFrom(
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),

                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Not (opsiyonel)',
                      hintText: 'Ek hatırlatma ya da detay yazabilirsin',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, color: colors.border),
        Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Vazgeç'),
              ),
              const SizedBox(width: AppSizes.sm),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(backgroundColor: colors.primary),
                child: Text(_isEditing ? 'Kaydet' : 'Ekle'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', //
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? context.colors.textPrimary : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}
