import 'package:boilerplate/presentation/overview/store/overview_store.dart';
import 'package:boilerplate/presentation/template_library/widgets/loading_widgets.dart';
import 'package:flutter/material.dart';

/// Groups flat [ReferencedDomain] rows (same API mapping as before) by hostname
/// and shows each domain as a card with a stacked distribution bar + legend.
class DomainDistributionWidget extends StatelessWidget {
  final List<ReferencedDomain> domains;
  final bool isLoading;

  const DomainDistributionWidget({
    Key? key,
    required this.domains,
    this.isLoading = false,
  }) : super(key: key);

  Color _categoryColor(String category) {
    switch (category) {
      case 'ChatGPT':
        return const Color(0xFF10A37F);
      case 'Gemini':
        return const Color(0xFF4285F4);
      case 'AI Overview':
        return const Color(0xFFEA4335);
      default:
        return const Color(0xFF888888);
    }
  }

  List<_DomainDistributionGroup> _groupByDomain(List<ReferencedDomain> flat) {
    final map = <String, List<ReferencedDomain>>{};
    for (final row in flat) {
      final key = row.domain.trim();
      if (key.isEmpty) continue;
      map.putIfAbsent(key, () => []).add(row);
    }
    final groups = map.entries.map((e) {
      final segments = e.value
          .map(
            (r) => _Segment(
              category: r.category,
              mentions: r.mentions,
              color: _categoryColor(r.category),
            ),
          )
          .toList();
      final total = segments.fold<int>(0, (a, s) => a + s.mentions);
      return _DomainDistributionGroup(
        domain: e.key,
        segments: segments,
        totalMentions: total,
      );
    }).toList()
      ..sort((a, b) => b.totalMentions.compareTo(a.totalMentions));
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDomain(domains);

    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Domain distribution',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline,
                    size: 18.0, color: Color(0xFF999999)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Share of AI surface mentions by platform, grouped per root domain.',
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Each domain expands into platform splits (ChatGPT, Gemini, AI Overview).',
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.grey.shade600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: LoadingIndicator(
                  size: 44,
                  color: Color(0xFF2196F3),
                  animationType: AnimationType.ring,
                ),
              ),
            )
          else if (groups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No domain distribution data available',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: groups.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                return _DomainDistributionCard(group: groups[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _Segment {
  final String category;
  final int mentions;
  final Color color;

  _Segment({
    required this.category,
    required this.mentions,
    required this.color,
  });
}

class _DomainDistributionGroup {
  final String domain;
  final List<_Segment> segments;
  final int totalMentions;

  _DomainDistributionGroup({
    required this.domain,
    required this.segments,
    required this.totalMentions,
  });
}

class _DomainDistributionCard extends StatelessWidget {
  final _DomainDistributionGroup group;

  const _DomainDistributionCard({required this.group});

  @override
  Widget build(BuildContext context) {
    final total = group.totalMentions;
    final safeTotal = total > 0 ? total : 1;

    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, size: 18, color: Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      group.domain,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    child: Text(
                      '$total mentions',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  width: double.infinity,
                  child: Row(
                    children: [
                      for (final s in group.segments)
                        if (s.mentions > 0)
                          Expanded(
                            flex: s.mentions,
                            child: Container(
                              color: s.color,
                            ),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  for (final s in group.segments)
                    if (s.mentions > 0)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: s.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            s.category,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(100 * s.mentions / safeTotal).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            ' · ${s.mentions}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
