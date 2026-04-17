import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/template_library/store/template_library_store.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';

class ContentProfileFormModal extends StatefulWidget {
  final String projectId;
  final ContentProfile? profile; // null for create, not null for update
  final VoidCallback onSuccess;

  const ContentProfileFormModal({
    Key? key,
    required this.projectId,
    this.profile,
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<ContentProfileFormModal> createState() =>
      _ContentProfileFormModalState();
}

class _ContentProfileFormModalState extends State<ContentProfileFormModal> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _voiceAndToneController;
  late TextEditingController _audienceController;
  final _formKey = GlobalKey<FormState>();
  late final TemplateLibraryStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<TemplateLibraryStore>();
    _nameController =
        TextEditingController(text: widget.profile?.name ?? '');
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  isEditMode ? 'Edit Content Profile' : 'Create Content Profile',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Profile Name',
                    hintText: 'e.g: E-commerce Ambassador',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText:
                        'Detailed description of this content style...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  decoration: InputDecoration(
                    labelText: 'Voice & Tone',
                    hintText:
                        'e.g: Enthusiastic, engaging, high-pressure...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  decoration: InputDecoration(
                    labelText: 'Target Audience',
                    hintText:
                        'e.g: Online shopping consumers (18-40 years old)...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                    if (mounted) {
                                      Navigator.pop(context);
                                      widget.onSuccess();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(isEditMode
                                              ? 'Profile updated successfully'
                                              : 'Profile created successfully'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Error: ${_store.errorStore.errorMessage}'),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                        child: _store.isSavingProfile
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(isEditMode ? 'Update' : 'Create'),
                      ),
                    ],
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
