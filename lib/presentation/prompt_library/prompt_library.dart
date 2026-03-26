import 'package:boilerplate/presentation/topics_keywords/topic_detail/topic_detail.dart';
import 'package:flutter/material.dart';

class PromptLibraryScreen extends StatelessWidget {
  const PromptLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TopicDetailScreen(
      topicName: 'Higher Education in IT',
      titleOverride: 'Prompt Library',
    );
  }
}
