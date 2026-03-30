import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_setup_store.dart';
import 'package:boilerplate/presentation/brand_setup/widgets/section_card.dart';
import 'package:boilerplate/presentation/brand_setup/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BrandSetupScreen extends StatefulWidget {
  const BrandSetupScreen({super.key});

  @override
  State<BrandSetupScreen> createState() => _BrandSetupScreenState();
}

class _BrandSetupScreenState extends State<BrandSetupScreen> {
  late final BrandSetupStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<BrandSetupStore>();
    _store.loadMockData();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 1100;
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Brand Setup & Configuration',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPageHeader(),
                  const SizedBox(height: 14.0),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBrandProfile()),
                        const SizedBox(width: 12.0),
                        Expanded(child: _buildKnowledgeBase()),
                      ],
                    )
                  else ...[
                    _buildBrandProfile(),
                    const SizedBox(height: 12.0),
                    _buildKnowledgeBase(),
                  ],
                  const SizedBox(height: 12.0),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildLinks()),
                        const SizedBox(width: 12.0),
                        Expanded(child: _buildRewriteRules()),
                      ],
                    )
                  else ...[
                    _buildLinks(),
                    const SizedBox(height: 12.0),
                    _buildRewriteRules(),
                  ],
                  const SizedBox(height: 12.0),
                  _buildLlmMonitoring(),
                  const SizedBox(height: 12.0),
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildBrandPositioning()),
                        const SizedBox(width: 12.0),
                        Expanded(child: _buildProjects()),
                      ],
                    )
                  else ...[
                    _buildBrandPositioning(),
                    const SizedBox(height: 12.0),
                    _buildProjects(),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPageHeader() {
    final profile = _store.profile;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield_outlined,
                      color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Brand Setup & Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure brand profile, knowledge base, links, rewrites, and LLM monitoring in one place.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildMetaPill(
                    '${_store.knowledgeBase.length} knowledge bases'),
                _buildMetaPill('${_store.links.length} tracked links'),
                _buildMetaPill(
                    '${_store.enabledLlmCount}/${_store.llmConfigs.length} LLMs on'),
                if (profile != null)
                  _buildMetaPill(profile.industry, icon: Icons.apartment),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandProfile() {
    final profile = _store.profile;
    if (profile == null) return const SizedBox.shrink();

    return SectionCard(
      title: 'Brand profile',
      subtitle: 'Identity and verification',
      actions: [
        _buildGhostButton('Edit profile'),
        _buildPrimaryButton('Verify domain'),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              profile.logoUrl,
              width: 68,
              height: 68,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        profile.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (profile.verified)
                      const StatusChip(
                        label: 'Verified',
                        color: Color(0xFFD1FAE5),
                        textColor: Color(0xFF047857),
                        icon: Icons.verified,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  profile.tagline,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(Icons.language, profile.website),
                    _buildInfoChip(Icons.work_outline, profile.industry),
                    _buildInfoChip(Icons.schedule,
                        'Polling ${_store.defaultPollingMinutes}m'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBase() {
    return SectionCard(
      title: 'Knowledge base management',
      subtitle: 'Sources AI engines will read and how fresh they are',
      actions: [
        _buildPrimaryButton('Add source'),
      ],
      child: Column(
        children: _store.knowledgeBase.map((kb) {
          final color = switch (kb.status) {
            'Synced' => const Color(0xFFDCFCE7),
            'Syncing' => const Color(0xFFFFF4E5),
            _ => const Color(0xFFEFF6FF),
          };
          final textColor = switch (kb.status) {
            'Synced' => const Color(0xFF166534),
            'Syncing' => const Color(0xFF92400E),
            _ => const Color(0xFF1D4ED8),
          };
          final icon = switch (kb.status) {
            'Synced' => Icons.check_circle,
            'Syncing' => Icons.sync,
            _ => Icons.schedule,
          };
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.folder_open, color: Color(0xFF2563EB)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              kb.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          StatusChip(
                            label: kb.status,
                            color: color,
                            textColor: textColor,
                            icon: icon,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        kb.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: [
                          _buildSmallPill(
                              Icons.auto_awesome, '${kb.sources} sources'),
                          _buildSmallPill(Icons.schedule, kb.freshness),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLinks() {
    return SectionCard(
      title: 'URL link management',
      subtitle: 'Tracked domains and key endpoints',
      actions: [
        _buildGhostButton('Bulk import'),
        _buildPrimaryButton('Add URL'),
      ],
      child: Column(
        children: _store.links.asMap().entries.map((entry) {
          final index = entry.key;
          final link = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    link.type,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        link.url,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        link.label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: link.monitored,
                  onChanged: (value) => _store.toggleLink(index, value),
                  activeColor: const Color(0xFF2563EB),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRewriteRules() {
    return SectionCard(
      title: 'URL rewrite configuration',
      subtitle: 'Ensure AI crawlers resolve to canonical destinations',
      actions: [
        _buildPrimaryButton('Add rule'),
      ],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryTile(
                  'Active rules',
                  '${_store.activeRules}/${_store.rewriteRules.length}',
                  Icons.check_circle,
                  const Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryTile(
                  'Coverage',
                  'Primary + docs',
                  Icons.public,
                  const Color(0xFF2563EB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._store.rewriteRules.map((rule) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.transform, color: Colors.blue.shade500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                rule.pattern,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            StatusChip(
                              label: rule.enabled ? 'On' : 'Off',
                              color: rule.enabled
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFF3F4F6),
                              textColor: rule.enabled
                                  ? const Color(0xFF047857)
                                  : const Color(0xFF6B7280),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '→ ${rule.target}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildLlmMonitoring() {
    return SectionCard(
      title: 'LLM monitoring',
      subtitle: 'Enable/disable engines and adjust polling frequencies',
      actions: [
        _buildGhostButton('Test prompts'),
        _buildPrimaryButton('Save preferences'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.schedule, color: Color(0xFF4338CA)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Global polling cadence',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF312E81),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Default for all engines unless overridden per engine.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_store.defaultPollingMinutes} min',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF312E81),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _store.llmConfigs.asMap().entries.map((entry) {
              final index = entry.key;
              final llm = entry.value;
              return Container(
                width: 320,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            llm.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: llm.enabled,
                          onChanged: (value) => _store.toggleLlm(index, value),
                          activeColor: const Color(0xFF2563EB),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      llm.tier,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.timer,
                            size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 6),
                        Text(
                          'Polling every ${llm.pollingMinutes} minutes',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (60 - llm.pollingMinutes) / 60,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: llm.enabled
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFCBD5E1),
                      minHeight: 6,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandPositioning() {
    final profile = _store.profile;
    return SectionCard(
      title: 'Brand positioning',
      subtitle: 'Audience, promise, and differentiators for AI answers',
      actions: [
        _buildGhostButton('Edit positioning'),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryTile('Audience', 'PMs + product marketers', Icons.people,
              const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          _buildSummaryTile('Promise', profile?.tagline ?? 'Trusted AI partner',
              Icons.bolt, const Color(0xFFF97316)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Key differentiators',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '• Search-grounded responses with citations\n• AI mention monitoring across GPT, Claude, Gemini, Perplexity\n• Rewrite and link control for brand-safe answers',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF92400E),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjects() {
    return SectionCard(
      title: 'Project management',
      subtitle: 'Organize rollout workstreams linked to AEO readiness',
      actions: [
        _buildPrimaryButton('New project'),
      ],
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _store.projects.map((project) {
          return Container(
            width: 320,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    StatusChip(
                      label: project.stage,
                      color: const Color(0xFFE0F2FE),
                      textColor: const Color(0xFF075985),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  project.focus,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.person,
                        size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 6),
                    Text(
                      project.owner,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: project.completion,
                  backgroundColor: const Color(0xFFF1F5F9),
                  color: const Color(0xFF2563EB),
                  minHeight: 6,
                ),
                const SizedBox(height: 6),
                Text(
                  '${(project.completion * 100).round()}% complete',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaPill(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF334155)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF2563EB)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGhostButton(String text) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111827),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
