import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:boilerplate/presentation/template_library/widgets/profile_operation_banner.dart';

class ContentProfileFormModal extends StatefulWidget {
  final String projectId;
  final ContentProfile? profile; // null for create, not null for update
  /// Screen context that stays valid after this dialog is popped (for loading + snackbars).
  final BuildContext hostContext;
  final VoidCallback onSuccess;

  const ContentProfileFormModal({
    Key? key,
    required this.projectId,
    required this.hostContext,
    this.profile,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ContentProfileFormModal> createState() =>
      _ContentProfileFormModalState();
}

class _ContentProfileFormModalState extends State<ContentProfileFormModal> {
  static const Color _fieldFocusColor = Color(0xFF2196F3);
  static const BorderRadius _fieldRadius =
      BorderRadius.all(Radius.circular(8));

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _voiceAndToneController;
  late TextEditingController _audienceController;
  final _formKey = GlobalKey<FormState>();
  late final TemplateLibraryStore _store;

  /// Outlined fields: label always floated (like focused), hints with e.g., focus ring blue not app red primary.
  InputDecoration _profileFieldDecoration({
    required String labelText,
    required String hintText,
    int maxLines = 1,
  }) {
    final outline = OutlineInputBorder(borderRadius: _fieldRadius);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      alignLabelWithHint: maxLines > 1,
      border: outline,
      enabledBorder: OutlineInputBorder(
        borderRadius: _fieldRadius,
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _fieldRadius,
        borderSide: const BorderSide(color: _fieldFocusColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _fieldRadius,
        borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: _fieldRadius,
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.error,
          width: 2,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  void initState() {
    super.initState();
    _store = getIt<TemplateLibraryStore>();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.profile?.description ?? '');
    _voiceAndToneController =
        TextEditingController(text: widget.profile?.voiceAndTone ?? '');
    _audienceController =
        TextEditingController(text: widget.profile?.audience ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _voiceAndToneController.dispose();
    _audienceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.profile != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: _fieldFocusColor,
                  ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    isEditMode
                        ? 'Edit Content Profile'
                        : 'Create Content Profile',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: 24),

                  // Name field
                  TextFormField(
                    controller: _nameController,
                    decoration: _profileFieldDecoration(
                      labelText: 'Profile Name',
                      hintText: 'e.g: E-commerce Ambassador',
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter profile name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: _profileFieldDecoration(
                      labelText: 'Description',
                      hintText:
                          'e.g: Brand story, key benefits, tone for product pages…',
                      maxLines: 3,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter description';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Voice and Tone field
                  TextFormField(
                    controller: _voiceAndToneController,
                    maxLines: 3,
                    decoration: _profileFieldDecoration(
                      labelText: 'Voice & Tone',
                      hintText:
                          'e.g: Warm expert — short sentences, confident, no jargon…',
                      maxLines: 3,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter voice and tone';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),

                  // Audience field
                  TextFormField(
                    controller: _audienceController,
                    maxLines: 3,
                    decoration: _profileFieldDecoration(
                      labelText: 'Target Audience',
                      hintText:
                          'e.g: Online shoppers 18–40, price-sensitive, mobile-first…',
                      maxLines: 3,
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter target audience';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),

                  // Action buttons - Using Observer for reactive state
                  Observer(
                    builder: (_) => Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _store.isSavingProfile
                              ? null
                              : () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _store.isSavingProfile
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    final host = widget.hostContext;
                                    Navigator.pop(context);

                                    await Future<void>.delayed(Duration.zero);
                                    if (!host.mounted) return;

                                    showDialog<void>(
                                      context: host,
                                      barrierDismissible: false,
                                      builder: (_) => LoadingDialog(
                                        message: isEditMode
                                            ? 'Updating profile...'
                                            : 'Creating profile...',
                                      ),
                                    );

                                    try {
                                      if (isEditMode) {
                                        await _store.updateContentProfile(
                                          projectId: widget.projectId,
                                          contentProfileId: widget.profile!.id,
                                          name: _nameController.text,
                                          description:
                                              _descriptionController.text,
                                          voiceAndTone:
                                              _voiceAndToneController.text,
                                          audience: _audienceController.text,
                                        );
                                      } else {
                                        await _store.createContentProfile(
                                          projectId: widget.projectId,
                                          name: _nameController.text,
                                          description:
                                              _descriptionController.text,
                                          voiceAndTone:
                                              _voiceAndToneController.text,
                                          audience: _audienceController.text,
                                        );
                                      }

                                      if (host.mounted) {
                                        Navigator.of(host, rootNavigator: true)
                                            .pop();
                                        widget.onSuccess();
                                        showProfileOperationTopBanner(
                                          host,
                                          success: true,
                                          message: isEditMode
                                              ? 'Profile updated successfully.'
                                              : 'Profile created successfully.',
                                        );
                                      }
                                    } catch (e) {
                                      if (host.mounted) {
                                        Navigator.of(host, rootNavigator: true)
                                            .pop();
                                        final err =
                                            _store.errorStore.errorMessage
                                                .trim();
                                        showProfileOperationTopBanner(
                                          host,
                                          success: false,
                                          message: err.isNotEmpty
                                              ? 'Failed: $err'
                                              : 'Something went wrong. Please try again.',
                                        );
                                      }
                                    }
                                  }
                                },
                          child: Text(isEditMode ? 'Update' : 'Create'),
                        ),
                      ],
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
