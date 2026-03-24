enum StructurePriority { high, medium, low }

class ContentStructureItem {
  final String section;
  final String recommendation;
  final StructurePriority priority;

  ContentStructureItem({
    required this.section,
    required this.recommendation,
    required this.priority,
  });
}
