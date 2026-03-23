import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';

/// Configuration screen for agent settings
/// Allows selecting content source (Prompt Library or Website)
/// and writing style profile
class AgentConfigurationScreen extends StatefulWidget {
  final String agentType; // 'website', 'social', 'training'
  final String agentTitle;

  const AgentConfigurationScreen({
    Key? key,
    required this.agentType,
    required this.agentTitle,
  }) : super(key: key);

  @override
  State<AgentConfigurationScreen> createState() => _AgentConfigurationScreenState();
}

class _AgentConfigurationScreenState extends State<AgentConfigurationScreen> {
  int _currentStep = 1;
  String? _selectedSource; // 'prompt' or 'website'
  TextEditingController? _websiteUrlController;
  String _selectedProfile = 'Professional Authority';

  @override
  void initState() {
    super.initState();
    _websiteUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _websiteUrlController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configure ${widget.agentTitle}',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        elevation: 0,
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(theme, l10n),
            const SizedBox(height: 24),

            if (_currentStep == 1) ...[
              // Step 1: Select source
              _buildSourceSelectionStep(theme, l10n),
            ] else ...[
              // Step 2: Writing style
              _buildWritingStyleStep(theme, l10n),
            ],

            const SizedBox(height: 32),

            // Navigation buttons
            Row(
              children: [
                if (_currentStep > 1)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 1) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleContinue : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      _currentStep == 2 ? l10n.translate('cronjob_btn_save') : 'Continue',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        // Step 1
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _currentStep >= 1 ? Colors.deepOrange : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    color: _currentStep >= 1 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Content Source',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: _currentStep >= 1 ? Colors.deepOrange : Colors.grey.shade600,
                fontWeight: _currentStep >= 1 ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
        // Connector line
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            child: Container(
              height: 2,
              color: _currentStep >= 2 ? Colors.deepOrange : Colors.grey.shade300,
            ),
          ),
        ),
        // Step 2
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _currentStep >= 2 ? Colors.deepOrange : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: _currentStep >= 2 ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Writing Style',
              style: GoogleFonts.montserrat(
                fontSize: 11,
                color: _currentStep >= 2 ? Colors.deepOrange : Colors.grey.shade600,
                fontWeight: _currentStep >= 2 ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceSelectionStep(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cronjob_select_source'),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 20),

        // Prompt Library Option
        _buildSourceCard(
          theme: theme,
          title: l10n.translate('cronjob_source_prompt_library'),
          description: 'Generate articles using AI prompts from our library',
          icon: Icons.library_books_outlined,
          value: 'prompt',
          selected: _selectedSource == 'prompt',
          onTap: () {
            setState(() => _selectedSource = 'prompt');
          },
        ),
        const SizedBox(height: 12),

        // Website Source Option
        _buildSourceCard(
          theme: theme,
          title: l10n.translate('cronjob_source_website'),
          description: 'Generate articles from content on a website or blog',
          icon: Icons.language_outlined,
          value: 'website',
          selected: _selectedSource == 'website',
          onTap: () {
            setState(() => _selectedSource = 'website');
          },
        ),

        if (_selectedSource == 'website') ...[
          const SizedBox(height: 20),
          Text(
            l10n.translate('cronjob_website_url'),
            style: GoogleFonts.montserrat(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _websiteUrlController,
            onChanged: (value) {
              setState(() {
                // Trigger rebuild to update Continue button state
              });
            },
            decoration: InputDecoration(
              hintText: 'https://example.com',
              prefixIcon: const Icon(Icons.link_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: Colors.grey.withOpacity(0.02),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSourceCard({
    required ThemeData theme,
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: selected ? theme.primaryColor.withOpacity(0.05) : Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? theme.primaryColor : Colors.grey.shade300,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? theme.primaryColor.withOpacity(0.2) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: selected ? theme.primaryColor : Colors.grey.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Radio<String>(
                value: value,
                groupValue: _selectedSource,
                onChanged: (_) => onTap(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWritingStyleStep(ThemeData theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.translate('cronjob_writing_style'),
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Define writing style and target voice for this agent.',
          style: GoogleFonts.montserrat(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 20),

        Row(
          children: [
            Text(
              l10n.translate('cronjob_content_profile'),
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              '*',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w700,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Content Profile Dropdown
        DropdownButtonFormField<String>(
          value: _selectedProfile,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.grey.withOpacity(0.02),
          ),
          items: [
            'Professional Authority',
            'Casual Blogger',
            'Technical Expert',
            'Storyteller',
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedProfile = newValue ?? 'Professional Authority';
            });
          },
        ),

        const SizedBox(height: 16),

        // Pro Tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.info_outlined, color: Colors.blue, size: 14),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PRO TIP',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.blue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Different agents can have different profiles. For example, your Blog Agent might use a formal tone while your Social Agent uses a casual one.',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.blue.shade700,
                        height: 1.4,
                      ),
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

  bool _canProceed() {
    if (_currentStep == 1) {
      if (_selectedSource == null) return false;
      if (_selectedSource == 'website' && _websiteUrlController!.text.isEmpty) {
        return false;
      }
      return true;
    }
    return true;
  }

  void _handleContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      // Configuration complete - save and return
      Navigator.pop(context, {
        'source': _selectedSource,
        'websiteUrl': _websiteUrlController?.text,
        'profile': _selectedProfile,
      });
    }
  }
}
