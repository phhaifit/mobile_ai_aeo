import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- Bổ sung các Model tương ứng với dữ liệu trả về từ Backend ---

class ContentProfile {
  final String id;
  final String name;
  final String audience;
  final String voiceAndTone;
  final String description;

  ContentProfile({
    required this.id,
    required this.name,
    required this.audience,
    required this.voiceAndTone,
    required this.description,
  });

  factory ContentProfile.fromJson(Map<String, dynamic> json) {
    return ContentProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      audience: json['audience'] ?? '',
      voiceAndTone: json['voiceAndTone'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class WebSearchResponseDto {
  final String title;
  final String url;
  final String description;
  final String relevanceDescription;
  final double relevanceScore;
  final String relevanceLabel;

  WebSearchResponseDto({
    required this.title,
    required this.url,
    required this.description,
    this.relevanceDescription = '',
    this.relevanceScore = 0.0,
    this.relevanceLabel = '',
  });
}

class Prompt {
  final String id;
  final String title;
  final String content;
  Prompt({required this.id, required this.title, required this.content});
}

class CustomerPersona {
  final String id;
  final String name;
  final dynamic description;
  final Map<String, dynamic>? demographics;
  final Map<String, dynamic>? professional;
  final dynamic goalsAndMotivations;
  final dynamic painPoints;
  final Map<String, dynamic>? contentPreferences;
  final Map<String, dynamic>? buyingBehavior;
  final bool isPrimary;

  CustomerPersona({
    required this.id,
    required this.name,
    this.description,
    this.demographics,
    this.professional,
    this.goalsAndMotivations,
    this.painPoints,
    this.contentPreferences,
    this.buyingBehavior,
    this.isPrimary = false,
  });

  factory CustomerPersona.fromJson(Map<String, dynamic> json) {
    return CustomerPersona(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      demographics: json['demographics'] as Map<String, dynamic>?,
      professional: json['professional'] as Map<String, dynamic>?,
      goalsAndMotivations: json['goalsAndMotivations'],
      painPoints: json['painPoints'],
      contentPreferences: json['contentPreferences'] as Map<String, dynamic>?,
      buyingBehavior: json['buyingBehavior'] as Map<String, dynamic>?,
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class AiWriterScreen extends StatefulWidget {
  @override
  _AiWriterScreenState createState() => _AiWriterScreenState();
}

class _AiWriterScreenState extends State<AiWriterScreen> {
  // --- Mock Data đại diện cho API response ---
  String _projectId = "ca6a7019-5e93-431f-b2d8-8deabc82a8af";
  String _brandId = "28514d02-a6d4-436c-bb92-b84cc844ee6c"; // Added brandId

  // --- Real API Data properties ---
  List<Prompt> _prompts = [];
  List<ContentProfile> _contentProfiles = [];
  List<CustomerPersona> _personas = [];
  List<WebSearchResponseDto> _topPages = [];

  bool _isLoadingMetaData = false;
  bool _isSearching = false;
  bool _isGeneratingContent = false;
  String? _selectedPromptId;
  String _referenceType = "search";
  String? _selectedTopPageUrl;
  String? _selectedSearchUrl;
  String? _selectedProfileId;
  String? _selectedPersonaId;
  String _selectedContentType = "blog_post";
  String? _selectedPlatform;

  final TextEditingController _customReferenceUrlController =
      TextEditingController();
  final TextEditingController _customUrlController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  final TextEditingController _improvementController = TextEditingController();
  final TextEditingController _modificationInstructionController =
      TextEditingController();

  final List<Map<String, String>> _contentTypes = [
    {"label": "Blog Post", "value": "blog_post"},
    {"label": "Social Media Post", "value": "social_media_post"},
    {"label": "Email", "value": "email"},
  ];

  final List<Map<String, String>> _socialPlatforms = [
    {"label": "Facebook", "value": "facebook"},
    {"label": "Twitter", "value": "twitter"},
    {"label": "LinkedIn", "value": "linkedin"},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMetaData();
  }

  Future<String?> _getToken() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('jwt_token');
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIzOWY3YTBkZi1iZGFkLTQ0ZWYtYTU4NC01Y2IxZmRlZTQyNjciLCJlbWFpbCI6ImpvaG4uZG9lQGV4YW1wbGUuY29tIiwiaWF0IjoxNzc3MTIyNTgxLCJleHAiOjE3Nzk3MTQ1ODF9._y_3WDNiqsdRjunEzR0IJkA1rR8tv6YGnylsuG2V3PU';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> _fetchMetaData() async {
    setState(() {
      _isLoadingMetaData = true;
    });

    try {
      final headers = await _getHeaders();

      // Fetch Prompts
      final promptsResponse = await http.get(
        Uri.parse('https://api.aeo.how/api/projects/$_projectId/prompts'),
        headers: headers,
      );
      if (promptsResponse.statusCode == 200) {
        // Adjust this if response is paginated (e.g. { data: [...] })
        final body = jsonDecode(promptsResponse.body);
        final List<dynamic> promptsData =
            body['data'] ?? body; // assumption based on standard pagination
        _prompts = promptsData
            .map(
              (e) => Prompt(
                id: e['id'],
                title: e['content'] ??
                    '', // Sử dụng trường 'content' làm title hiển thị trên dropdown
                content: e['content'] ?? '',
              ),
            )
            .toList();
      }

      // Fetch Profiles
      final profilesResponse = await http.get(
        Uri.parse(
          'https://api.aeo.how/api/projects/$_projectId/content-profiles',
        ),
        headers: headers,
      );
      if (profilesResponse.statusCode == 200) {
        final List<dynamic> profilesData = jsonDecode(profilesResponse.body);
        _contentProfiles =
            profilesData.map((e) => ContentProfile.fromJson(e)).toList();
      }

      // Fetch Personas
      final personasResponse = await http.get(
        Uri.parse('https://api.aeo.how/api/brands/$_brandId/customer-personas'),
        headers: headers,
      );
      if (personasResponse.statusCode == 200) {
        final List<dynamic> personasData = jsonDecode(personasResponse.body);
        _personas =
            personasData.map((e) => CustomerPersona.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching metadata: $e');
    } finally {
      setState(() {
        _isLoadingMetaData = false;
      });
    }
  }

  Future<void> _fetchTopPages(String promptId) async {
    setState(() {
      _isSearching = true;
      _topPages = [];
      _selectedTopPageUrl = null;
    });

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('https://api.aeo.how/api/prompts/$promptId/top-pages'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _topPages = data
              .map(
                (e) => WebSearchResponseDto(
                  title: e['title'],
                  url: e['url'],
                  description: e['description'],
                  relevanceDescription: e['relevanceDescription'] ?? '',
                  relevanceScore:
                      (e['relevanceScore'] as num?)?.toDouble() ?? 0.0,
                  relevanceLabel: e['relevanceLabel'] ?? '',
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching top pages: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // ...existing code...
  void _addNewProfile(ContentProfile profile) {
    setState(() {
      _contentProfiles.add(profile);
      _selectedProfileId = profile.id;
    });
  }

  Future<void> _onProfileSelected(String? id) async {
    setState(() => _selectedProfileId = id);
    if (id != null) {
      try {
        final headers = await _getHeaders();
        http.get(
          Uri.parse(
            'https://api.aeo.how/api/projects/$_projectId/content-profiles/$id',
          ),
          headers: headers,
        );
      } catch (e) {
        debugPrint("Get profile details error: $e");
      }
    }
  }

  Future<void> _deleteProfile(ContentProfile p) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Are you sure you want to delete this content profile?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final headers = await _getHeaders();
        final response = await http.delete(
          Uri.parse(
            'https://api.aeo.how/api/projects/$_projectId/content-profiles/${p.id}',
          ),
          headers: headers,
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            _contentProfiles.removeWhere((e) => e.id == p.id);
            if (_selectedProfileId == p.id) _selectedProfileId = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xóa Content Profile ${p.name} thành công'),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error deleting profile: $e');
      }
    }
  }

  void _openProfileDialog([ContentProfile? profile]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddWritingStyleDialog(
        projectId: _projectId,
        profile: profile,
        getHeaders: _getHeaders,
        onStyleCreatedOrUpdated: (savedProfile) => setState(() {
          if (profile == null) {
            _contentProfiles.add(savedProfile);
            _selectedProfileId = savedProfile.id;
          } else {
            final idx = _contentProfiles.indexWhere(
              (e) => e.id == savedProfile.id,
            );
            if (idx != -1) _contentProfiles[idx] = savedProfile;
          }
        }),
      ),
    );
  }

  Future<void> _onPersonaSelected(String? id) async {
    setState(() => _selectedPersonaId = id);
    if (id != null) {
      try {
        final headers = await _getHeaders();
        // Fire and forget GET per requirement
        http.get(
          Uri.parse(
            'https://api.aeo.how/api/brands/$_brandId/customer-personas/$id',
          ),
          headers: headers,
        );
      } catch (e) {
        debugPrint("Get persona details error: $e");
      }
    }
  }

  Future<void> _deletePersona(CustomerPersona p) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm"),
        content: Text("Are you sure you want to delete this persona?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final headers = await _getHeaders();
        final response = await http.delete(
          Uri.parse(
            'https://api.aeo.how/api/brands/$_brandId/customer-personas/${p.id}',
          ),
          headers: headers,
        );
        if (response.statusCode == 200 || response.statusCode == 204) {
          setState(() {
            _personas.removeWhere((e) => e.id == p.id);
            if (_selectedPersonaId == p.id) _selectedPersonaId = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Xóa Customer Persona ${p.name} thành công'),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('Error deleting persona: $e');
      }
    }
  }

  void _openPersonaDialog([CustomerPersona? persona]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CustomerPersonaDialog(
        brandId: _brandId,
        persona: persona,
        getHeaders: _getHeaders,
        onSaved: (savedPersona) => setState(() {
          if (persona == null) {
            _personas.add(savedPersona);
            _selectedPersonaId = savedPersona.id;
          } else {
            final idx = _personas.indexWhere((e) => e.id == savedPersona.id);
            if (idx != -1) _personas[idx] = savedPersona;
          }
        }),
        onAIGenerated: (newPersonas) => setState(() {
          _personas.addAll(newPersonas);
          if (newPersonas.isNotEmpty) _selectedPersonaId = newPersonas.first.id;
        }),
      ),
    );
  }

  void _onPromptChanged(String? newPromptId) {
    setState(() {
      _selectedPromptId = newPromptId;
      if (newPromptId != null && _referenceType == "search") {
        _fetchTopPages(newPromptId);
      }
    });
  }

  void _onReferenceTypeChanged(String? newType) {
    setState(() {
      _referenceType = newType ?? "search";
      if (_referenceType == "search" &&
          _selectedPromptId != null &&
          _topPages.isEmpty) {
        _fetchTopPages(_selectedPromptId!);
      }
    });
  }

  // ...existing code...
  Future<void> _submitContentGeneration() async {
    // Basic validations
    if (_selectedPromptId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hãy chọn Prompt")));
      return;
    }
    if (_selectedProfileId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Hãy chọn Content Profile")));
      return;
    }
    if (_referenceType == "search" && _selectedSearchUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hãy chọn một trang tham khảo từ kết quả tìm kiếm"),
        ),
      );
      return;
    }
    if (_referenceType == "custom" &&
        _customUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hãy nhập URL trang tham khảo")),
      );
      return;
    }

    setState(() {
      _isGeneratingContent = true;
    });

    // Fallback persona to the primary one if not selected
    String? personaId = _selectedPersonaId;
    if (personaId == null && _personas.isNotEmpty) {
      // Trying to find isPrimary is handled at backend, but we can pick first if needed
      // Currently the backend says the persona ID is optional and falls back to primary.
    }

    // Chuyển đổi chuỗi keywords thành mảng
    List<String> parsedKeywords = _keywordsController.text
        .split(',')
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toList();

    final payload = {
      "projectId": _projectId,
      "contentType": _selectedContentType,
      "contentProfileId": _selectedProfileId,
      "keywords": parsedKeywords,
      "referencePageUrl": _referenceType == "search"
          ? _selectedSearchUrl!
          : _customUrlController.text.trim(),
      if (_selectedContentType == "social_media_post")
        "platform": _selectedPlatform,
      if (_modificationInstructionController.text.isNotEmpty)
        "improvement": _modificationInstructionController.text,
      "referenceType": _referenceType,
      if (personaId != null) "customerPersonaId": personaId,
    };

    try {
      final headers = await _getHeaders();

      // 1. Validate Reference API
      final validatePayload = {
        "projectId": _projectId,
        "referencePageUrl": payload["referencePageUrl"],
        "referenceType": _referenceType,
      };

      final validateResponse = await http.post(
        Uri.parse(
          'https://api.aeo.how/api/prompts/$_selectedPromptId/validate-reference',
        ),
        headers: headers,
        body: jsonEncode(validatePayload),
      );

      if (validateResponse.statusCode != 200 &&
          validateResponse.statusCode != 201) {
        String errorMsg = "Reference URL không hợp lệ";
        try {
          final errBody = jsonDecode(validateResponse.body);
          if (errBody['message'] != null)
            errorMsg = errBody['message'].toString();
        } catch (_) {}
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMsg)));
        setState(() {
          _isGeneratingContent = false;
        });
        return; // Dừng nếu validate thất bại
      }

      // 2. Nếu validate thành công, gọi API generate
      debugPrint("Payload (GenerateContentDto): ${jsonEncode(payload)}");
      final response = await http.post(
        Uri.parse(
          'https://api.aeo.how/api/prompts/$_selectedPromptId/generations',
        ),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final jobId = body['jobId']; // Asynchronous endpoint returns jobId

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Workflow started. Waiting for completion...')),
          );

          // Listen to SSE to wait for completion
          _listenToJobStream(jobId, await _getToken() ?? '');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to generate: ${response.statusCode} - ${response.body}'),
            ),
          );
          setState(() {
            _isGeneratingContent = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting workflow: $e')),
        );
        setState(() {
          _isGeneratingContent = false;
        });
      }
    }
    // Removed finally block that immediately sets _isGeneratingContent = false
    // because we need to keep loading true while SSE is streaming
  }

  void _listenToJobStream(String jobId, String token) async {
    final client = http.Client();
    try {
      final request = http.Request(
        'GET',
        Uri.parse('https://api.aeo.how/api/contents/jobs/$jobId/stream'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      final response = await client.send(request);

      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          if (line.startsWith('data: ')) {
            try {
              final jsonString = line.substring(6); // remove 'data: '
              if (jsonString.trim().isNotEmpty) {
                final payload = jsonDecode(jsonString);

                if (payload['event'] == 'result' || payload['id'] != null) {
                  client.close();
                  final contentId = payload['data'] != null
                      ? payload['data']['id']
                      : payload['id'];

                  if (mounted) {
                    Navigator.of(context).pushReplacementNamed(
                      '/post-detail',
                      arguments: contentId,
                    );
                  }
                } else if (payload['event'] == 'failed' ||
                    payload['error'] != null) {
                  client.close();
                  if (mounted) {
                    setState(() => _isGeneratingContent = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Generation failed: ${payload['message'] ?? 'Unknown'}')),
                    );
                  }
                }
              }
            } catch (e) {
              debugPrint('Error parsing SSE data: $e');
            }
          }
        },
        onDone: () {
          client.close();
        },
        onError: (err) {
          client.close();
          if (mounted) setState(() => _isGeneratingContent = false);
        },
      );
    } catch (e) {
      client.close();
      if (mounted) setState(() => _isGeneratingContent = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingMetaData) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI Writer')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
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
                child: Icon(
                  Icons.lightbulb_outline,
                  color: Colors.orange,
                  size: 32,
                ),
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
            _buildLabel('Select Prompt *'),
            _buildDropdown(
              hint: 'Select a prompt...',
              value: _selectedPromptId,
              items: _prompts
                  .map(
                    (p) => DropdownMenuItem(value: p.id, child: Text(p.title)),
                  )
                  .toList(),
              onChanged: _onPromptChanged,
            ),
            _buildHelperText('Choose the prompt for generation.'),
            SizedBox(height: 16),

            _buildLabel('Select Reference Page *'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToggleButton(
                    'Search-Ranking Pages',
                    _referenceType == 'search',
                    () => _onReferenceTypeChanged('search'),
                  ),
                  SizedBox(width: 8),
                  _buildToggleButton(
                    'Custom URL',
                    _referenceType == 'custom',
                    () => _onReferenceTypeChanged('custom'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            if (_referenceType == 'search') ...[
              _buildHelperText(
                'The system will automatically crawl keywords on google to fetch top ranking pages as references.',
                maxLines: 2,
              ),
              SizedBox(height: 12),
              if (_isSearching)
                Center(child: CircularProgressIndicator())
              else
                ..._topPages.map((page) => _buildTopPageCard(page)),
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
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              _buildHelperText(
                'Enter a URL of the page you want to reference.',
                maxLines: 2,
              ),
            ],

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

            _buildLabel('Improvement Instructions (Optional)'),
            TextField(
              controller: _improvementController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g. Make it shorter and more engaging',
                hintStyle: TextStyle(color: Colors.grey[400]),
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
            _buildHelperText('Instructions to improve or tweak the content.'),
            SizedBox(height: 16),

            // Select Customer Persona
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Target Customer Persona'),
                TextButton.icon(
                  onPressed: () => _openPersonaDialog(),
                  icon: Icon(Icons.add, size: 16, color: Colors.orange),
                  label: Text('New', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
            Container(
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
                      Icon(
                        Icons.people_outline,
                        size: 20,
                        color: Colors.purple.shade300,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select persona (optional)...',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                  value: _selectedPersonaId,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: _personas
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      // If the dropdown is currently open, pop it. Otherwise do not pop.
                                      // We use a small hack by calling _openPersonaDialog asynchronously.
                                      // Or if we know it's a dropdown item click, the dropdown itself usually closes automatically.
                                      // Wait momentarily then open so we don't double pop the screen
                                      Future.delayed(Duration.zero, () {
                                        _openPersonaDialog(p);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dropdown menu first
                                      Future.delayed(Duration.zero, () {
                                        _deletePersona(p);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => _onPersonaSelected(val),
                ),
              ),
            ),
            _buildHelperText(
              'Defaults to the brand\'s primary persona if left empty.',
            ),
            SizedBox(height: 16),

            _buildLabel('Select Content Type *'),
            _buildDropdown(
              hint: 'Select content type...',
              value: _selectedContentType,
              items: _contentTypes
                  .map(
                    (c) => DropdownMenuItem(
                      value: c['value']!,
                      child: Text(c['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (val) => setState(() {
                _selectedContentType = val!;
                if (_selectedContentType != 'social_media_post') {
                  _selectedPlatform = null;
                }
              }),
              icon: Icons.article_outlined,
            ),
            SizedBox(height: 16),

            if (_selectedContentType == 'social_media_post') ...[
              _buildLabel('Select Platform *'),
              _buildDropdown(
                hint: 'Select Platform...',
                value: _selectedPlatform,
                items: _socialPlatforms
                    .map(
                      (p) => DropdownMenuItem(
                        value: p['value']!,
                        child: Text(p['label']!),
                      ),
                    )
                    .toList(),
                onChanged: (val) => setState(() => _selectedPlatform = val),
                icon: Icons.tag,
              ),
              SizedBox(height: 16),
            ],

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Select Content Profile (Style)'),
                TextButton.icon(
                  onPressed: () => _openProfileDialog(),
                  icon: Icon(Icons.add, size: 16, color: Colors.orange),
                  label: Text('New', style: TextStyle(color: Colors.orange)),
                ),
              ],
            ),
            Container(
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
                      Icon(
                        Icons.style,
                        size: 20,
                        color: Colors.purple.shade300,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select a profile (optional)...',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                  value: _selectedProfileId,
                  icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  items: _contentProfiles
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  p.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      Future.delayed(Duration.zero, () {
                                        _openProfileDialog(p);
                                      });
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dropdown menu first
                                      Future.delayed(Duration.zero, () {
                                        _deleteProfile(p);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => _onProfileSelected(val),
                ),
              ),
            ),
            if (_selectedProfileId != null) ...[
              SizedBox(height: 16),
              _buildWritingStyleDetails(
                _contentProfiles.firstWhere((e) => e.id == _selectedProfileId),
              ),
            ],

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed:
                    _isGeneratingContent ? null : _submitContentGeneration,
                child: _isGeneratingContent
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Generate Content',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF6600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPageCard(WebSearchResponseDto page) {
    final isSelected = _selectedSearchUrl == page.url;
    return GestureDetector(
      onTap: () => setState(() => _selectedSearchUrl = page.url),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.05) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.orange : Colors.grey,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    page.title,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.url,
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    page.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
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
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          children: [
            if (text.contains('*'))
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    String? value,
    List<DropdownMenuItem<String>>? items,
    required Function(String?) onChanged,
    IconData? icon,
  }) {
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
                SizedBox(width: 8),
              ],
              Text(
                hint,
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items ?? [], // Empty list if no items provided
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
            color: isSelected ? Colors.grey[400]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildWritingStyleDetails(ContentProfile style) {
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
          _buildStyleDetailRow('Voice & Tone:', style.voiceAndTone),
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
  final String projectId;
  final ContentProfile? profile;
  final Future<Map<String, String>> Function() getHeaders;
  final Function(ContentProfile) onStyleCreatedOrUpdated;

  const AddWritingStyleDialog({
    Key? key,
    required this.projectId,
    this.profile,
    required this.getHeaders,
    required this.onStyleCreatedOrUpdated,
  }) : super(key: key);

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.profile != null) {
      _styleNameController.text = widget.profile!.name;
      _descriptionController.text = widget.profile!.description;
      _voiceToneController.text = widget.profile!.voiceAndTone;
      _audienceController.text = widget.profile!.audience;
    }
  }

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

  Future<void> _saveStyle() async {
    if (_formKey3.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final isUpdating = widget.profile != null;
        final url = isUpdating
            ? 'https://api.aeo.how/api/projects/${widget.projectId}/content-profiles/${widget.profile!.id}'
            : 'https://api.aeo.how/api/projects/${widget.projectId}/content-profiles';

        final payload = {
          "name": _styleNameController.text,
          "description": _descriptionController.text,
          "voiceAndTone": _voiceToneController.text,
          "audience": _audienceController.text,
        };

        final headers = await widget.getHeaders();
        final response = isUpdating
            ? await http.patch(
                Uri.parse(url),
                headers: headers,
                body: jsonEncode(payload),
              )
            : await http.post(
                Uri.parse(url),
                headers: headers,
                body: jsonEncode(payload),
              );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = jsonDecode(response.body);
          widget.onStyleCreatedOrUpdated(ContentProfile.fromJson(data));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Saved successfully!')));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
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
    final title =
        widget.profile == null ? 'Add Writing Style' : 'Edit Writing Style';
    final subtitle = widget.profile == null
        ? 'Create a new writing style for your brand'
        : 'Update the details of your writing style';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
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
        ),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                  'e.g. This is a writing style that combines education...',
                ),
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
                  ),
                ],
              ),
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
                  'e.g., Professional, friendly, informative',
                ),
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
                  'e.g., Tech-savvy professionals, small business owners',
                ),
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
                side: BorderSide(color: Colors.grey[300]!),
              ),
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
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ),
        if (_currentStep < 3)
          ElevatedButton(
            onPressed: isStepValid ? _nextStep : null,
            child: Text(
              'Next',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return Color(0xFFFCAA80).withOpacity(0.5);
                }
                return Color(0xFFE69138); // Darker orange/brown when active
              }),
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              elevation: WidgetStateProperty.all(0),
            ),
          )
        else
          ElevatedButton(
            onPressed: isStepValid && !_isLoading ? _saveStyle : null,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.profile == null ? 'Create' : 'Update',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  return Color(0xFFFCAA80).withOpacity(0.5);
                }
                return Color(0xFFE69138); // Darker orange/brown when active
              }),
              padding: WidgetStateProperty.all(
                EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: [
            if (text.contains('*'))
              TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.grey[300]!,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
    );
  }
}

