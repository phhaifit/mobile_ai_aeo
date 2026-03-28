import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get_it/get_it.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';

import '../../../domain/entity/cronjob/cronjob.dart';
import '../../../domain/entity/cronjob/publishing_destination.dart';
import '../../../domain/entity/cronjob/schedule.dart';
import '../../../domain/entity/cronjob/source_type.dart';
import '../store/cronjob_store.dart';
import '../util/cron_validator.dart';
import '../widget/cron_helper_widget.dart';
import '../widget/destination_checkbox_group.dart';
import '../widget/source_type_radio_group.dart';

/// Screen for creating or editing a cronjob
class CreateEditCronjobScreen extends StatefulWidget {
  final String? cronjobId;

  const CreateEditCronjobScreen({
    Key? key,
    this.cronjobId,
  }) : super(key: key);

  @override
  State<CreateEditCronjobScreen> createState() =>
      _CreateEditCronjobScreenState();
}

class _CreateEditCronjobScreenState extends State<CreateEditCronjobScreen> {
  late CronjobStore _cronjobStore;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _cronController;
  late TextEditingController _sourceUrlController;
  late TextEditingController _articleCountController;

  late ValueNotifier<Set<PublishingDestination>> _destinations;
  late ValueNotifier<SourceType> _sourceType;
  late ValueNotifier<bool> _isEnabled;
  late ValueNotifier<bool> _isDirty;

  @override
  void initState() {
    super.initState();
    _cronjobStore = GetIt.I<CronjobStore>();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _cronController = TextEditingController();
    _sourceUrlController = TextEditingController();
    _articleCountController = TextEditingController(text: '10');

    _destinations = ValueNotifier({});
    _sourceType = ValueNotifier(SourceType.promptLibrary);
    _isEnabled = ValueNotifier(true);
    _isDirty = ValueNotifier(false);

    if (widget.cronjobId != null) {
      _loadExistingCronjob();
    }
  }

