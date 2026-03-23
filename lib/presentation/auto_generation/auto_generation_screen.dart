import 'package:flutter/material.dart';

class AutoGenerationScreen extends StatefulWidget {
  const AutoGenerationScreen({super.key});

  @override
  State<AutoGenerationScreen> createState() => _AutoGenerationScreenState();
}

class _AutoGenerationScreenState extends State<AutoGenerationScreen> {
  int _rowsPerPage = 10;

  // Configuration State
  final AgentConfig _socialAgentConfig = AgentConfig();
  final AgentConfig _blogAgentConfig = AgentConfig();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Auto-Generation',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ), // Assuming drawer navigation or similar
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto-Generation',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable automated content generation and track execution history.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildAgentPerformanceCard(),
            const SizedBox(height: 24),
            _buildActiveAgentsSection(),
            const SizedBox(height: 24),
            _buildExecutionHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentPerformanceCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Agent Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.show_chart, color: Colors.blue.shade400),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: CircularProgressIndicator(
                      value: 0.0, // 0%
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '0%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400, // Or theme color
                        ),
                      ),
                      Text(
                        'SUCCESS',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                'Average success rate of all agents in the last 30 days.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),
            _buildPerformanceStatItem(
              icon: Icons.check_circle_outline,
              iconColor: Colors.green,
              label: 'Success',
              count: '0',
              subLabel: 'Total articles',
            ),
            const SizedBox(height: 16),
            _buildPerformanceStatItem(
              icon: Icons.error_outline,
              iconColor: Colors.red,
              label: 'Failed',
              count: '0',
              subLabel: 'Total errors',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceStatItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String count,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            subLabel,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveAgentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Agents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ready to start your automation?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Activate and configure (optional) an agent to start generating content automatically.\nNote: You can only activate one agent at a time.',
                      style:
                          TextStyle(color: Colors.blue.shade800, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildAgentCard(
          title: 'Social Media Generator',
          description:
              'Write Social Media posts for your categories automatically.',
          status: 'INACTIVE',
          statusColor: Colors.green.shade50,
          statusTextColor: Colors.green.shade800,
          config: _socialAgentConfig,
          onConfigure: () => _showConfigureModal(
            context,
            'Social Media Generator',
            _socialAgentConfig,
          ),
        ),
        const SizedBox(height: 16),
        _buildAgentCard(
          title: 'Blog Generator',
          description:
              'Write SEO blog posts for your categories automatically.',
          status: 'INACTIVE',
          statusColor: Colors.green.shade50,
          statusTextColor: Colors.green.shade800,
          config: _blogAgentConfig,
          onConfigure: () => _showConfigureModal(
            context,
            'Blog Generator',
            _blogAgentConfig,
          ),
        ),
      ],
    );
  }

  void _showConfigureModal(
      BuildContext context, String title, AgentConfig config) {
    showDialog(
      context: context,
      builder: (context) => _ConfigureAgentModal(
        agentName: title,
        config: config,
        onSave: (newConfig) {
          setState(() {
            config.profile = newConfig.profile;
            config.selectedPrompt = newConfig.selectedPrompt;
          });
        },
      ),
    );
  }

  Widget _buildAgentCard({
    required String title,
    required String description,
    required String status,
    required Color statusColor,
    required Color statusTextColor,
    required AgentConfig config,
    required VoidCallback onConfigure,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Text(
              'LAST RUN: NEVER RUN',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100), // Orange color
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text('Activate'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onConfigure,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Configure'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Execution History',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showFilterBottomSheet(context), // Filter action
          icon: const Icon(Icons.filter_list, size: 18),
          label: const Text('Filter'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey.shade800,
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            minimumSize: const Size(double.infinity, 48),
            alignment: Alignment.center,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildTableHeader('TIME'),
                    _buildTableHeader('AGENT NAME'),
                    _buildTableHeader('ARTICLE TITLE'),
                    _buildTableHeader('STATUS'),
                    _buildTableHeader('DURATION'),
                  ],
                ),
              ),
              const Divider(height: 1),
              Container(
                height: 200,
                alignment: Alignment.center,
                child: Text(
                  'No execution history found.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '0 results',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(width: 16),
            Text(
              'Show:',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 8),
            Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _rowsPerPage,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                  style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                  onChanged: (int? newValue) {
                    setState(() {
                      _rowsPerPage = newValue!;
                    });
                  },
                  items:
                      [10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'per page',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Expanded(
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  bool _statusSuccess = false;
  bool _statusFailed = false;
  bool _statusPending = false;

  bool _agentBlog = false;
  bool _agentSocial = false;

  bool _isExecutionDateExpanded = true;
  String _lastTimeUnit = 'days';

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Filters',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _statusSuccess = false;
                          _statusFailed = false;
                          _statusPending = false;
                          _agentBlog = false;
                          _agentSocial = false;
                        });
                      },
                      child: const Text('Clear all',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Body
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildSectionTitle('Status'),
                    const SizedBox(height: 8),
                    _buildCheckbox('Success', _statusSuccess,
                        (v) => setState(() => _statusSuccess = v!)),
                    _buildCheckbox('Failed', _statusFailed,
                        (v) => setState(() => _statusFailed = v!)),
                    _buildCheckbox('Pending', _statusPending,
                        (v) => setState(() => _statusPending = v!)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Agent Type'),
                    const SizedBox(height: 8),
                    _buildCheckbox('Blog Agent', _agentBlog,
                        (v) => setState(() => _agentBlog = v!)),
                    _buildCheckbox('Social Agent', _agentSocial,
                        (v) => setState(() => _agentSocial = v!)),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => setState(() =>
                          _isExecutionDateExpanded = !_isExecutionDateExpanded),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle('Execution Date'),
                          Icon(_isExecutionDateExpanded
                              ? Icons
                                  .expand_less // Use expand_less for expanded state
                              : Icons
                                  .expand_more), // Use expand_more for collapsed
                        ],
                      ),
                    ),
                    if (_isExecutionDateExpanded) ...[
                      const SizedBox(height: 16),
                      const Text('Last', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 40,
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Enter amount',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 0),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _lastTimeUnit,
                                onChanged: (v) =>
                                    setState(() => _lastTimeUnit = v!),
                                items: ['days', 'weeks', 'months']
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
                                    .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Calendar
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFFE65100), // Orange color
                            ),
                          ),
                          child: CalendarDatePicker(
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                            onDateChanged: (date) {},
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 16, 16, MediaQuery.of(context).viewPadding.bottom + 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Apply Filters',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            height: 24,
            width: 24,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: const CircleBorder(),
              activeColor: const Color(0xFFE65100),
              side: BorderSide(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }
}

