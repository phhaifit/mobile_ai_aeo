import 'package:boilerplate/presentation/topics_keywords/topic_detail/store/topic_detail_store.dart';
import 'package:boilerplate/presentation/topics_keywords/topic_detail/tabs/prompt_tab_screen.dart';
import 'package:flutter/material.dart';

class ActiveTabScreen extends StatelessWidget {
  const ActiveTabScreen({
    super.key,
    required this.searchController,
    required this.prompts,
    required this.onOpenFilters,
    required this.onOpenAddPrompt,
    required this.onRefreshPrompt,
    required this.onDeletePrompt,
    required this.formatCreatedDate,
  });

  final TextEditingController searchController;
  final List<PromptItem> prompts;
  final VoidCallback onOpenFilters;
  final VoidCallback onOpenAddPrompt;
  final ValueChanged<PromptItem> onRefreshPrompt;
  final ValueChanged<PromptItem> onDeletePrompt;
  final String Function(DateTime) formatCreatedDate;

  @override
  Widget build(BuildContext context) {
    return PromptTabScreen(
      searchController: searchController,
      prompts: prompts,
      onOpenFilters: onOpenFilters,
      onOpenAddPrompt: onOpenAddPrompt,
      onRefreshPrompt: onRefreshPrompt,
      onDeletePrompt: onDeletePrompt,
      formatCreatedDate: formatCreatedDate,
    );
  }
}
