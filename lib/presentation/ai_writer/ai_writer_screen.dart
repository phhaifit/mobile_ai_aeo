import 'package:flutter/material.dart';

class WritingStyle {
  final String name;
  final String audience;
  final String voiceTone;
  final String description;

  WritingStyle({
    required this.name,
    required this.audience,
    required this.voiceTone,
    required this.description,
  });
}

class AiWriterScreen extends StatefulWidget {
  @override
  _AiWriterScreenState createState() => _AiWriterScreenState();
}

class _AiWriterScreenState extends State<AiWriterScreen> {
  // Mock Data
  final List<String> _topics = [
    'Technology',
    'Health',
    'Finance',
    'Education',
    'Travel',
    'Lifestyle',
  ];

  final Map<String, List<String>> _promptsByTopic = {
    'Technology': [
      'The Future of AI',
      'Blockchain Explained',
      'Cybersecurity Tips',
      'Latest Gadget Reviews'
    ],
    'Health': [
      'Benefits of Meditation',
      'Healthy Eating Habits',
      'Workout Routines for Beginners',
      'Mental Health Awareness'
    ],
    'Finance': [
      'Investing for Beginners',
      'How to Save Money',
      'Cryptocurrency Trends',
      'Retirement Planning'
    ],
    'Education': [
      'Online Learning Pros and Cons',
      'Study Tips for Students',
      'The Importance of Reading',
      'Learning a New Language'
    ],
    'Travel': [
      'Top Travel Destinations 2024',
      'Budget Travel Tips',
      'Solo Travel Guide',
      'Packing Checklist'
    ],
    'Lifestyle': [
      'Minimalist Living',
      'Work-Life Balance',
      'Sustainable Fashion',
      'Home Decor Ideas'
    ],
  };

  final List<WritingStyle> _writingStyles = [
    WritingStyle(
      name: 'Professional',
      audience: 'Business professionals, corporate clients, and stakeholders.',
      voiceTone:
          'Formal, objective, authoritative, and respectful. Avoids slang and overly emotional language.',
      description:
          'A standard style for business communications, reports, and official documentation.',
    ),
    WritingStyle(
      name: 'Casual',
      audience: 'Friends, family, and social media followers.',
      voiceTone:
          'Relaxed, friendly, and conversational. Uses everyday language and contractions.',
      description:
          'Great for personal blog posts, social media updates, and informal emails.',
    ),
    WritingStyle(
      name: 'Enthusiastic',
      audience: 'Potential customers, fans, and community members.',
      voiceTone:
          'Energetic, positive, and inspiring. Uses exclamation points and strong adjectives.',
      description:
          'Perfect for marketing copy, announcements, and motivational content.',
    ),
    WritingStyle(
      name: 'Informative',
      audience: 'Students, researchers, and people seeking knowledge.',
      voiceTone:
          'Clear, concise, and educational. Focuses on facts and logical explanations.',
      description:
          'Ideal for tutorials, how-to guides, and educational articles.',
    ),
    WritingStyle(
      name: 'Witty',
      audience: 'A younger or more culturally aware audience who enjoys humor.',
      voiceTone: 'Humorous, clever, and playful. Uses wordplay and irony.',
      description:
          'Suitable for entertainment blogs, creative writing, and engaging social media posts.',
    ),
    WritingStyle(
      name: 'Conversational Educator',
      audience:
          'Small business owners, marketers, and entrepreneurs aged 25-45. People looking to learn who prefer practical, actionable content over theory.',
      voiceTone:
          'Friendly, relatable, and encouraging. Casual but informative tone that is warm and enthusiastic. Uses analogies, examples, and questions to engage readers. Breaks down complex ideas into digestible pieces.',
      description:
          'A friendly, engaging writing style that simplifies complex topics into easy-to-understand content. Combines education with storytelling to keep readers engaged while delivering practical value.',
    ),
  ];

