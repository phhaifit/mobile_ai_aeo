import '../../../domain/entity/seo/topic_cluster.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TopicClusteringWidget extends StatelessWidget {
  final List<TopicCluster> clusters;
  final bool isLoading;

  const TopicClusteringWidget({
    Key? key,
    required this.clusters,
    required this.isLoading,
  }) : super(key: key);

  // A rotating palette for pillar topic accent colors
  static const List<Color> _accentColors = [
    Color(0xFF0052CC), // primary blue
    Color(0xFF0EA5E9), // sky
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFFEC4899), // pink
  ];

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
          ...clusters.asMap().entries.map(
                (entry) => _buildClusterCard(entry.value, entry.key),
              ),
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
      child: Row(
        children: [
          const Icon(Icons.hub_outlined, color: Color(0xFF0052CC), size: 28.0),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Topic Clusters',
                  style: GoogleFonts.oswald(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0052CC),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Grouped by semantic relevance using AI analysis',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: const Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClusterCard(TopicCluster cluster, int index) {
    final color = _accentColors[index % _accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pillar header
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12.0)),
              border: Border(
                left: BorderSide(color: color, width: 4.0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.star_outline_rounded, color: color, size: 18.0),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    cluster.pillarTopic,
                    style: GoogleFonts.montserrat(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 3.0),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    'Pillar Topic',
                    style: GoogleFonts.montserrat(
                      fontSize: 9.0,
                      fontWeight: FontWeight.w700,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Subtopics chips
          Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Related Topics',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.0,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: cluster.subtopics
                      .map((s) => _buildSubtopicChip(s, color))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12.0,
          color: const Color(0xFF444444),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
