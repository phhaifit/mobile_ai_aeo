import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/utils/routes/routes.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage(
      {required this.text, required this.isUser, required this.timestamp});
}

class ChatSession {
  final String id;
  final String title;
  final DateTime date;

  ChatSession({required this.id, required this.title, required this.date});
}

class ChatAssistantScreen extends StatefulWidget {
  const ChatAssistantScreen({Key? key}) : super(key: key);

  @override
  State<ChatAssistantScreen> createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  String? _authToken;

  // Danh sách session (có thể fetch từ backend sau, tạm thời để trống)
  List<ChatSession> _pastSessions = [];

  @override
  void initState() {
    super.initState();
    _initChatSession();
  }

  Future<void> _initChatSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(Preferences.auth_token);

    if (token == null || token.isEmpty) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Yêu cầu đăng nhập'),
            content:
                const Text('Bạn cần đăng nhập để sử dụng AI Chat Assistant.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(Routes.login);
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        );
      }
      return;
    }

    _authToken = token;
    _fetchPastSessions(token);

    if (mounted) {
      setState(() {
        // Add a welcome message
        _messages.add(ChatMessage(
          text:
              "Xin chào! Mình là AI Assistant. Mình có thể giúp gì cho bạn hôm nay?",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
  }

  Future<void> _fetchPastSessions(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.6:8000/api/v1/chat/sessions?access_token=$token'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sessionsList = data['sessions'] as List;
        if (mounted) {
          setState(() {
            _pastSessions = sessionsList
                .map((s) => ChatSession(
                      id: s['session_id'],
                      title: s['title'],
                      date: DateTime.parse(s['updated_at']),
                    ))
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy danh sách session: $e");
    }
  }

  Future<void> _loadSession(ChatSession session) async {
    setState(() {
      _isLoading = true;
      _sessionId = session.id;
      _messages.clear();
    });

    try {
      final response = await http.get(
        Uri.parse(
            'http://192.168.1.6:8000/api/v1/chat/sessions/${session.id}/messages'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final messagesList = data['messages'] as List;

        setState(() {
          // Add in reverse order for ListView
          _messages.addAll(messagesList
              .map((m) => ChatMessage(
                    text: m['content'],
                    isUser: m['type'] == 'human',
                    timestamp: DateTime.now(),
                  ))
              .toList()
              .reversed);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải phiên chat: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteSession(ChatSession session) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'http://192.168.1.6:8000/api/v1/chat/sessions/${session.id}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _pastSessions.removeWhere((s) => s.id == session.id);
          // Nếu đang xem session bị xóa, chuyển về hội thoại mới
          if (_sessionId == session.id) {
            _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
            _messages.clear();
            _messages.add(ChatMessage(
              text:
                  "Xin chào! Mình là AI Assistant. Mình có thể giúp gì cho bạn hôm nay?",
              isUser: false,
              timestamp: DateTime.now(),
            ));
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã xóa phiên chat')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xóa phiên chat: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    _textController.clear();
    setState(() {
      _messages.insert(
          0,
          ChatMessage(
            text: text,
            isUser: true,
            timestamp: DateTime.now(),
          ));
      _isLoading = true;
    });

    try {
      final token = _authToken ?? "test_token";

      final response = await http.post(
        Uri.parse('http://192.168.1.6:8000/api/v1/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
            {'message': text, 'access_token': token, 'session_id': _sessionId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text: data['response'] ?? "Không có phản hồi từ AI.",
                isUser: false,
                timestamp: DateTime.now(),
              ));
        });
        // Refresh danh sách sessions sau khi chat thành công
        if (_authToken != null) {
          _fetchPastSessions(_authToken!);
        }
      } else {
        setState(() {
          _messages.insert(
              0,
              ChatMessage(
                text:
                    "Lỗi kết nối tới Agent: ${response.statusCode}\nChi tiết: ${response.body}",
                isUser: false,
                timestamp: DateTime.now(),
              ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
              text:
                  "Không thể kết nối đến Backend AI: $e\nĐảm bảo server đang chạy.",
              isUser: false,
              timestamp: DateTime.now(),
            ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat Assistant',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      drawer: _buildDrawer(),
      body: Container(
        color: const Color(0xFFF5F7FA), // Background color nhẹ
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            _buildTextComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            width: double.infinity,
            color: Colors.blueAccent,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.support_agent, size: 48, color: Colors.white),
                SizedBox(height: 12),
                Text(
                  'Lịch sử Chat',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Xem lại các phiên làm việc trước',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.add_comment, color: Colors.blue),
            title: const Text('Bắt đầu hội thoại mới',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
                _messages.clear();
                _messages.add(ChatMessage(
                  text:
                      "Xin chào! Mình là AI Assistant. Mình có thể giúp gì cho bạn hôm nay?",
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
              });
            },
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _pastSessions.length,
              itemBuilder: (context, index) {
                final session = _pastSessions[index];
                return Dismissible(
                  key: Key(session.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Xác nhận xóa'),
                        content: Text('Bạn có chắc muốn xóa phiên "${session.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                            child: const Text('Xóa'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    _deleteSession(session);
                  },
                  child: ListTile(
                    leading:
                        const Icon(Icons.chat_bubble_outline, color: Colors.grey),
                    title: Text(session.title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                        "${session.date.day}/${session.date.month}/${session.date.year}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text('Bạn có chắc muốn xóa phiên "${session.title}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                  _deleteSession(session);
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      // Xử lý load session cũ
                      Navigator.pop(context);
                      _loadSession(session);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              radius: 16,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isUser ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isUser ? 16.0 : 4.0),
                  bottomRight: Radius.circular(isUser ? 4.0 : 16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isUser ? Colors.white : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 16,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.only(
          left: 16.0, right: 16.0, bottom: 24.0, top: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F5),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: 'Nhập câu lệnh cho Assistant...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
