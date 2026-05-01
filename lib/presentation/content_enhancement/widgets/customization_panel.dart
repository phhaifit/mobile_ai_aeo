import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:flutter/material.dart';

/// Shows the user-controllable knobs for an enhancement run:
///   * Free-text "describe what to change" input (always visible).
///   * Tone chips — visible for enhance / rewrite / humanize.
///   * Length chips — visible only when the chosen operation is summarize.
///
/// All callbacks are required: the parent (store) owns state.
class CustomizationPanel extends StatelessWidget {
  final ContentOperation operation;
  final String? selectedTone;
  final String selectedLength;
  final String customInstruction;
  final Color accentColor;
  final ValueChanged<String?> onToneChanged;
  final ValueChanged<String> onLengthChanged;
  final ValueChanged<String> onInstructionChanged;

  const CustomizationPanel({
    Key? key,
    required this.operation,
    required this.selectedTone,
    required this.selectedLength,
    required this.customInstruction,
    required this.accentColor,
    required this.onToneChanged,
    required this.onLengthChanged,
    required this.onInstructionChanged,
  }) : super(key: key);

  static const _tones = <_Option>[
    _Option('professional', 'Professional', Icons.business_center_outlined),
    _Option('casual', 'Casual', Icons.weekend_outlined),
    _Option('friendly', 'Friendly', Icons.sentiment_satisfied),
    _Option('formal', 'Formal', Icons.school_outlined),
    _Option('playful', 'Playful', Icons.celebration_outlined),
  ];

  static const _lengths = <_Option>[
    _Option('short', 'Short', Icons.short_text),
    _Option('medium', 'Medium', Icons.notes),
    _Option('long', 'Long', Icons.subject),
  ];

  @override
  Widget build(BuildContext context) {
    final isSummarize = operation == ContentOperation.summarize;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              const Text(
                'Customize the AI output',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              const Spacer(),
              Text(
                'Optional',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLabel('Tell the AI what to focus on', Icons.edit_note_outlined),
          const SizedBox(height: 6),
          _buildInstructionField(),
          const SizedBox(height: 14),
          if (!isSummarize) ...[
            _buildLabel('Target tone', Icons.record_voice_over_outlined),
            const SizedBox(height: 8),
            _buildChipRow(
              options: _tones,
              selected: selectedTone,
              onSelected: (value) {
                onToneChanged(selectedTone == value ? null : value);
              },
            ),
          ] else ...[
            _buildLabel('Summary length', Icons.text_decrease_outlined),
            const SizedBox(height: 8),
            _buildChipRow(
              options: _lengths,
              selected: selectedLength,
              onSelected: (value) => onLengthChanged(value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionField() {
    return TextField(
      onChanged: onInstructionChanged,
      controller: TextEditingController(text: customInstruction)
        ..selection = TextSelection.collapsed(offset: customInstruction.length),
      maxLines: 3,
      maxLength: 500,
      style: const TextStyle(fontSize: 13, height: 1.4),
      decoration: InputDecoration(
        hintText:
            'e.g. "Keep brand mentions intact and target a Vietnamese audience"',
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: accentColor.withValues(alpha: 0.6)),
        ),
        counterStyle: TextStyle(fontSize: 10, color: Colors.grey.shade400),
      ),
    );
  }

  Widget _buildChipRow({
    required List<_Option> options,
    required String? selected,
    required ValueChanged<String> onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected == opt.value;
        return InkWell(
          onTap: () => onSelected(opt.value),
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? accentColor.withValues(alpha: 0.1)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? accentColor : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opt.icon,
                  size: 14,
                  color: isSelected ? accentColor : Colors.grey.shade500,
                ),
                const SizedBox(width: 5),
                Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? accentColor
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Option {
  final String value;
  final String label;
  final IconData icon;
  const _Option(this.value, this.label, this.icon);
}
