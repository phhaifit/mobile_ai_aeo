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
    return TextField(
      controller: controller,
      maxLines: 8,
      maxLength: 10000,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, height: 1.5),
      decoration: InputDecoration(
        hintText: 'Paste or type your content here...',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        border: InputBorder.none,
        counterText: '',
        contentPadding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(top: 4, right: 4),
          child: Align(
            alignment: Alignment.topRight,
            widthFactor: 1,
            heightFactor: 1,
            child: IconButton(
              icon: Icon(Icons.clear, size: 18, color: Colors.grey.shade400),
              tooltip: 'Clear text',
              onPressed: () {
                controller.clear();
                onClear();
              },
            ),
          ),
        ),
      ),
    );
  }
}
