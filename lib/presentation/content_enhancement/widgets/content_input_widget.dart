import 'package:flutter/material.dart';

class ContentInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;
  final ValueChanged<String>? onChanged;

  const ContentInputWidget({
    Key? key,
    required this.controller,
    required this.onClear,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          maxLines: 8,
          maxLength: 10000,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter text to process...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            contentPadding: const EdgeInsets.all(12.0),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'Clear text',
              onPressed: () {
                controller.clear();
                onClear();
              },
            ),
          ),
        ),
      ],
    );
  }
}