  void _loadExistingCronjob() {
    final job = _cronjobStore.selectedCronjob;
    if (job != null) {
      _nameController.text = job.name;
      _descriptionController.text = job.description ?? '';
      _cronController.text = job.schedulePattern;
      _sourceUrlController.text = job.sourceUrl ?? '';
      _articleCountController.text =
          job.articleCountPerRun.toString();
      _destinations.value = Set.from(job.destinations);
      _sourceType.value = job.sourceType;
      _isEnabled.value = job.isEnabled;
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      _showError('Job name is required');
      return false;
    }

    if (_cronController.text.trim().isEmpty) {
      _showError('Cron expression is required');
      return false;
    }

    if (!CronValidator.isValid(_cronController.text)) {
      _showError('Invalid cron expression');
      return false;
    }

    if (_destinations.value.isEmpty) {
      _showError('Select at least one destination');
      return false;
    }

    final count = int.tryParse(_articleCountController.text);
    if (count == null || count < 1) {
      _showError('Article count must be > 0');
      return false;
    }

    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    try {
      final now = DateTime.now();
      final job = Cronjob(
        id: widget.cronjobId ??
            'cronjob_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        schedule: Schedule.custom,
        schedulePattern: _cronController.text.trim(),
        sourceType: _sourceType.value,
        sourceUrl: _sourceUrlController.text.trim().isEmpty
            ? null
            : _sourceUrlController.text.trim(),
        articleCountPerRun:
            int.parse(_articleCountController.text),
        destinations: _destinations.value.toList(),
        isEnabled: _isEnabled.value,
        createdAt: _cronjobStore.selectedCronjob?.createdAt ??
            now,
        updatedAt: now,
      );

      if (widget.cronjobId != null) {
        await _cronjobStore.updateCronjob(job);
      } else {
        await _cronjobStore.createCronjob(job);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    }
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true && widget.cronjobId != null) {
      try {
        await _cronjobStore.deleteCronjob(widget.cronjobId!);
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        _showError('Error: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cronController.dispose();
    _sourceUrlController.dispose();
    _articleCountController.dispose();
    _destinations.dispose();
    _sourceType.dispose();
    _isEnabled.dispose();
    _isDirty.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.cronjobId != null;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? l10n.translate('cronjob_edit_job') : l10n.translate('cronjob_create_new'),
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic Info Section
            _buildSectionCard(
              context: context,
              icon: Icons.info_outline_rounded,
              title: 'Job Information',
              children: [
                _buildProfessionalField(
                  context: context,
                  label: l10n.translate('cronjob_job_name'),
                  controller: _nameController,
                  hint: 'e.g., Daily News Publish',
                  icon: Icons.label_outline,
                ),
                const SizedBox(height: 16),
                _buildProfessionalField(
                  context: context,
                  label: l10n.translate('cronjob_description'),
                  controller: _descriptionController,
                  maxLines: 3,
                  hint: 'Describe what this job does',
                  icon: Icons.description_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Source Section
            _buildSectionCard(
              context: context,
              icon: Icons.source_outlined,
              title: 'Content Source',
              children: [
                _buildLabel(context, l10n.translate('cronjob_source_type')),
                const SizedBox(height: 12),
                ValueListenableBuilder<SourceType>(
                  valueListenable: _sourceType,
                  builder: (c, val, _) => SourceTypeRadioGroup(
                    selected: val,
                    onChanged: (v) {
                      _sourceType.value = v;
                      _isDirty.value = true;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                _buildProfessionalField(
                  context: context,
                  label: l10n.translate('cronjob_source_url'),
                  controller: _sourceUrlController,
                  hint: 'https://example.com/api',
                  icon: Icons.link_outlined,
                  isOptional: true,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Schedule Section
            _buildSectionCard(
              context: context,
              icon: Icons.schedule_outlined,
              title: 'Schedule & Execution',
              children: [
                _buildProfessionalField(
                  context: context,
                  label: l10n.translate('cronjob_schedule'),
                  controller: _cronController,
                  hint: l10n.translate('cronjob_schedule_help'),
                  icon: Icons.schedule_outlined,
                  onChanged: (_) => setState(() {}),
                ),
                if (_cronController.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: CronHelperWidget(
                        cronExpression: _cronController.text,
                        lastExecutionTime: null,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                _buildProfessionalField(
                  context: context,
                  label: l10n.translate('cronjob_articles_per_run'),
                  controller: _articleCountController,
                  keyboardType: TextInputType.number,
                  hint: '10',
                  icon: Icons.article_outlined,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Destinations Section
            _buildSectionCard(
              context: context,
              icon: Icons.publish_outlined,
              title: l10n.translate('cronjob_destinations'),
              children: [
                ValueListenableBuilder<Set<PublishingDestination>>(
                  valueListenable: _destinations,
                  builder: (c, val, _) => DestinationCheckboxGroup(
                    selected: val,
                    onChanged: (v) {
                      _destinations.value = v;
                      _isDirty.value = true;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Status Section
            _buildSectionCard(
              context: context,
              icon: Icons.toggle_on_outlined,
              title: l10n.translate('cronjob_status'),
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: _isEnabled,
                  builder: (c, val, _) => Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: val ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: val ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              val ? Icons.check_circle : Icons.pause_circle,
                              color: val ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              val ? l10n.translate('cronjob_enabled') : l10n.translate('cronjob_disabled'),
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: val,
                          onChanged: (v) {
                            _isEnabled.value = v;
                            _isDirty.value = true;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: Icon(isEdit ? Icons.save_outlined : Icons.add_rounded),
                    label: Text(isEdit ? l10n.translate('cronjob_btn_save') : l10n.translate('cronjob_btn_create')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    label: Text(l10n.translate('cronjob_btn_cancel')),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            if (isEdit) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(l10n.translate('cronjob_btn_delete')),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.primaryColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.montserrat(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildProfessionalField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    String? hint,
    IconData? icon,
    bool isOptional = false,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildLabel(context, label),
            if (isOptional)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  '(Optional)',
                  style: GoogleFonts.montserrat(
                    color: theme.textTheme.labelSmall?.color?.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.02),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
          onChanged: (value) {
            _isDirty.value = true;
            onChanged?.call(value);
          },
        ),
      ],
    );
  }
}