  void _addNewWritingStyle(WritingStyle newStyle) {
    setState(() {
      _writingStyles.add(newStyle);
      _selectedWritingStyle = newStyle.name;
    });
  }

  final List<String> _targetMarkets = [
    'Global',
    'USA',
    'Vietnam',
    'Japan',
    'UK',
    'Canada'
  ];

  final List<String> _languages = [
    'English',
    'Vietnamese',
    'Japanese',
    'Spanish',
    'French'
  ];

  // Dropdown values
  String? _selectedTopic;
  String? _selectedPrompt;
  String? _selectedReferencePage = 'Top 10 Search-Ranking Pages';
  String? _selectedContentType = 'Blog Post';
  String? _selectedWritingStyle;
  String? _selectedTargetMarket = 'Global';
  String? _selectedLanguage = 'English';

  // Controllers
  final TextEditingController _customUrlController = TextEditingController();
  final TextEditingController _keywordsController =
      TextEditingController(text: 'SEO, content marketing, brand visibility');

  @override
  void dispose() {
    _customUrlController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AI Writer', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Writer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Generate high-quality, SEO-optimized content for your brand in seconds.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            _buildCreateNewContentCard(),
            SizedBox(height: 24),
            _buildContentHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNewContentCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFFFF0E0),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lightbulb_outline,
                    color: Colors.orange, size: 32),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                'Create New Content',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                'Enter your topic and select content details',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 24),
            _buildLabel('Select Topic *'),
            _buildDropdown(
              hint: 'Select a topic...',
              value: _selectedTopic,
              items: _topics,
              onChanged: (val) => setState(() {
                _selectedTopic = val;
                _selectedPrompt = null; // Reset prompt when topic changes
              }),
            ),
            _buildHelperText('Choose the topic for generation.'),
            SizedBox(height: 16),
            _buildLabel('Select Prompt *'),
            IgnorePointer(
              ignoring: _selectedTopic == null,
              child: Opacity(
                opacity: _selectedTopic == null ? 0.5 : 1.0,
                child: _buildDropdown(
                  hint: 'Select a prompt...',
                  value: _selectedPrompt,
                  items: _selectedTopic != null
                      ? _promptsByTopic[_selectedTopic]
                      : [],
                  onChanged: (val) => setState(() => _selectedPrompt = val),
                ),
              ),
            ),
            _buildHelperText('Choose the prompt for generation.'),
            SizedBox(height: 16),
            _buildLabel('Select Reference Page *'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToggleButton(
                    'Top 10 Search-Ranking Pages',
                    _selectedReferencePage == 'Top 10 Search-Ranking Pages',
                    () => setState(() =>
                        _selectedReferencePage = 'Top 10 Search-Ranking Pages'),
                  ),
                  SizedBox(width: 8),
                  _buildToggleButton(
                    'Custom URL',
                    _selectedReferencePage == 'Custom URL',
                    () => setState(() => _selectedReferencePage = 'Custom URL'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_selectedReferencePage == 'Top 10 Search-Ranking Pages') ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Target Market'),
                        _buildDropdown(
                          hint: 'Select Market',
                          value: _selectedTargetMarket,
                          items: _targetMarkets,
                          onChanged: (val) =>
                              setState(() => _selectedTargetMarket = val),
                          icon: Icons.public,
                        ),
                        _buildHelperText(
                            'Choose the target market for search results.',
                            maxLines: 2),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Language'),
                        _buildDropdown(
                          hint: 'Select Language',
                          value: _selectedLanguage,
                          items: _languages,
                          onChanged: (val) =>
                              setState(() => _selectedLanguage = val),
                          icon: Icons.translate,
                        ),
                        _buildHelperText(
                            'Choose the language for search results.',
                            maxLines: 2),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.search),
                  label: Text('Search Ranking Pages'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              _buildNoReferencePagesFound(),
            ] else ...[
              TextField(
                controller: _customUrlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/article',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              _buildHelperText('Enter a URL of the page you want to reference.',
                  maxLines: 2),
            ], // Close else block
            SizedBox(height: 24),
            _buildLabel('Target Keywords'),
            TextField(
              controller: _keywordsController,
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            _buildHelperText('Separate keywords with commas.'),
            SizedBox(height: 16),
            _buildLabel('Select content type *'),
            _buildDropdown(
                hint: 'Select content type...',
                value: _selectedContentType,
                items: ['Blog Post', 'Social Media Post', 'Email'],
                onChanged: (val) => setState(() => _selectedContentType = val),
                icon: Icons.article_outlined),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Select Writing Style *'),
                TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AddWritingStyleDialog(
                          onStyleCreated: _addNewWritingStyle,
                        ),
                      );
                    },
                    icon: Icon(Icons.add, size: 16, color: Colors.orange),
                    label: Text('New', style: TextStyle(color: Colors.orange)))
              ],
            ),
            _buildDropdown(
              hint: 'Select a style...',
              value: _selectedWritingStyle,
              items: _writingStyles.map((e) => e.name).toList(),
              onChanged: (val) => setState(() => _selectedWritingStyle = val),
            ),
            if (_selectedWritingStyle != null) ...[
              SizedBox(height: 16),
              _buildWritingStyleDetails(_writingStyles
                  .firstWhere((e) => e.name == _selectedWritingStyle)),
            ],

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                child: Text('Start Workflow →',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Color(0xFFFCAA80), // Orange/Salmon color from image
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHistoryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text('Content History',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            Divider(height: 32),
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.description_outlined,
                        color: Colors.grey[400], size: 32),
                  ),
                  SizedBox(height: 16),
                  Text('No content yet',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text(
                    'Select a prompt above to see previously\ngenerated content here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text.replaceAll('*', ''),
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14),
          children: [
            if (text.contains('*'))
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(
      {required String hint,
      String? value,
      List<String>? items,
      required Function(String?) onChanged,
      IconData? icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: Colors.purple.shade300),
                SizedBox(width: 8)
              ],
              Text(hint,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
            ],
          ),
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items?.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList() ??
              [], // Empty list if no items provided yet
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildHelperText(String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 0),
      child: Text(
        text,
        style: TextStyle(color: Colors.grey[500], fontSize: 12),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey[200] : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
              color: isSelected ? Colors.grey[400]! : Colors.grey[300]!),
        ),
        child: Text(
          text,
          style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildNoReferencePagesFound() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Color(0xFFF9FAFB), // Very light grey
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: Icon(Icons.search, size: 32, color: Colors.black),
          ),
          SizedBox(height: 16),
          Text('No reference pages found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 8),
          Text(
            'Start by selecting a topic and a prompt. You can also choose a location or language if needed. When you\'re ready, click Search Ranking Pages to fetch the top 10 ranking pages.',
            textAlign: TextAlign.center,
            style:
                TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Select a page from the search results once loaded.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWritingStyleDetails(WritingStyle style) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStyleDetailRow('Name:', style.name),
          SizedBox(height: 12),
          _buildStyleDetailRow('Audience:', style.audience),
          SizedBox(height: 12),
          _buildStyleDetailRow('Voice & Tone:', style.voiceTone),
          SizedBox(height: 12),
          _buildStyleDetailRow('Description:', style.description),
        ],
      ),
    );
  }

  Widget _buildStyleDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Color(0xFF0D2B5B), // Dark blue/black color from image
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class AddWritingStyleDialog extends StatefulWidget {
  final Function(WritingStyle) onStyleCreated;

  const AddWritingStyleDialog({Key? key, required this.onStyleCreated})
      : super(key: key);

  @override
  _AddWritingStyleDialogState createState() => _AddWritingStyleDialogState();
}

