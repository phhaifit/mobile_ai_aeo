import '../../../domain/entity/seo/internal_link_suggestion.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InternalLinkingWidget extends StatelessWidget {
  final List<InternalLinkSuggestion> suggestions;
  final bool isLoading;

  const InternalLinkingWidget({
    Key? key,
    required this.suggestions,
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
          _buildInfoBanner(),
          const SizedBox(height: 16.0),
          _buildSectionHeader(
            'Suggested Links',
            '${suggestions.length} opportunities found',
          ),
          const SizedBox(height: 12.0),
          ...suggestions.map((s) => _buildSuggestionCard(context, s)),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18.0),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              'AI has identified internal linking opportunities based on semantic similarity between your pages.',
              style: GoogleFonts.montserrat(
                fontSize: 12.0,
                color: const Color(0xFF1D4ED8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.oswald(
              fontSize: 14.0,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.montserrat(
            fontSize: 11.0,
            color: const Color(0xFF888888),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, InternalLinkSuggestion s) {
    final scoreColor = _scoreColor(s.relevanceScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(14.0),
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
          // Source → Target row
          _buildPageRow(s.sourcePage, s.targetPage),
          const SizedBox(height: 10.0),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10.0),
          // Anchor text + score + action
          Row(
            children: [
              const Icon(Icons.link, size: 14.0, color: Color(0xFF0052CC)),
              const SizedBox(width: 6.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anchor Text',
                      style: GoogleFonts.montserrat(fontSize: 10.0, color: const Color(0xFF888888)),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      '"${s.anchorText}"',
                      style: GoogleFonts.montserrat(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0052CC),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8.0),
              _buildScoreBadge(s.relevanceScore, scoreColor),
              const SizedBox(width: 10.0),
              _buildApplyButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageRow(String source, String target) {
    return Row(
      children: [
        Expanded(
          child: _buildPageBadge(
              source, const Color(0xFFF4F4F5), const Color(0xFF555555)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Icon(
            Icons.arrow_forward,
            size: 16.0,
            color: Colors.grey[400],
          ),
        ),
        Expanded(
          child: _buildPageBadge(
              target, const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
        ),
      ],
    );
  }

  Widget _buildPageBadge(String path, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Text(
        path,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.sourceCodePro(
          fontSize: 11.0,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildScoreBadge(int score, Color color) {
    return Column(
      children: [
        Text(
          '$score%',
          style: GoogleFonts.oswald(
            fontSize: 14.0,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          'relevance',
          style: GoogleFonts.montserrat(fontSize: 9.0, color: const Color(0xFFAAAAAA)),
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internal link added to queue'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF0052CC),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Icon(Icons.add, size: 16.0, color: Colors.white),
      ),
    );
  }

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF22C55E);
    if (score >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}
