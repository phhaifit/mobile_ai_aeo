import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';

/// Checkbox group for selecting publishing destinations
class DestinationCheckboxGroup extends StatefulWidget {
  final Set<PublishingDestination> selected;
  final ValueChanged<Set<PublishingDestination>> onChanged;

  const DestinationCheckboxGroup({
    Key? key,
    required this.selected,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DestinationCheckboxGroup> createState() => _DestinationCheckboxGroupState();
}

class _DestinationCheckboxGroupState extends State<DestinationCheckboxGroup> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publishing Destinations *',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...PublishingDestination.values.map((destination) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: widget.selected.contains(destination),
              onChanged: (checked) {
                final newSelected = Set<PublishingDestination>.from(widget.selected);
                if (checked == true) {
                  newSelected.add(destination);
                } else {
                  newSelected.remove(destination);
                }
                widget.onChanged(newSelected);
              },
              title: Text(
                _formatDestination(destination),
                style: theme.textTheme.bodyMedium,
              ),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          );
        }).toList(),
      ],
    );
  }

  String _formatDestination(PublishingDestination destination) {
    return destination.toString().split('.').last;
  }
}
