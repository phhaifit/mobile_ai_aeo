import 'package:meta/meta.dart';

/// Content of a chat message. API replies map to [AssistantPlainTextPayload].
sealed class AssistantMessagePayload {
  const AssistantMessagePayload();
}

@immutable
final class UserTextPayload extends AssistantMessagePayload {
  final String text;

  const UserTextPayload(this.text);
}

@immutable
final class AssistantPlainTextPayload extends AssistantMessagePayload {
  final String text;

  const AssistantPlainTextPayload(this.text);
}