class AgentConfig {
  String? profile;
  String? selectedPrompt;

  AgentConfig({this.profile, this.selectedPrompt});
}

class _ConfigureAgentModal extends StatefulWidget {
  final String agentName;
  final AgentConfig config;
  final Function(AgentConfig) onSave;

  const _ConfigureAgentModal({
    required this.agentName,
    required this.config,
    required this.onSave,
  });

  @override
  State<_ConfigureAgentModal> createState() => _ConfigureAgentModalState();
}

class _ConfigureAgentModalState extends State<_ConfigureAgentModal> {
  late int _currentStep;
  late AgentConfig _tempConfig;

  final List<String> _profiles = [
    'Professional',
    'Casual',
    'Witty',
    'Enthusiastic',
    'Informative'
  ];

  final List<String> _prompts = [
    'compare top digital strategy firms',
    'what makes a top digital marketing agency?',
    'how to properly vet an SEO and growth agency?',
    'questions to ask a branding consultant before hiring',
    'find the best agencies for online brand building',
    'YourBrand.com official website',
  ];

  @override
  void initState() {
    super.initState();
    _currentStep = 1;
    _tempConfig = AgentConfig(
      profile: widget.config.profile,
      selectedPrompt: widget.config.selectedPrompt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure ${widget.agentName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentStep == 1
                            ? 'Define writing style and target voice for this agent.'
                            : 'Select content prompts this agent will monitor.',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Stepper
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(1, 'Writing Style'),
                Container(
                  width: 60,
                  height: 2,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),
                _buildStepIndicator(2, 'Prompts'),
              ],
            ),
          ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _currentStep == 1 ? _buildStep1() : _buildStep2(),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep == 1) ...[
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _tempConfig.profile != null
                        ? () => setState(() => _currentStep = 2)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCCBC), // Light orange
                      foregroundColor: const Color(0xFFE65100), // Dark orange
                      disabledBackgroundColor: Colors.grey.shade200,
                      disabledForegroundColor: Colors.grey.shade400,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Continue',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 1),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Go Back'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_tempConfig);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Complete Setup'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep == step;
    bool isCompleted = _currentStep > step;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive || isCompleted
                ? const Color(0xFFE65100)
                : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Text(
            step.toString(),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isActive || isCompleted ? FontWeight.bold : FontWeight.normal,
            color:
                isActive || isCompleted ? const Color(0xFFE65100) : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Content Writing Profile ',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
            children: [
              TextSpan(text: '*', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text('Select writing profile...'),
              value: _tempConfig.profile,
              onChanged: (val) => setState(() => _tempConfig.profile = val),
              items: _profiles
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose a voice and tone profile to instruct the agent on how to write.',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO TIP',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Different agents can have different profiles. For example, your Blog Agent might use a formal tone while your Social Agent uses a casual one.',
                      style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: _prompts.map((prompt) {
        bool isSelected = _tempConfig.selectedPrompt == prompt;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _tempConfig.selectedPrompt = null;
              } else {
                _tempConfig.selectedPrompt = prompt;
              }
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.shade50 : Colors.white,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? const Color(0xFFE65100) : Colors.white,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE65100)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? const Color(0xFF1E3A8A)
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'REFERENCE URL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'https://example.com/competitor-post',
                            style: TextStyle(color: Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange.shade800, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Using top search result for content inspiration.',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
