import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Horizontal chip row for selecting a date range preset.
class DateRangeSelector extends StatelessWidget {
  final String selectedRange;
  final Function(String range, {DateTime? customStart, DateTime? customEnd})
      onRangeChanged;

  const DateRangeSelector({
    Key? key,
    required this.selectedRange,
    required this.onRangeChanged,
  }) : super(key: key);

  static const _presets = ['7D', '30D', '3M', '6M', '1Y', 'Custom'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _presets.map((preset) {
          final isSelected = selectedRange == preset.toLowerCase() ||
              (preset != 'Custom' && selectedRange == preset);
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(preset),
              selected: isSelected,
              selectedColor: const Color(0xFF0052CC),
              backgroundColor: Colors.grey[100],
              labelStyle: GoogleFonts.montserrat(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 12.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF0052CC) : Colors.grey[300]!,
                ),
              ),
              onSelected: (_) async {
                if (preset == 'Custom') {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF0052CC),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    onRangeChanged(
                      'custom',
                      customStart: picked.start,
                      customEnd: picked.end,
                    );
                  }
                } else {
                  onRangeChanged(preset);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
