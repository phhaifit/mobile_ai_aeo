import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_store.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_execution_store.dart';
import 'package:boilerplate/presentation/cronjob/routes/cronjob_routes.dart';

import 'package:boilerplate/presentation/cronjob/widget/empty_state.dart';
import 'package:boilerplate/presentation/cronjob/widget/error_banner.dart';

import 'package:boilerplate/utils/locale/app_localization.dart';


/// Main screen for viewing and managing cronjobs
class CronjobListScreen extends StatefulWidget {
  const CronjobListScreen({Key? key}) : super(key: key);

  @override
  State<CronjobListScreen> createState() => _CronjobListScreenState();
}

class _CronjobListScreenState extends State<CronjobListScreen> {
  late CronjobStore _cronjobStore;
  int _pageSize = 5; // Default page size
  int _currentPage = 1; // Current page number
  
  // Filter states
  Set<String> _selectedStatuses = {}; // 'Success', 'Failed', 'Pending'
  Set<String> _selectedAgentTypes = {}; // 'Blog Agent', 'Social Agent', 'Website Agent'
  DateTimeRange? _selectedDateRange;
  
  // Temporary filter dialog states
  int _tempDateAmount = 2;
  String _tempDateUnit = 'weeks';

  @override
  void initState() {
    super.initState();
    _cronjobStore = getIt<CronjobStore>();
    
    // Load cronjobs on screen init
    _cronjobStore.loadCronjobs();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('cronjob_title'),
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        actions: [
          Observer(
            builder: (_) => _cronjobStore.isLoading
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(
                          theme.appBarTheme.foregroundColor ?? Colors.white,
                        ),
                      ),
                    ),
                  )
                : PopupMenuButton<int>(
                    icon: const Icon(Icons.help_outline),
                    offset: const Offset(0, 40),
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.tour, size: 20),
                            const SizedBox(width: 8),
                            const Text('View product tour'),
                          ],
                        ),
                        onTap: () {
                          // Handle view product tour
                        },
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.description, size: 20),
                            const SizedBox(width: 8),
                            const Text('Documentation'),
                          ],
                        ),
                        onTap: () {
                          // Handle documentation
                        },
                      ),
                      PopupMenuItem<int>(
                        value: 2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.keyboard, size: 20),
                            const SizedBox(width: 8),
                            const Text('Keyboard shortcuts'),
                          ],
                        ),
                        onTap: () {
                          // Handle keyboard shortcuts
                        },
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: const SizedBox.shrink(),
      body: Observer(
        builder: (_) {
          // Loading state
          if (_cronjobStore.isLoading && _cronjobStore.cronjobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('cronjob_error_loading'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          // Error state
          if (_cronjobStore.hasError) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  ErrorBanner(
                    message: _cronjobStore.errorMessage ?? l10n.translate('cronjob_error_loading'),
                    onDismiss: _cronjobStore.clearError,
                    onRetry: _cronjobStore.loadCronjobs,
                  ),
                  // Show new design or empty state
                  if (_cronjobStore.cronjobs.isEmpty)
                    EmptyState(onCreatePressed: _handleCreate),
                  if (_cronjobStore.cronjobs.isNotEmpty)
                    _buildCompleteLayout(),
                ],
              ),
            );
          }

          // Empty state
          if (_cronjobStore.cronjobs.isEmpty) {
            return EmptyState(onCreatePressed: _handleCreate);
          }

          // Success state - display list
          return RefreshIndicator(
            onRefresh: () => _cronjobStore.loadCronjobs(),
            color: theme.primaryColor,
            child: _buildCompleteLayout(),
          );
        },
      ),
    );
  }

  /// Build complete layout with performance, info banner, agents, and history
  Widget _buildCompleteLayout() {
    return Observer(
      builder: (_) => SingleChildScrollView(
        child: Column(
          children: [
            // Header Section with Title and Description
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Generation',
                    style: GoogleFonts.oswald(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enable automated content generation and track execution history.',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            // Performance Overview Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildPerformanceSection(),
            ),
            
            // Active Agents Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Agents',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Info Banner
                  Observer(
                    builder: (_) {
                      final hasActiveAgent = _cronjobStore.activeAgentType != null;
                      
                      if (hasActiveAgent) {
                        // Active state - show success message
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.withOpacity(0.15)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.check_circle, color: Colors.green, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '1 Agent Activated Successfully',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Your automation is now running according to your configuration.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: Colors.green,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Inactive state - show initial message
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.15)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.info_outlined, color: Colors.blue, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ready to start your automation?',
                                      style: GoogleFonts.montserrat(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Activate and configure (optional) an agent to start generating content automatically.\nNote: You can only activate one agent at a time.',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        height: 1.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Agent Cards
                  _buildAgentCards(Theme.of(context), AppLocalizations.of(context)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Execution History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Execution History',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.black87,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildExecutionHistoryTable(Theme.of(context)),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Build performance section matching the exact design
  Widget _buildPerformanceSection() {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agent Performance',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Icon(Icons.trending_up, color: Colors.blue, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            // Circular Progress Indicator with centered text
            Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Custom circular progress
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: CircleProgressPainter(
                              progress: 0.923,
                              strokeWidth: 6,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: Colors.red,
                            ),
                          ),
                        ),
                        // Text in center
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '92%',
                              style: GoogleFonts.oswald(
                                fontWeight: FontWeight.w700,
                                fontSize: 48,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'success',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Average success rate of all agents in the last 30 days.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.teal,
                    label: 'Success',
                    value: '24',
                    subtitle: 'Total articles',
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.cancel_outlined,
                    iconColor: Colors.red,
                    label: 'Failed',
                    value: '2',
                    subtitle: 'Total errors',
                    theme: theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.oswald(
                fontWeight: FontWeight.w700,
                fontSize: 28,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build 3 agent type cards
  Widget _buildAgentCards(ThemeData theme, AppLocalizations l10n) {
    final agentTypes = [
      {
        'type': 'website',
        'title': 'Auto-post to Website',
        'description': 'Write articles for your website (CMS integration)',
        'icon': Icons.language_outlined,
      },
      {
        'type': 'social',
        'title': 'Social Media Generator',
        'description': 'Write Social Media posts for your categories automatically.',
        'icon': Icons.share_outlined,
      },
      {
        'type': 'training',
        'title': 'Blog Generator',
        'description': 'Write SEO blog posts for your categories automatically.',
        'icon': Icons.newspaper_outlined,
      },
    ];
    
    return Column(
      children: agentTypes.map((agent) {
        return _buildAgentCard(
          agent: agent,
          theme: theme,
          isActive: _cronjobStore.isAgentActive(agent['type'] as String),
          onActivate: () => _handleActivateAgent(
            agent['type'] as String,
            agent['title'] as String,
          ),
        );
      }).toList(),
    );
  }

  /// Build individual agent card
  Widget _buildAgentCard({
    required Map<String, dynamic> agent,
    required ThemeData theme,
    required bool isActive,
    required VoidCallback onActivate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isActive ? Colors.deepOrange : Colors.grey.shade200,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent['title'] as String,
                          style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent['description'] as String,
                          style: GoogleFonts.montserrat(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.green.withOpacity(0.15) : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isActive ? 'ACTIVE' : 'INACTIVE',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        color: Colors.green,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 12),
              
              // Last run info
              Row(
                children: [
                  Icon(Icons.schedule_outlined, size: 12, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'LAST RUN: NEVER RUN',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              
              // Show activation info if active
              if (isActive)
              ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Agent Activated!',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              color: Colors.green,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'JUST NOW',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              color: Colors.green.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This agent will generate 100 posts per day',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          color: Colors.green.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Action buttons
              if (isActive)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handlePauseAgent(agent['type'] as String),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Pause',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleConfigureAgent(
                          agent['type'].toString().toLowerCase(),
                          agent['title'] as String,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        child: Text(
                          'Configure',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onActivate,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                        child: const Text(
                          'Activate',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleConfigureAgent(
                          agent['type'].toString().toLowerCase(),
                          agent['title'] as String,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: Colors.grey.shade400, width: 1),
                        ),
                        child: Text(
                          'Configure',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build execution history table with mock data
  Widget _buildExecutionHistoryTable(ThemeData theme) {
    // Mock execution history data
    final mockExecutions = [
      {
        'time': '2:30 PM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'How to Build a Productive Morning Routine',
        'status': 'Success',
        'duration': '2m 34s',
        'date': '2026-03-22',
      },
      {
        'time': '1:15 PM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'Top 5 Productivity Tips for Entrepreneurs',
        'status': 'Success',
        'duration': '1m 12s',
        'date': '2026-03-22',
      },
      {
        'time': '12:45 PM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Complete Guide to AI Writing Tools',
        'status': 'Success',
        'duration': '3m 45s',
        'date': '2026-03-22',
      },
      {
        'time': '11:30 AM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'Why Personal Branding Matters in 2026',
        'status': 'Failed',
        'duration': '1m 05s',
        'date': '2026-03-21',
      },
      {
        'time': '10:00 AM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Best Practices for Content Marketing',
        'status': 'Success',
        'duration': '2m 18s',
        'date': '2026-03-21',
      },
      {
        'time': '9:45 AM',
        'agent': 'Website Agent',
        'agentType': 'Website Agent',
        'title': 'SEO Strategies for 2026',
        'status': 'Success',
        'duration': '4m 15s',
        'date': '2026-03-21',
      },
      {
        'time': '8:30 AM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'The Future of Digital Marketing',
        'status': 'Failed',
        'duration': '1m 30s',
        'date': '2026-03-20',
      },
      {
        'time': '7:15 AM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'Growth Hacking Tactics That Actually Work',
        'status': 'Success',
        'duration': '2m 45s',
        'date': '2026-03-20',
      },
      {
        'time': '6:00 PM',
        'agent': 'Website Agent',
        'agentType': 'Website Agent',
        'title': 'Building High-Performing Websites',
        'status': 'Pending',
        'duration': '0m 00s',
        'date': '2026-03-20',
      },
      {
        'time': '5:30 PM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Content Strategy for SaaS Companies',
        'status': 'Success',
        'duration': '3m 22s',
        'date': '2026-03-19',
      },
      {
        'time': '4:15 PM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'Influencer Marketing Guide',
        'status': 'Success',
        'duration': '2m 10s',
        'date': '2026-03-19',
      },
      {
        'time': '3:00 PM',
        'agent': 'Website Agent',
        'agentType': 'Website Agent',
        'title': 'User Experience Best Practices',
        'status': 'Failed',
        'duration': '1m 45s',
        'date': '2026-03-19',
      },
      {
        'time': '2:30 PM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Copywriting Tips for Better Conversions',
        'status': 'Success',
        'duration': '2m 55s',
        'date': '2026-03-18',
      },
      {
        'time': '1:45 PM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'LinkedIn Content Strategy',
        'status': 'Success',
        'duration': '1m 50s',
        'date': '2026-03-18',
      },
      {
        'time': '12:30 PM',
        'agent': 'Website Agent',
        'agentType': 'Website Agent',
        'title': 'Mobile-First Design Principles',
        'status': 'Pending',
        'duration': '0m 00s',
        'date': '2026-03-18',
      },
      {
        'time': '11:15 AM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Email Marketing Automation Guide',
        'status': 'Success',
        'duration': '3m 10s',
        'date': '2026-03-17',
      },
      {
        'time': '10:30 AM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'TikTok Marketing for Brands',
        'status': 'Failed',
        'duration': '2m 20s',
        'date': '2026-03-17',
      },
      {
        'time': '9:15 AM',
        'agent': 'Website Agent',
        'agentType': 'Website Agent',
        'title': 'Web Performance Optimization',
        'status': 'Success',
        'duration': '4m 05s',
        'date': '2026-03-17',
      },
      {
        'time': '8:45 AM',
        'agent': 'Blog Agent',
        'agentType': 'Blog Agent',
        'title': 'Personal Finance Blog Writing',
        'status': 'Success',
        'duration': '2m 40s',
        'date': '2026-03-16',
      },
      {
        'time': '7:30 AM',
        'agent': 'Social Agent',
        'agentType': 'Social Agent',
        'title': 'Instagram Reels Strategy Guide',
        'status': 'Success',
        'duration': '1m 55s',
        'date': '2026-03-16',
      },
    ];

    // PHẦN 1: Filter button - OUTSIDE CARD, FULL WIDTH
    final filterButton = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: GestureDetector(
          onTap: () => _handleFilterExecutions(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _selectedStatuses.isNotEmpty || _selectedAgentTypes.isNotEmpty || _selectedDateRange != null
                    ? Colors.orange
                    : Colors.grey.shade300,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.filter_list_outlined,
                  size: 18,
                  color: _selectedStatuses.isNotEmpty || _selectedAgentTypes.isNotEmpty || _selectedDateRange != null
                      ? Colors.orange
                      : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _selectedStatuses.isNotEmpty || _selectedAgentTypes.isNotEmpty || _selectedDateRange != null
                        ? Colors.orange
                        : Colors.grey.shade600,
                  ),
                ),
                if (_selectedStatuses.isNotEmpty || _selectedAgentTypes.isNotEmpty || _selectedDateRange != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    child: Text(
                      '${_selectedStatuses.length + _selectedAgentTypes.length + (_selectedDateRange != null ? 1 : 0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    // PHẦN 2: Active filters - OUTSIDE CARD, GRAY BACKGROUND
    final activeFiltersWidget = _selectedStatuses.isNotEmpty || _selectedAgentTypes.isNotEmpty || _selectedDateRange != null
        ? Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              color: Colors.grey.shade100,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Active filters:" label
                  Text(
                    'Active filters:',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._selectedAgentTypes.map((agent) => _buildFilterTag('Agent: $agent', () {
                        setState(() {
                          _selectedAgentTypes.remove(agent);
                        });
                      })),
                      ..._selectedStatuses.map((status) => _buildFilterTag('Status: $status', () {
                        setState(() {
                          _selectedStatuses.remove(status);
                        });
                      })),
                      if (_selectedDateRange != null)
                        _buildFilterTag(
                          'Date: ${_selectedDateRange!.start.toString().split(' ')[0]} - ${_selectedDateRange!.end.toString().split(' ')[0]}',
                          () {
                            setState(() {
                              _selectedDateRange = null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedStatuses.clear();
                        _selectedAgentTypes.clear();
                        _selectedDateRange = null;
                        _currentPage = 1;
                      });
                    },
                    child: Text(
                      'Clear all',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();

    // PHẦN 3: Table - INSIDE CARD
    final tableCard = Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          
          Divider(height: 1, color: Colors.grey.shade200),
          
          // PHẦN 3: Table - SCROLLABLE HORIZONTALLY
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                // Table Header - WITH BACKGROUND AND BORDER
                Container(
                  color: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            'TIME',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: 120,
                        child: Text(
                          'AGENT NAME',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: 220,
                        child: Text(
                          'ARTICLE TITLE',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 32),
                      SizedBox(
                        width: 80,
                        child: Text(
                          'STATUS',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                
                // Table Rows with pagination
                if (mockExecutions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      'No execution history found.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                else
                  ..._getPaginatedExecutions(mockExecutions).map((entry) {
                    final execution = entry.value;
                    final isSuccess = execution['status'] == 'Success';
                    return _buildExecutionRowScrollable(execution, theme, isSuccess, () => _handleExecutionRowTap(execution));
                  }).toList(),
              ],
            ),
          ),

          // Pagination footer
          Divider(height: 1, color: Colors.grey.shade200),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _buildPaginationFooter(mockExecutions, theme),
          ),
        ],
      ),
    );

    // Return all 3 parts: filter button + active filters + table card
    // Filter and active filters are OUTSIDE the card
    return Column(
      children: [
        filterButton,
        activeFiltersWidget,
        tableCard,
      ],
    );
  }

  /// Build execution history row with fixed width columns for horizontal scroll
  Widget _buildExecutionRowScrollable(
    Map<String, dynamic> execution,
    ThemeData theme,
    bool isSuccess,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TIME - 80px width
                SizedBox(
                  width: 80,
                  child: Text(
                    execution['time'] as String? ?? '',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 32),
                // AGENT NAME - 120px width
                SizedBox(
                  width: 120,
                  child: Text(
                    execution['agent'] as String,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 32),
                // ARTICLE TITLE - 220px width
                SizedBox(
                  width: 220,
                  child: Text(
                    execution['title'] as String,
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 32),
                // STATUS - 80px width
                SizedBox(
                  width: 80,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      execution['status'] as String,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSuccess ? Colors.green : Colors.red,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  // ============================================================================
  // Event Handlers
  // ============================================================================

  /// Handle activate agent
  Future<void> _handleActivateAgent(String agentType, String agentTitle) async {
    if (!mounted) return;
    
    final config = {
      'source': 'prompt',
      'profile': 'Professional Authority',
    };
    
    _cronjobStore.activateAgent(agentType, config);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$agentTitle activated successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle pause agent
  void _handlePauseAgent(String agentType) {
    _cronjobStore.deactivateAgent();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent paused'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Handle create cronjob
  Future<void> _handleCreate() async {
    _cronjobStore.clearError();
    if (!mounted) return;
    Navigator.pushNamed(context, '/cronjob/create');
  }

  /// Handle agent configuration navigation
  Future<void> _handleConfigureAgent(String agentType, String agentTitle) async {
    if (!mounted) return;
    
    // Navigate to agent configuration screen
    Navigator.pushNamed(
      context,
      CronjobRoutes.agentConfigure,
      arguments: AgentConfigureArgs(
        agentType: agentType,
        agentTitle: agentTitle,
      ),
    );
  }

  /// Handle execution history row tap
  void _handleExecutionRowTap(Map<String, dynamic> execution) {
    if (!mounted) return;
    
    final agent = execution['agent'] as String;
    
    // Navigate to execution detail screen
    Navigator.pushNamed(
      context,
      CronjobRoutes.executionDetails,
      arguments: ExecutionDetailsArgs(
        executionId: 'exec_${DateTime.now().millisecondsSinceEpoch}',
        cronjobId: 'cronjob_001',
        cronjobName: agent,
      ),
    );
  }
  
  /// Handle filter executions
  void _handleFilterExecutions() {
    _showFilterDialog();
  }
  
  /// Show filter dialog
  void _showFilterDialog() {
    // Temporary state for dialog - reset each time dialog opens
    Set<String> tempStatuses = Set.from(_selectedStatuses);
    Set<String> tempAgentTypes = Set.from(_selectedAgentTypes);
    DateTimeRange? tempDateRange = _selectedDateRange;
    int tempDateAmount = _tempDateAmount;
    String tempDateUnit = _tempDateUnit;
    
    // Auto-calculate date range from "Last X weeks/months/etc"
    if (tempDateAmount > 0) {
      final now = DateTime.now();
      late DateTime startDate;
      
      switch (tempDateUnit) {
        case 'days':
          startDate = now.subtract(Duration(days: tempDateAmount - 1)); // Today is day 1
          break;
        case 'weeks':
          startDate = now.subtract(Duration(days: (tempDateAmount * 7) - 1)); // Today is day 1
          break;
        case 'months':
          startDate = DateTime(now.year, now.month - tempDateAmount, now.day);
          break;
        case 'years':
          startDate = DateTime(now.year - tempDateAmount, now.month, now.day);
          break;
      }
      
      tempDateRange = DateTimeRange(start: startDate, end: now);
    }
    
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (context, setDialogState) => _buildFilterDialog(
          tempStatuses,
          tempAgentTypes,
          tempDateRange,
          tempDateAmount,
          tempDateUnit,
          (statuses, agents, dateRange, amount, unit) {
            setDialogState(() {
              tempStatuses = statuses;
              tempAgentTypes = agents;
              tempDateRange = dateRange;
              tempDateAmount = amount;
              tempDateUnit = unit;
            });
          },
        ),
      ),
    );
  }
  
  /// Build filter dialog widget - WITH STATEFUL UPDATES
  Widget _buildFilterDialog(
    Set<String> tempStatuses,
    Set<String> tempAgentTypes,
    DateTimeRange? tempDateRange,
    int tempDateAmount,
    String tempDateUnit,
    Function(Set<String>, Set<String>, DateTimeRange?, int, String) onUpdate,
  ) {
    return AlertDialog(
      title: Text(
        'Filters',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Filter
              Text(
                'Status',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _buildCheckboxWithUpdate('Success', 'Success', tempStatuses, (newSet) {
                onUpdate(newSet, tempAgentTypes, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              _buildCheckboxWithUpdate('Failed', 'Failed', tempStatuses, (newSet) {
                onUpdate(newSet, tempAgentTypes, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              _buildCheckboxWithUpdate('Pending', 'Pending', tempStatuses, (newSet) {
                onUpdate(newSet, tempAgentTypes, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 24),
              
              // Agent Type Filter
              Text(
                'Agent Type',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _buildCheckboxWithUpdate('Blog Agent', 'Blog Agent', tempAgentTypes, (newSet) {
                onUpdate(tempStatuses, newSet, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              _buildCheckboxWithUpdate('Social Agent', 'Social Agent', tempAgentTypes, (newSet) {
                onUpdate(tempStatuses, newSet, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              _buildCheckboxWithUpdate('Website Agent', 'Website Agent', tempAgentTypes, (newSet) {
                onUpdate(tempStatuses, newSet, tempDateRange, tempDateAmount, tempDateUnit);
              }),
              
              const SizedBox(height: 24),
              Divider(color: Colors.grey.shade300),
              const SizedBox(height: 24),
              
              // Execution Date Filter
              Text(
                'Execution Date',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Last',
                style: GoogleFonts.montserrat(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              // Amount + Time unit inputs
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: TextEditingController(text: tempDateAmount.toString()),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newAmount = int.tryParse(value) ?? 1;
                        _calculateDateRangeFromAmount(
                          newAmount,
                          tempDateUnit,
                          tempStatuses,
                          tempAgentTypes,
                          onUpdate,
                        );
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: tempDateUnit,
                      isExpanded: true,
                      onChanged: (value) {
                        if (value != null) {
                          _calculateDateRangeFromAmount(
                            tempDateAmount,
                            value,
                            tempStatuses,
                            tempAgentTypes,
                            onUpdate,
                          );
                        }
                      },
                      items: [
                        const DropdownMenuItem(value: 'days', child: Text('days')),
                        const DropdownMenuItem(value: 'weeks', child: Text('weeks')),
                        const DropdownMenuItem(value: 'months', child: Text('months')),
                        const DropdownMenuItem(value: 'years', child: Text('years')),
                      ],
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Custom calendar picker with date range coloring
              _CustomCalendarPicker(
                selectedRange: tempDateRange,
                onDateChanged: (clickedDate) {
                  // Smart date range selection logic
                  late DateTimeRange newRange;
                  
                  if (tempDateRange == null) {
                    // No range yet, start new range
                    newRange = DateTimeRange(start: clickedDate, end: clickedDate);
                  } else {
                    // Already have a range
                    final clickedDateOnly = DateTime(clickedDate.year, clickedDate.month, clickedDate.day);
                    final startDateOnly = DateTime(tempDateRange.start.year, tempDateRange.start.month, tempDateRange.start.day);
                    final endDateOnly = DateTime(tempDateRange.end.year, tempDateRange.end.month, tempDateRange.end.day);
                    
                    if (clickedDateOnly.isBefore(startDateOnly)) {
                      // Clicked before start: new start date
                      newRange = DateTimeRange(start: clickedDate, end: tempDateRange.end);
                    } else if (clickedDateOnly.isAfter(endDateOnly)) {
                      // Clicked after end: new end date
                      newRange = DateTimeRange(start: tempDateRange.start, end: clickedDate);
                    } else {
                      // Clicked within range: reset to single day
                      newRange = DateTimeRange(start: clickedDate, end: clickedDate);
                    }
                  }
                  
                  onUpdate(tempStatuses, tempAgentTypes, newRange, tempDateAmount, tempDateUnit);
                },
              ),
              if (tempDateRange != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Selected: ${tempDateRange.start.toString().split(' ')[0]} to ${tempDateRange.end.toString().split(' ')[0]}',
                    style: GoogleFonts.montserrat(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Apply selected filters to main state
            Navigator.pop(context);
            setState(() {
              _selectedStatuses = tempStatuses;
              _selectedAgentTypes = tempAgentTypes;
              _selectedDateRange = tempDateRange;
              _tempDateAmount = tempDateAmount;
              _tempDateUnit = tempDateUnit;
              _currentPage = 1; // Reset to first page when filtering
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text(
            'Apply Filters',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
  
  /// Calculate date range from amount and unit, update dialog state
  void _calculateDateRangeFromAmount(
    int amount,
    String unit,
    Set<String> statuses,
    Set<String> agents,
    Function(Set<String>, Set<String>, DateTimeRange?, int, String) onUpdate,
  ) {
    if (amount <= 0) return;
    
    final now = DateTime.now();
    late DateTime startDate;
    
    switch (unit) {
      case 'days':
        startDate = now.subtract(Duration(days: amount - 1)); // Today is day 1
        break;
      case 'weeks':
        startDate = now.subtract(Duration(days: (amount * 7) - 1)); // Today is day 1
        break;
      case 'months':
        startDate = DateTime(now.year, now.month - amount, now.day);
        break;
      case 'years':
        startDate = DateTime(now.year - amount, now.month, now.day);
        break;
    }
    
    final newDateRange = DateTimeRange(start: startDate, end: now);
    onUpdate(statuses, agents, newDateRange, amount, unit);
  }
  
  /// Build checkbox with realtime update callback
  Widget _buildCheckboxWithUpdate(
    String label,
    String value,
    Set<String> selectedSet,
    Function(Set<String>) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Checkbox(
            value: selectedSet.contains(value),
            activeColor: Colors.orange,
            checkColor: Colors.white,
            onChanged: (bool? newValue) {
              final Set<String> newSet = Set.from(selectedSet);
              if (newValue == true) {
                newSet.add(value);
              } else {
                newSet.remove(value);
              }
              onChanged(newSet);
            },
          ),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  /// Build filter tag chip with remove button
  Widget _buildFilterTag(String label, VoidCallback onRemove) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.deepOrange.withOpacity(0.1),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Icon(
              Icons.close,
              size: 14,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ),
    );
  }

  /// Build pagination footer with navigation controls - UPDATED LAYOUT
  Widget _buildPaginationFooter(
    List<Map<String, dynamic>> allExecutions,
    ThemeData theme,
  ) {
    final filteredExecutions = _getFilteredExecutions(allExecutions);
    final totalPages = filteredExecutions.isEmpty ? 0 : (filteredExecutions.length / _pageSize).ceil();
    final totalResults = filteredExecutions.length;

    return Column(
      children: [
        // Top row: Pagination navigation (MOVED UP)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous button
            GestureDetector(
              onTap: _currentPage > 1
                  ? () {
                      setState(() {
                        _currentPage--;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentPage > 1
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.chevron_left,
                  size: 16,
                  color: _currentPage > 1
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Page indicator
            Text(
              totalPages == 0 ? 'Page 0' : 'Page $_currentPage of $totalPages',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(width: 12),
            // Next button
            GestureDetector(
              onTap: _currentPage < totalPages
                  ? () {
                      setState(() {
                        _currentPage++;
                      });
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _currentPage < totalPages
                        ? Colors.grey.shade300
                        : Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: _currentPage < totalPages
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom row: Results count and page size selector
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$totalResults results',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 20),
            Text(
              'Show:',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: PopupMenuButton<int>(
                initialValue: _pageSize,
                onSelected: (value) => _handlePageSizeChange(value),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 5, child: Text('5')),
                  const PopupMenuItem(value: 10, child: Text('10')),
                  const PopupMenuItem(value: 20, child: Text('20')),
                  const PopupMenuItem(value: 50, child: Text('50')),
                ],
                child: Row(
                  children: [
                    Text(
                      '$_pageSize',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.expand_more, size: 14, color: Colors.grey.shade600),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'per page',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  /// Handle page size change
  void _handlePageSizeChange(int pageSize) {
    setState(() {
      _pageSize = pageSize;
      _currentPage = 1; // Reset to first page when changing page size
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Showing $pageSize items per page'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Get filtered executions based on selected filters
  List<Map<String, dynamic>> _getFilteredExecutions(
    List<Map<String, dynamic>> allExecutions,
  ) {
    return allExecutions.where((execution) {
      // Filter by status
      if (_selectedStatuses.isNotEmpty) {
        if (!_selectedStatuses.contains(execution['status'])) {
          return false;
        }
      }

      // Filter by agent type
      if (_selectedAgentTypes.isNotEmpty) {
        if (!_selectedAgentTypes.contains(execution['agentType'])) {
          return false;
        }
      }

      // Filter by date range
      if (_selectedDateRange != null) {
        final executionDate = DateTime.parse(execution['date'] as String);
        if (executionDate.isBefore(_selectedDateRange!.start) ||
            executionDate.isAfter(_selectedDateRange!.end)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
  
  /// Get paginated executions based on current page and page size
  List<MapEntry<int, Map<String, dynamic>>> _getPaginatedExecutions(
    List<Map<String, dynamic>> allExecutions,
  ) {
    // First apply filters
    final filteredExecutions = _getFilteredExecutions(allExecutions);
    
    final startIndex = (_currentPage - 1) * _pageSize;
    final endIndex = startIndex + _pageSize;
    
    final paginatedList = filteredExecutions.asMap().entries.toList().sublist(
      startIndex,
      endIndex > filteredExecutions.length ? filteredExecutions.length : endIndex,
    );
    
    return paginatedList;
  }
}

/// Custom Calendar Picker with month navigation
class _CustomCalendarPicker extends StatefulWidget {
  final DateTimeRange? selectedRange;
  final Function(DateTime) onDateChanged;

  const _CustomCalendarPicker({
    required this.selectedRange,
    required this.onDateChanged,
  });

  @override
  State<_CustomCalendarPicker> createState() => _CustomCalendarPickerState();
}

class _CustomCalendarPickerState extends State<_CustomCalendarPicker> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    
    // Get first day of month and number of days
    final firstDayOfMonth = DateTime(year, month, 1);
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday
    
    // Week days header
    const weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Month/Year header with navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.chevron_left, size: 18, color: Colors.grey.shade700),
                ),
              ),
              // Month/Year text
              Text(
                '${monthNames[month]} $year',
                style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              // Next button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.chevron_right, size: 18, color: Colors.grey.shade700),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Week days header
          Row(
            children: weekDays.map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar days
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: (firstWeekday + daysInMonth),
            itemBuilder: (context, index) {
              // Empty cells before month starts
              if (index < firstWeekday) {
                return const SizedBox.shrink();
              }
              
              final dayNum = index - firstWeekday + 1;
              final date = DateTime(year, month, dayNum);
              
              // Check if date is start or end date
              bool isStartDate = false;
              bool isEndDate = false;
              bool isInRange = false;
              
              if (widget.selectedRange != null) {
                final startDateOnly = DateTime(widget.selectedRange!.start.year, widget.selectedRange!.start.month, widget.selectedRange!.start.day);
                final endDateOnly = DateTime(widget.selectedRange!.end.year, widget.selectedRange!.end.month, widget.selectedRange!.end.day);
                final currentDateOnly = DateTime(year, month, dayNum);
                
                isStartDate = currentDateOnly.isAtSameMomentAs(startDateOnly);
                isEndDate = currentDateOnly.isAtSameMomentAs(endDateOnly);
                
                // Is between start and end (inclusive)
                isInRange = (currentDateOnly.isAfter(startDateOnly) || currentDateOnly.isAtSameMomentAs(startDateOnly)) &&
                           (currentDateOnly.isBefore(endDateOnly) || currentDateOnly.isAtSameMomentAs(endDateOnly));
              }
              
              return GestureDetector(
                onTap: () => widget.onDateChanged(date),
                child: Container(
                  decoration: BoxDecoration(
                    color: isStartDate || isEndDate
                        ? Colors.orange // Dark orange (#FF9800) for start/end
                        : isInRange
                            ? const Color(0xFFFFE0B2) // Light orange for middle dates
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    dayNum.toString(),
                    style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: isStartDate || isEndDate
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isStartDate || isEndDate
                              ? Colors.white
                              : Colors.black87,
                        ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Test run dialog
class _TestRunDialog extends StatefulWidget {
  final String cronjobId;
  final CronjobExecutionStore executionStore;

  const _TestRunDialog({
    required this.cronjobId,
    required this.executionStore,
  });

  @override
  State<_TestRunDialog> createState() => _TestRunDialogState();
}

class _TestRunDialogState extends State<_TestRunDialog> {
  @override
  void initState() {
    super.initState();
    // Start test run
    widget.executionStore.testRunCronjob(widget.cronjobId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(l10n.translate('cronjob_test_run')),
      content: Observer(
        builder: (_) {
          if (widget.executionStore.isExecuting) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.translate('cronjob_error_testing'),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          // Show result
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ((widget.executionStore.executionMessage ?? '').isNotEmpty)
                Text(
                  widget.executionStore.executionMessage ?? '',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${widget.executionStore.successCount}',
                              style: GoogleFonts.oswald(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.translate('cronjob_success'),
                              style: GoogleFonts.montserrat(
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${widget.executionStore.failureCount}',
                              style: GoogleFonts.oswald(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.translate('cronjob_failed'),
                              style: GoogleFonts.montserrat(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.executionStore.clearMessage();
            Navigator.pop(context);
          },
          child: Text(l10n.translate('cronjob_btn_cancel')),
        ),
      ],
    );
  }
}

/// Custom circle progress painter for showing progress without blocking center area
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color backgroundColor;
  final Color valueColor;

  CircleProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = valueColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final angle = progress * 2 * 3.14159265359;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      angle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Extension for easier list/empty checks
extension ListX<T> on List<T> {
  bool get isNotEmpty => length > 0;
}
