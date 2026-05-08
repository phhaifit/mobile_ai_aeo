import 'package:meta/meta.dart';

/// Content of a chat message. Extend with new payload types when the API
/// returns richer blocks (e.g. tables, citations).
sealed class AssistantMessagePayload {
  const AssistantMessagePayload();
}

@immutable
final class UserTextPayload extends AssistantMessagePayload {
  final String text;

  const UserTextPayload(this.text);
}

@immutable
final class AssistantHighlightBullet {
  final String title;
  final String description;

  const AssistantHighlightBullet({
    required this.title,
    required this.description,
  });
}

@immutable
final class AssistantStructuredPayload extends AssistantMessagePayload {
  final String intro;
  final List<AssistantHighlightBullet> bullets;

  const AssistantStructuredPayload({
    required this.intro,
    required this.bullets,
  });
}

@immutable
final class AssistantPlainTextPayload extends AssistantMessagePayload {
  final String text;

  const AssistantPlainTextPayload(this.text);
}
