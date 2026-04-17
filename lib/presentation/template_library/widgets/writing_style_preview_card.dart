import 'package:flutter/material.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';

/// Widget for previewing content profile inline in modal
class WritingStylePreviewCard extends StatelessWidget {
  final ContentProfile profile;
  final VoidCallback onClose;

  const WritingStylePreviewCard({
    Key? key,
    required this.profile,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: VoicePreviewModal(
        profile: profile,
        onApply: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${profile.name} profile applied!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
