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
      appBar: AppBar(
        title: Text('Planning & Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Overview'),
            Text(
              'AI-powered recommendations to guide content strategy and brand optimization efforts.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            _buildSectionTitle('Gap Analysis'),
            _buildGapAnalysisCard(),
            SizedBox(height: 24),
            _buildSectionTitle('AI Suggestions & Actions'),
            _buildActionItem(
              title: 'Content Strategy Development',
              description:
                  'Create detailed articles on emerging market trends.',
              priority: 'High',
              impact: 'High',
              icon: Icons.article,
            ),
            _buildActionItem(
              title: 'Social Engagement',
              description: 'Increase engagement on social media platforms.',
              priority: 'Medium',
              impact: 'Medium',
              icon: Icons.share,
            ),
            _buildActionItem(
              title: 'Partnership Opportunities',
              description: 'Collaborate with industry influencers.',
              priority: 'Low',
              impact: 'High',
              icon: Icons.handshake,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGapAnalysisCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAnalysisRow(
                'Content Gap', 'Invest in long-form guides', Colors.orange),
            Divider(height: 24),
            _buildAnalysisRow(
                'Citations', 'Increase authoritative backlinks', Colors.blue),
            Divider(height: 24),
            _buildAnalysisRow(
                'Coverage', 'Expand to new local directories', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildActionItem({
    required String title,
    required String description,
    required String priority,
    required String impact,
    required IconData icon,
  }) {
    Color priorityColor = priority == 'High'
        ? Colors.red
        : (priority == 'Medium' ? Colors.orange : Colors.green);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(description),
              SizedBox(height: 8),
              Row(
                children: [
                  _buildTag('Priority: $priority', priorityColor),
                  SizedBox(width: 8),
                  _buildTag('Impact: $impact', Colors.blue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
