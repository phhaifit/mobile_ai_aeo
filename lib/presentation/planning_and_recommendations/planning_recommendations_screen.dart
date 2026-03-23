import 'package:flutter/material.dart';

class PlanningRecommendationsScreen extends StatefulWidget {
  @override
  _PlanningRecommendationsScreenState createState() =>
      _PlanningRecommendationsScreenState();
}

class _PlanningRecommendationsScreenState
    extends State<PlanningRecommendationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Planning & Recommendations',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () => _showDetailModal(
              context,
              'Overview',
              'AI-powered recommendations to guide content strategy and brand optimization efforts.',
              ['Analyze content gaps', 'Review AI suggestions', 'Add to your strategy']
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. GAP ANALYSIS
            _buildSectionHeader('Performance Gaps', Icons.analytics_outlined),
            _buildGapAnalysisCard(),
            const SizedBox(height: 24),

            /// 2. AI SUGGESTED ACTIONS
            _buildSectionHeader('AI Suggested Actions', Icons.auto_awesome),
            _buildActionItem(
              title: 'Update Legacy SEO Content',
              description: 'Old posts are underperforming vs competitors.',
              priority: 'High',
              impact: 'Critical',
              steps: ['Identify top 5 low-traffic posts', 'Update with 2026 data', 'Re-submit to search engines'],
            ),
            _buildActionItem(
              title: 'Create 3 Long-form Articles',
              description: 'Competitors dominate with articles >2000 words.',
              priority: 'Medium',
              impact: 'High',
              steps: ['Keyword research: AI Agents', 'Draft content', 'Add interactive charts'],
            ),
            const SizedBox(height: 24),

            /// 3. CONTENT STRATEGY
            _buildSectionHeader('Content Strategy', Icons.assignment_turned_in_outlined),
            _buildStrategyList(),
          ],
        ),
      ),
    );
  }

  /// --- CÁC COMPONENT GIAO DIỆN ---

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGapAnalysisCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProgressRow('Content Gap', 0.6, Colors.orange),
            const SizedBox(height: 16),
            _buildProgressRow('Citations', 0.8, Colors.blue),
            const SizedBox(height: 16),
            _buildProgressRow('Coverage', 0.4, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRow(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            Text('${(value * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: value, backgroundColor: color.withOpacity(0.1), color: color, minHeight: 6),
      ],
    );
  }

  // Tiện ích lấy màu theo mức độ Priority
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Widget dùng chung để hiển thị Tag (Priority / Impact)
  Widget _buildTag(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  // Widget hiển thị từng gợi ý của AI
  Widget _buildActionItem({
    required String title,
    required String description,
    required String priority,
    required String impact,
    required List<String> steps
  }) {
    return GestureDetector(
      onTap: () => _showDetailModal(context, title, description, steps),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTag('Priority', priority, _getPriorityColor(priority)),
                      _buildTag('Impact', impact, Colors.blue),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () {}, // Logic chuyển từ Suggestion sang Strategy
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue[50],
                minimumSize: const Size(60, 36),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
              ),
              child: const Text('Add', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách Content Strategy với Mock Data (đã loại bỏ Status, thêm Tags)
  Widget _buildStrategyList() {
    final mockStrategies = [
      {'title': 'Weekly AI Trend Report', 'priority': 'High', 'impact': 'High', 'steps': ['Scrape data', 'Write summary']},
      {'title': 'Social Engagement Polls', 'priority': 'Medium', 'impact': 'Low', 'steps': ['Draft 5 polls', 'Schedule on X/Twitter']},
      {'title': 'Influencer Outreach', 'priority': 'Low', 'impact': 'Medium', 'steps': ['Contact list', 'Email campaign']},
    ];

    return Column(
      children: mockStrategies.map((s) => GestureDetector(
        onTap: () => _showDetailModal(context, s['title'] as String, 'Executing strategy for ${s['title']}', s['steps'] as List<String>),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s['title'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTag('Priority', s['priority'] as String, _getPriorityColor(s['priority'] as String)),
                        _buildTag('Impact', s['impact'] as String, Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ),
      )).toList(),
    );
  }

  /// --- MODAL CHI TIẾT ---
  void _showDetailModal(BuildContext context, String title, String description, List<String> steps) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(description, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 20),
            const Text('Action Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.arrow_right, color: Colors.blueAccent, size: 20),
                  ),
                  Expanded(child: Text(step, style: const TextStyle(height: 1.4))),
                ],
              ),
            )).toList(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.all(14)),
                child: const Text('Got it', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}