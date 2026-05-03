import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../domain/entity/trend/content_item.dart';

/// Card for individual content item in the list.
class ContentItemCard extends StatelessWidget {
  final ContentItem item;

  const ContentItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateStr = item.publishedAt != null
        ? DateFormat('MMM d, yyyy').format(item.publishedAt!)
        : DateFormat('MMM d, yyyy').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                  ? Image.network(item.thumbnailUrl!, width: 56, height: 56, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderThumb())
                  : _placeholderThumb(),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(item.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(fontSize: 13.0, fontWeight: FontWeight.w600, color: Colors.black87)),
                  const SizedBox(height: 6),
                  // Status + date
                  Row(children: [
                    _statusBadge(item.completionStatus),
                    const SizedBox(width: 8),
                    Text(dateStr, style: GoogleFonts.montserrat(fontSize: 10.0, color: const Color(0xFF888888))),
                    if (item.promptType != null) ...[
                      const SizedBox(width: 8),
                      _typeBadge(item.promptType!),
                    ],
                  ]),
                  if (item.topicName != null) ...[
                    const SizedBox(height: 6),
                    Row(children: [
                      Icon(Icons.folder_outlined, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.topicName!,
                          style: GoogleFonts.montserrat(fontSize: 10.0, color: const Color(0xFF888888)),
                          overflow: TextOverflow.ellipsis)),
                    ]),
                  ],
                  if (item.targetKeywords.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 4, runSpacing: 4,
                      children: item.targetKeywords.take(3).map((kw) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0052CC).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(kw, style: GoogleFonts.montserrat(fontSize: 10.0, color: const Color(0xFF0052CC))),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderThumb() => Container(
    width: 56, height: 56,
    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
    child: Icon(Icons.article_outlined, color: Colors.grey[400], size: 24),
  );

  Widget _statusBadge(String status) {
    final isPublished = status == 'PUBLISHED';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isPublished ? 'Published' : status.toLowerCase().replaceAll('_', ' '),
        style: GoogleFonts.montserrat(fontSize: 10.0, fontWeight: FontWeight.w600,
            color: isPublished ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
      ),
    );
  }

  Widget _typeBadge(String type) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFF8B5CF6).withOpacity(0.1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(type, style: GoogleFonts.montserrat(fontSize: 10.0, color: const Color(0xFF8B5CF6), fontWeight: FontWeight.w500)),
  );
}
