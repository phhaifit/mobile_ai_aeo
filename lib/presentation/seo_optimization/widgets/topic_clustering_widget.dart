import '../../../domain/entity/seo/topic_cluster.dart';
import '../../../domain/entity/seo/cluster_job.dart';
import '../../../domain/entity/seo/cluster_plan.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A rotating palette for pillar topic accent colors
const List<Color> _accentColors = [
  Color(0xFF0052CC), // primary blue
  Color(0xFF0EA5E9), // sky
  Color(0xFF10B981), // emerald
  Color(0xFFF59E0B), // amber
  Color(0xFFEC4899), // pink
];

class TopicClusteringWidget extends StatefulWidget {
  final List<TopicCluster> clusters;
  final bool isLoading;
  final ClusterPlan? clusterPlan;
  final ClusterJob? clusterJob;
  final bool isGeneratingCluster;
  final Future<void> Function(String topic) onGeneratePlan;
  final Future<void> Function() onGenerateArticles;

  const TopicClusteringWidget({
    Key? key,
    required this.clusters,
    required this.isLoading,
    required this.clusterPlan,
    required this.clusterJob,
    required this.isGeneratingCluster,
    required this.onGeneratePlan,
    required this.onGenerateArticles,
  }) : super(key: key);

  @override
  State<TopicClusteringWidget> createState() => _TopicClusteringWidgetState();
}

class _TopicClusteringWidgetState extends State<TopicClusteringWidget> {
  final TextEditingController _topicController = TextEditingController();

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16.0),
          _buildPlanActions(context),
          const SizedBox(height: 16.0),
          if (widget.clusterPlan != null) _buildPlanSummary(widget.clusterPlan!),
          if (widget.clusterPlan != null) const SizedBox(height: 16.0),
          if (widget.clusterJob != null) _buildJobProgress(widget.clusterJob!),
          if (widget.clusterJob != null) const SizedBox(height: 16.0),
          ...widget.clusters.asMap().entries.map(
                (entry) => _buildClusterCard(entry.value, entry.key),
              ),
        ],
      ),
    );
  }

  Widget _buildPlanActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _topicController,
          decoration: const InputDecoration(
            labelText: 'Topic',
            hintText: 'e.g. AI SEO for e-commerce',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.isGeneratingCluster
                    ? null
                    : () async {
                        final topic = _topicController.text.trim();
                        if (topic.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter a topic first.'),
                            ),
                          );
                          return;
                        }
                        await widget.onGeneratePlan(topic);
                      },
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate Plan'),
              ),
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.isGeneratingCluster || widget.clusterPlan == null
                    ? null
                    : () async {
                        await widget.onGenerateArticles();
                      },
                icon: const Icon(Icons.article_outlined),
                label: const Text('Generate Articles'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlanSummary(ClusterPlan plan) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pillar Outline', style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          const SizedBox(height: 6.0),
          Text(plan.pillarOutline, style: GoogleFonts.montserrat(fontSize: 12.0)),
        ],
      ),
    );
  }

  Widget _buildJobProgress(ClusterJob job) {
    final status = job.status.name.toUpperCase();
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Generation Status: $status',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8.0),
          LinearProgressIndicator(value: (job.progress / 100).clamp(0.0, 1.0)),
          const SizedBox(height: 8.0),
          Text('${job.progress}% - ${job.message}',
              style: GoogleFonts.montserrat(fontSize: 12.0)),
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
