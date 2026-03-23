import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';

/// Radio button group for selecting source type
class SourceTypeRadioGroup extends StatefulWidget {
  final SourceType selected;
  final ValueChanged<SourceType> onChanged;

  const SourceTypeRadioGroup({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<SourceTypeRadioGroup> createState() => _SourceTypeRadioGroupState();
}

class _SourceTypeRadioGroupState extends State<SourceTypeRadioGroup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Source *',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...SourceType.values.map((sourceType) {
          return RadioListTile<SourceType>(
            contentPadding: EdgeInsets.zero,
            value: sourceType,
            groupValue: widget.selected,
            onChanged: (value) {
              if (value != null) {
                widget.onChanged(value);
              }
            },
            title: Text(
              _formatSourceType(sourceType),
              style: theme.textTheme.bodyMedium,
            ),
            controlAffinity: ListTileControlAffinity.leading,
          );
        }).toList(),
      ],
    );
  }

  String _formatSourceType(SourceType sourceType) {
    final name = sourceType.toString().split('.').last;
    // Convert camelCase to Title Case
    return name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );
  }
}
