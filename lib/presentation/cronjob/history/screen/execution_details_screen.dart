import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../util/history_utils.dart';
import '../widget/article_preview_card.dart';
import '../widget/execution_list_item.dart';
import '../widget/publishing_results_card.dart';

/// Screen displaying detailed information about a single execution
/// 
/// Shows execution metadata, generated articles, and publishing results
class ExecutionDetailsScreen extends StatefulWidget {
  final String executionId;
  final String cronjobId;
  final String? cronjobName;

  const ExecutionDetailsScreen({
    Key? key,
    required this.executionId,
    required this.cronjobId,
    this.cronjobName,
  }) : super(key: key);

  @override
  State<ExecutionDetailsScreen> createState() => _ExecutionDetailsScreenState();
}

class _ExecutionDetailsScreenState extends State<ExecutionDetailsScreen> {
  // Mock data - in real app, loaded from CronjobStore
  final MockCronjobExecution mockExecution = MockCronjobExecution(
    id: 'exec-1',
    cronjobId: 'job-1',
    executedAt: DateTime.now(),
    status: 'success',
    articleCount: 3,
    successfulDestinations: 3,
    totalDestinations: 3,
    errorMessage: null,
  );

  final List<MockGeneratedArticle> mockArticles = [
    MockGeneratedArticle(
      id: 'article-1',
      title: 'AI Trends 2026: Machine Learning Evolution',
      content: 'This is a mock article content...',
      wordCount: 850,
      paragraphCount: 3,
    ),
    MockGeneratedArticle(
      id: 'article-2',
      title: 'SEO Best Practices for Modern Websites',
      content: 'This is a mock article content...',
      wordCount: 720,
      paragraphCount: 4,
    ),
    MockGeneratedArticle(
      id: 'article-3',
      title: 'Digital Marketing in 2026',
      content: 'This is a mock article content...',
      wordCount: 950,
      paragraphCount: 5,
    ),
  ];

  final List<MockExecutionResult> mockResults = [
    MockExecutionResult(
      destination: 'Website (Blog)',
      status: 'success',
      publishedAt: DateTime.now(),
    ),
    MockExecutionResult(
      destination: 'LinkedIn',
      status: 'success',
      publishedAt: DateTime.now(),
    ),
    MockExecutionResult(
      destination: 'Facebook',
      status: 'failed',
      errorMessage: 'Rate limited - exceeded daily post limit',
    ),
  ];

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Execution Details',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(context),
                  const SizedBox(height: 20),
                  _buildArticlesSection(context),
                  const SizedBox(height: 20),
                  _buildPublishingResultsSection(context),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = mockExecution.status == 'success'
        ? Colors.green
        : mockExecution.status == 'failed'
            ? Colors.red
            : Colors.orange;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cronjobName ?? 'Cronjob',
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(
                            formatExecutionDateTime(mockExecution.executedAt),
                            style: GoogleFonts.montserrat(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        mockExecution.status == 'success'
                            ? Icons.check_circle
                            : mockExecution.status == 'failed'
                                ? Icons.cancel_rounded
                                : Icons.info_rounded,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        mockExecution.status[0].toUpperCase() + mockExecution.status.substring(1),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.article_outlined,
                  label: 'Articles',
                  value: mockExecution.articleCount.toString(),
                  theme: theme,
                ),
                _buildStatItem(
                  icon: Icons.check_circle_outline,
                  label: 'Success',
                  value: mockExecution.successfulDestinations.toString(),
                  theme: theme,
                ),
                _buildStatItem(
                  icon: Icons.publish_outlined,
                  label: 'Total',
                  value: mockExecution.totalDestinations.toString(),
                  theme: theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildArticlesSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Generated Articles',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mockArticles.length.toString(),
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (mockArticles.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No articles were generated',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          )
        else
          Column(
            children: mockArticles
                .map((article) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ArticlePreviewCard(
                        article: article,
                        onViewFull: () => _showArticleFullView(article),
                      ),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildPublishingResultsSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publishing Results',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        if (mockResults.isEmpty)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.grey.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No publishing results available',
                  style: GoogleFonts.montserrat(
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          )
        else
          Column(
            children: mockResults
                .map((result) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: PublishingResultsCard(result: result),
                    ))
                .toList(),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        if (mockExecution.status == 'failed') ...[
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showArticleFullView(MockGeneratedArticle article) {
    showDialog(
      context: context,
      builder: (context) => _buildArticleDialog(article),
    );
  }

  Widget _buildArticleDialog(MockGeneratedArticle article) {
    return AlertDialog(
      title: Text(article.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formatArticleStats(article.wordCount, article.paragraphCount),
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              article.content,
              style: const TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _handleRetry() {
    setState(() => _isLoading = true);

    // Simulate retry operation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Execution retry initiated'),
          duration: Duration(seconds: 2),
        ),
      );
    });
  }
}
