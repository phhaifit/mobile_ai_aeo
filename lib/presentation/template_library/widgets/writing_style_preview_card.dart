import 'package:flutter/material.dart';
import 'package:boilerplate/presentation/template_library/models/writing_style_model.dart';
import 'package:boilerplate/presentation/template_library/widgets/voice_preview_modal.dart';

/// Widget for previewing writing style inline in modal
class WritingStylePreviewCard extends StatelessWidget {
  final WritingStyleModel style;
  final VoidCallback onClose;

  const WritingStylePreviewCard({
    Key? key,
    required this.style,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: VoicePreviewModal(
        template: style,
        onApply: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${style.name} style applied!'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
