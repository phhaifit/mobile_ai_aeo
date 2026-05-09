import 'package:flutter/material.dart';

/// Widget for displaying suggestion chips
class SuggestionChipsWidget extends StatelessWidget {
  final List<String> suggestions;
  final Function(String) onSuggestionTapped;

  const SuggestionChipsWidget({
    Key? key,
    required this.suggestions,
    required this.onSuggestionTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            suggestions.length,
            (index) {
              final suggestion = suggestions[index];
              return Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(suggestion),
                  onSelected: (_) => onSuggestionTapped(suggestion),
                  backgroundColor: Colors.purple.shade50,
                  side: BorderSide(
                    color: Colors.purple.shade200,
                    width: 1.5,
                  ),
                  labelStyle: TextStyle(
                    color: Colors.purple.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