class CustomerPersonaDialog extends StatefulWidget {
  final String brandId;
  final CustomerPersona? persona;
  final Future<Map<String, String>> Function() getHeaders;
  final Function(CustomerPersona) onSaved;
  final Function(List<CustomerPersona>) onAIGenerated;

  const CustomerPersonaDialog({
    Key? key,
    required this.brandId,
    this.persona,
    required this.getHeaders,
    required this.onSaved,
    required this.onAIGenerated,
  }) : super(key: key);

  @override
  _CustomerPersonaDialogState createState() => _CustomerPersonaDialogState();
}

class _CustomerPersonaDialogState extends State<CustomerPersonaDialog> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isGenerating = false;

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _goalsController;
  late TextEditingController _painPointsController;

  // Add more detailed controllers
  late TextEditingController _demoAgeController;
  late TextEditingController _demoGenderController;
  late TextEditingController _demoLocationController;
  late TextEditingController _demoEducationController;
  late TextEditingController _demoIncomeController;

  late TextEditingController _profJobController;
  late TextEditingController _profIndustryController;
  late TextEditingController _profCompanySizeController;
  late TextEditingController _profSeniorityController;

  late TextEditingController _prefChannelsController;
  late TextEditingController _prefFormatsController;
  late TextEditingController _prefResearchController;

  late TextEditingController _buyingTriggersController;
  late TextEditingController _buyingObjectionsController;
  late TextEditingController _buyingCriteriaController;

  bool _isPrimary = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.persona?.name ?? '');
    _descController = TextEditingController(
      text: widget.persona?.description?.toString() ?? '',
    );
    _goalsController = TextEditingController(
      text: widget.persona?.goalsAndMotivations?.toString() ?? '',
    );
    _painPointsController = TextEditingController(
      text: widget.persona?.painPoints?.toString() ?? '',
    );

    final demo = widget.persona?.demographics ?? {};
    _demoAgeController = TextEditingController(
      text: demo['ageRange']?.toString() ?? '',
    );
    _demoGenderController = TextEditingController(
      text: demo['gender']?.toString() ?? '',
    );
    _demoLocationController = TextEditingController(
      text: demo['location']?.toString() ?? '',
    );
    _demoEducationController = TextEditingController(
      text: demo['educationLevel']?.toString() ?? '',
    );
    _demoIncomeController = TextEditingController(
      text: demo['incomeRange']?.toString() ?? '',
    );

    final prof = widget.persona?.professional ?? {};
    _profJobController = TextEditingController(
      text: prof['jobTitle']?.toString() ?? '',
    );
    _profIndustryController = TextEditingController(
      text: prof['industry']?.toString() ?? '',
    );
    _profCompanySizeController = TextEditingController(
      text: prof['companySize']?.toString() ?? '',
    );
    _profSeniorityController = TextEditingController(
      text: prof['seniorityLevel']?.toString() ?? '',
    );

    final pref = widget.persona?.contentPreferences ?? {};
    _prefChannelsController = TextEditingController(
      text: (pref['channels'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _prefFormatsController = TextEditingController(
      text: (pref['formats'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _prefResearchController = TextEditingController(
      text: pref['researchHabits']?.toString() ?? '',
    );

    final buying = widget.persona?.buyingBehavior ?? {};
    _buyingTriggersController = TextEditingController(
      text: (buying['triggers'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _buyingObjectionsController = TextEditingController(
      text: (buying['objections'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _buyingCriteriaController = TextEditingController(
      text: (buying['evaluationCriteria'] as List<dynamic>?)?.join(', ') ?? '',
    );

    _isPrimary = widget.persona?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _goalsController.dispose();
    _painPointsController.dispose();

    _demoAgeController.dispose();
    _demoGenderController.dispose();
    _demoLocationController.dispose();
    _demoEducationController.dispose();
    _demoIncomeController.dispose();

    _profJobController.dispose();
    _profIndustryController.dispose();
    _profCompanySizeController.dispose();
    _profSeniorityController.dispose();

    _prefChannelsController.dispose();
    _prefFormatsController.dispose();
    _prefResearchController.dispose();

    _buyingTriggersController.dispose();
    _buyingObjectionsController.dispose();
    _buyingCriteriaController.dispose();
    super.dispose();
  }

  Future<void> _savePersona() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final isUpdating = widget.persona != null;
      final url = isUpdating
          ? 'https://api.aeo.how/api/brands/${widget.brandId}/customer-personas/${widget.persona!.id}'
          : 'https://api.aeo.how/api/brands/${widget.brandId}/customer-personas';

      final payload = {
        "name": _nameController.text,
        "description": _descController.text,
        "goalsAndMotivations": _goalsController.text,
        "painPoints": _painPointsController.text,
        "demographics": {
          "ageRange": _demoAgeController.text,
          "gender": _demoGenderController.text,
          "location": _demoLocationController.text,
          "educationLevel": _demoEducationController.text,
          "incomeRange": _demoIncomeController.text,
        },
        "professional": {
          "jobTitle": _profJobController.text,
          "industry": _profIndustryController.text,
          "companySize": _profCompanySizeController.text,
          "seniorityLevel": _profSeniorityController.text,
        },
        "contentPreferences": {
          "channels": _prefChannelsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "formats": _prefFormatsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "researchHabits": _prefResearchController.text,
        },
        "buyingBehavior": {
          "triggers": _buyingTriggersController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "objections": _buyingObjectionsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
          "evaluationCriteria": _buyingCriteriaController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        },
        "isPrimary": _isPrimary,
      };

      final headers = await widget.getHeaders();
      final response = isUpdating
          ? await http.patch(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(payload),
            )
          : await http.post(
              Uri.parse(url),
              headers: headers,
              body: jsonEncode(payload),
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        widget.onSaved(CustomerPersona.fromJson(data));
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Saved successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePersona() async {
    setState(() => _isGenerating = true);
    try {
      final headers = await widget.getHeaders();
      final response = await http.post(
        Uri.parse(
          'https://api.aeo.how/api/brands/${widget.brandId}/customer-personas/generate',
        ),
        headers: headers,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> generatedData = jsonDecode(response.body);
        List<CustomerPersona> newPersonas = [];
        for (var item in generatedData) {
          final creatingRes = await http.post(
            Uri.parse(
              'https://api.aeo.how/api/brands/${widget.brandId}/customer-personas',
            ),
            headers: headers,
            body: jsonEncode(item),
          );
          if (creatingRes.statusCode == 200 || creatingRes.statusCode == 201) {
            newPersonas.add(
              CustomerPersona.fromJson(jsonDecode(creatingRes.body)),
            );
          }
        }

        if (newPersonas.isNotEmpty) {
          widget.onAIGenerated(newPersonas);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Added AI Personas: ${newPersonas.map((e) => e.name).join(", ")}',
              ),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        final err = jsonDecode(response.body)['message'] ?? 'Generation failed';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err.toString())));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error generating: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.persona == null
        ? 'Create Customer Persona'
        : 'Edit Customer Persona';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                if (widget.persona == null) ...[
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: _isGenerating ? null : _generatePersona,
                    icon: _isGenerating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome,
                            size: 18,
                          ),
                    label: const Text(
                      "Create AI-generated personas",
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade400,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                _buildSectionTitle('Basic Info'),
                _buildTextField(
                  'Name *',
                  _nameController,
                  isRequired: true,
                ),
                _buildTextField(
                  'Description',
                  _descController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Demographics'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Age Range',
                        _demoAgeController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Gender',
                        _demoGenderController,
                      ),
                    ),
                  ],
                ),
                _buildTextField(
                  'Location',
                  _demoLocationController,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Education Level',
                        _demoEducationController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Income Range',
                        _demoIncomeController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle('Professional'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Job Title',
                        _profJobController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Industry',
                        _profIndustryController,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        'Company Size',
                        _profCompanySizeController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        'Seniority Level',
                        _profSeniorityController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  'Goals & Pain Points',
                ),
                _buildTextField(
                  'Goals & Motivations',
                  _goalsController,
                  maxLines: 2,
                ),
                _buildTextField(
                  'Pain Points',
                  _painPointsController,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  'Content Preferences',
                ),
                _buildTextField(
                  'Channels (comma separated)',
                  _prefChannelsController,
                ),
                _buildTextField(
                  'Formats (comma separated)',
                  _prefFormatsController,
                ),
                _buildTextField(
                  'Research Habits',
                  _prefResearchController,
                ),
                const SizedBox(height: 16),
                _buildSectionTitle(
                  'Buying Behavior',
                ),
                _buildTextField(
                  'Triggers (comma separated)',
                  _buyingTriggersController,
                ),
                _buildTextField(
                  'Objections (comma separated)',
                  _buyingObjectionsController,
                ),
                _buildTextField(
                  'Evaluation Criteria (comma separated)',
                  _buyingCriteriaController,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: _isPrimary,
                      onChanged: (val) {
                        setState(() {
                          _isPrimary = val ?? false;
                        });
                      },
                    ),
                    const Text(
                      'Mark as Primary Persona',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePersona,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFCAA80),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                widget.persona == null
                                    ? 'Create Persona'
                                    : 'Save Changes',
                                textAlign: TextAlign.center,
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0D2B5B),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', '').trim(),
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              children: [
                if (isRequired)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: isRequired
                ? (v) => v == null || v.isEmpty ? 'Required' : null
                : null,
            decoration: InputDecoration(
              hintText:
                  'Enter ${label.replaceAll('*', '').trim().toLowerCase()}',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.orange),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
