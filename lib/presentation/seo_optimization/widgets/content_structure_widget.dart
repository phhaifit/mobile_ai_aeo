import '../../../domain/entity/seo/content_structure_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContentStructureWidget extends StatelessWidget {
  final List<ContentStructureItem> items;
  final bool isLoading;

  const ContentStructureWidget({
    Key? key,
    required this.items,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16.0),
          ...items.map((item) => _buildRecommendationCard(item)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: const Color(0xFFD6E4FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Color(0xFF0052CC), size: 22.0),
              const SizedBox(width: 8.0),
              Text(
                'Content Structure Optimization',
                style: GoogleFonts.oswald(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0052CC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6.0),
          Text(
            'AI-powered recommendations to improve how your content is structured for maximum AI citation probability.',
            style: GoogleFonts.montserrat(
              fontSize: 11.0,
              color: const Color(0xFF555555),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(ContentStructureItem item) {
    final config = _priorityConfig(item.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Priority indicator bar
            Container(
              width: 5.0,
              decoration: BoxDecoration(
                color: config.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12.0),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.section,
                            style: GoogleFonts.montserrat(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        _buildPriorityBadge(config),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      item.recommendation,
                      style: GoogleFonts.montserrat(
                        fontSize: 12.0,
                        color: const Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    // AI insight chip
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 12.0,
                          color: Color(0xFF0052CC),
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          'AI Recommendation',
                          style: GoogleFonts.montserrat(
                            fontSize: 10.0,
                            color: const Color(0xFF0052CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(_PriorityConfig config) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        config.label,
        style: GoogleFonts.montserrat(
          fontSize: 10.0,
          fontWeight: FontWeight.w700,
          color: config.color,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  _PriorityConfig _priorityConfig(StructurePriority priority) {
    switch (priority) {
      case StructurePriority.high:
        return _PriorityConfig(
          color: const Color(0xFFEF4444),
          label: 'High Priority',
        );
      case StructurePriority.medium:
        return _PriorityConfig(
          color: const Color(0xFFF59E0B),
          label: 'Medium Priority',
        );
      case StructurePriority.low:
        return _PriorityConfig(
          color: const Color(0xFF22C55E),
          label: 'Low Priority',
        );
    }
  }
}

class _PriorityConfig {
  final Color color;
  final String label;
  _PriorityConfig({required this.color, required this.label});
}
