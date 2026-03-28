import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import '../util/history_utils.dart';
import '../widget/execution_list_item.dart';

/// Screen displaying execution history for a specific cronjob
/// 
/// Provides filtering by date range and status, displays execution list,
/// and navigates to execution details on selection
class CronjobHistoryScreen extends StatefulWidget {
  final String cronjobId;
  final String cronjobName;

  const CronjobHistoryScreen({
    Key? key,
    required this.cronjobId,
    required this.cronjobName,
  }) : super(key: key);

  @override
  State<CronjobHistoryScreen> createState() => _CronjobHistoryScreenState();
}

class _CronjobHistoryScreenState extends State<CronjobHistoryScreen> {
  // State variables
  late DateTimeRange _selectedDateRange; // Flutter's DateTimeRange from material.dart
  ExecutionStatusFilter _statusFilter = ExecutionStatusFilter.all;
  bool _showFilters = false;

  // Mock data - in real app, loaded from CronjobStore
  final List<MockCronjobExecution> _allExecutions = [
    MockCronjobExecution(
      id: 'exec-1',
      cronjobId: 'job-1',
      executedAt: DateTime.now(),
      status: 'success',
      articleCount: 3,
      successfulDestinations: 3,
      totalDestinations: 3,
    ),
    MockCronjobExecution(
      id: 'exec-2',
      cronjobId: 'job-1',
      executedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: 'success',
      articleCount: 3,
      successfulDestinations: 2,
      totalDestinations: 3,
    ),
    MockCronjobExecution(
      id: 'exec-3',
      cronjobId: 'job-1',
      executedAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'failed',
      articleCount: 0,
      successfulDestinations: 0,
      totalDestinations: 3,
      errorMessage: 'Network timeout',
    ),
    MockCronjobExecution(
      id: 'exec-4',
      cronjobId: 'job-1',
      executedAt: DateTime.now().subtract(const Duration(days: 3)),
      status: 'partial',
      articleCount: 2,
      successfulDestinations: 1,
      totalDestinations: 3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now().add(const Duration(days: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.translate('cronjob_execution_history'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filters',
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section (collapsible)
          if (_showFilters) _buildFilterSection(context),

          // Execution list
          Expanded(
            child: _buildExecutionList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range selector
          Text(
            'Date Range',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: DateRangePreset.values.map((preset) {
                final isSelected = _selectedDateRange.start.day == getDateRangeForPreset(preset).start.day;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(preset.label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedDateRange = getDateRangeForPreset(preset);
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: theme.primaryColor.withOpacity(0.2),
                    side: BorderSide(
                      color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Status filter
          Text(
            'Status',
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExecutionStatusFilter.values.map((filter) {
              final isSelected = _statusFilter == filter;
              return ChoiceChip(
                label: Text(
                  filter.value[0].toUpperCase() + filter.value.substring(1),
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _statusFilter = filter);
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: theme.primaryColor.withOpacity(0.2),
                side: BorderSide(
                  color: isSelected ? theme.primaryColor : Colors.grey.shade300,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Clear filters button
          TextButton.icon(
            onPressed: () {
              setState(() {
                _selectedDateRange = DateTimeRange(
                  start: DateTime.now().subtract(const Duration(days: 30)),
                  end: DateTime.now().add(const Duration(days: 1)),
                );
                _statusFilter = ExecutionStatusFilter.all;
              });
            },
            icon: const Icon(Icons.clear_rounded),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionList(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final filtered = _getFilteredExecutions();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.history_rounded,
                  size: 64,
                  color: theme.primaryColor.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                l10n.translate('cronjob_no_history'),
                style: GoogleFonts.oswald(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Try adjusting your filters',
                style: GoogleFonts.montserrat(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final execution = filtered[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: ExecutionListItem(
            execution: execution,
            onTap: () => _handleViewDetails(execution),
            onRetry: execution.status == 'failed'
                ? () => _handleRetry(execution)
                : null,
          ),
        );
      },
    );
  }

  List<MockCronjobExecution> _getFilteredExecutions() {
    return _allExecutions
        .where((e) =>
            e.executedAt.isAfter(_selectedDateRange.start) &&
            e.executedAt.isBefore(_selectedDateRange.end))
        .where((e) =>
            _statusFilter == ExecutionStatusFilter.all ||
            e.status == _statusFilter.value)
        .toList()
        ..sort((a, b) => b.executedAt.compareTo(a.executedAt));
  }

  void _handleViewDetails(MockCronjobExecution execution) {
    // Navigate to execution details screen
    // In real app: 
    // Navigator.pushNamed(
    //   context,
    //   '/cronjob/${widget.cronjobId}/execution/${execution.id}',
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View details for execution ${execution.id}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleRetry(MockCronjobExecution execution) {
    // Retry failed execution
    // In real app:
    // context.read<CronjobStore>().retryExecution(execution.id)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Retrying execution ${execution.id}...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
