class CrawlerEvent {
  final String botName;
  final String path;
  final int statusCode;
  final DateTime timestamp;

  CrawlerEvent({
    required this.botName,
    required this.path,
    required this.statusCode,
    required this.timestamp,
  });

  factory CrawlerEvent.fromMap(Map<String, dynamic> map) {
    return CrawlerEvent(
      botName: map['botName'] as String,
      path: map['path'] as String,
      statusCode: map['statusCode'] as int,
      timestamp: map['timestamp'] is String
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  Map<String, dynamic> toMap() => {
        'botName': botName,
        'path': path,
        'statusCode': statusCode,
        'timestamp': timestamp.toIso8601String(),
      };
}