class _AddWritingStyleDialogState extends State<AddWritingStyleDialog> {
  int _currentStep = 1;
  final TextEditingController _styleNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _voiceToneController = TextEditingController();
  final TextEditingController _audienceController = TextEditingController();

  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  @override
  void dispose() {
    _styleNameController.dispose();
    _descriptionController.dispose();
    _voiceToneController.dispose();
    _audienceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_formKey1.currentState!.validate()) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_formKey2.currentState!.validate()) {
        setState(() => _currentStep = 3);
      }
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  void _createStyle() {
    if (_formKey3.currentState!.validate()) {
      widget.onStyleCreated(WritingStyle(
        name: _styleNameController.text,
        description: _descriptionController.text,
        voiceTone: _voiceToneController.text,
        audience: _audienceController.text,
      ));
      Navigator.of(context).pop();
    }
  }

  bool get _isCurrentStepValid {
    switch (_currentStep) {
      case 1:
        return _styleNameController.text.trim().isNotEmpty;
      case 2:
        return _voiceToneController.text.trim().isNotEmpty;
      case 3:
        return _audienceController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24),
              _buildStepper(),
              SizedBox(height: 24),
              _buildStepContent(),
              SizedBox(height: 24),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Writing Style',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Create a new writing style for your brand',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(Icons.close, color: Colors.grey),
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
        )
      ],
    );
  }

  Widget _buildStepper() {
    return Row(
      children: [
        _buildStepIndicator(1, 'Basic Info'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 2 ? Colors.orange : Colors.grey[200],
          ),
        ),
        _buildStepIndicator(2, 'Voice & Tone'),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 3 ? Colors.orange : Colors.grey[200],
          ),
        ),
        _buildStepIndicator(3, 'Audience'),
      ],
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = _currentStep == step;
    bool isCompleted = _currentStep > step;
    Color color = isActive || isCompleted ? Colors.orange : Colors.grey[300]!;
    Color textColor =
        isActive || isCompleted ? Colors.orange : Colors.grey[400]!;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogLabel('Style Name *'),
              TextFormField(
                controller: _styleNameController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('Enter profile name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter style name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              _buildDialogLabel('Description'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: _inputDecoration(
                    'e.g. This is a writing style that combines education...'),
              ),
              SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.help_outline, size: 16, color: Colors.grey[400]),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Briefly summarize the purpose of this writing style.',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  )
                ],
              )
            ],
          ),
        );
      case 2:
        return Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogLabel('Voice & Tone *'),
              TextFormField(
                controller: _voiceToneController,
                onChanged: (_) => setState(() {}),
                maxLines: 8,
                decoration: _inputDecoration(
                    'e.g., Professional, friendly, informative'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Voice & Tone';
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      case 3:
        return Form(
          key: _formKey3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogLabel('Audience *'),
              TextFormField(
                controller: _audienceController,
                onChanged: (_) => setState(() {}),
                maxLines: 8,
                decoration: _inputDecoration(
                    'e.g., Tech-savvy professionals, small business owners'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Audience';
                  }
                  return null;
                },
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  Widget _buildFooter() {
    final bool isStepValid = _isCurrentStepValid;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep == 1)
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!)),
            ),
          )
        else
          OutlinedButton(
            onPressed: _prevStep,
            child: Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[300]!)),
            ),
          ),
        if (_currentStep < 3)
          ElevatedButton(
            onPressed: isStepValid ? _nextStep : null,
            child: Text('Next',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Color(0xFFFCAA80).withOpacity(0.5);
                  }
                  return Color(0xFFE69138); // Darker orange/brown when active
                },
              ),
              padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
              elevation: WidgetStateProperty.all(0),
            ),
          )
        else
          ElevatedButton(
            onPressed: isStepValid ? _createStyle : null,
            child: Text('Create',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return Color(0xFFFCAA80).withOpacity(0.5);
                  }
                  return Color(0xFFE69138); // Darker orange/brown when active
                },
              ),
              padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
              elevation: WidgetStateProperty.all(0),
            ),
          ),
      ],
    );
  }

  Widget _buildDialogLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text.replaceAll('*', ''),
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          children: [
            if (text.contains('*'))
              TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}
