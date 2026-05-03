import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';

void main() {
  group('ContentOperation Extension', () {
    test('apiPath returns correct value for each operation', () {
      expect(ContentOperation.enhance.apiPath, 'enhance');
      expect(ContentOperation.rewrite.apiPath, 'rewrite');
      expect(ContentOperation.humanize.apiPath, 'humanize');
      expect(ContentOperation.summarize.apiPath, 'summarize');
    });

    test('displayName returns correct value for each operation', () {
      expect(ContentOperation.enhance.displayName, 'Enhance');
      expect(ContentOperation.rewrite.displayName, 'Rewrite');
      expect(ContentOperation.humanize.displayName, 'Humanize');
      expect(ContentOperation.summarize.displayName, 'Summarize');
    });
  });

  group('ContentRequest', () {
    // The BE reuses the regenerate N8N flow, so the body only needs
    // optional tone/length hints — operation is in the URL, contentId
    // identifies the target draft.

    test('constructor sets all fields correctly', () {
      final request = ContentRequest(
        contentId: 'd6b1aef8-0748-4a32-a2c9-b42f13c6253c',
        operation: ContentOperation.enhance,
      );

      expect(request.contentId, 'd6b1aef8-0748-4a32-a2c9-b42f13c6253c');
      expect(request.operation, ContentOperation.enhance);
      expect(request.options, null);
    });

    test('constructor with options', () {
      final options = {'tone': 'formal', 'length': 'short'};
      final request = ContentRequest(
        contentId: 'cid-1',
        operation: ContentOperation.rewrite,
        options: options,
      );

      expect(request.contentId, 'cid-1');
      expect(request.operation, ContentOperation.rewrite);
      expect(request.options, options);
    });

    test('toMap is empty when no options are provided', () {
      final request = ContentRequest(
        contentId: 'cid-2',
        operation: ContentOperation.humanize,
      );

      final map = request.toMap();

      expect(map.isEmpty, true);
      expect(map.containsKey('text'), false);
      expect(map.containsKey('contentId'), false);
      expect(map.containsKey('operation'), false);
      expect(map.containsKey('options'), false);
    });

    test('toMap flattens options into the body', () {
      final options = {'tone': 'formal', 'length': 'short'};
      final request = ContentRequest(
        contentId: 'cid-3',
        operation: ContentOperation.summarize,
        options: options,
      );

      final map = request.toMap();

      expect(map['tone'], 'formal');
      expect(map['length'], 'short');
      expect(map.containsKey('options'), false);
      expect(map.containsKey('operation'), false);
      expect(map.containsKey('contentId'), false);
    });

    test('toMap omits operation + contentId for every operation type', () {
      for (final op in ContentOperation.values) {
        final request =
            ContentRequest(contentId: 'cid-$op', operation: op);
        final map = request.toMap();
        expect(map.containsKey('operation'), false,
            reason: 'operation $op should not appear in body');
        expect(map.containsKey('contentId'), false);
      }
    });
  });

  group('ContentResult', () {
    test('jobCreated factory builds an ack-only result', () {
      final result = ContentResult.jobCreated(
        jobId: 'job-1',
        operation: ContentOperation.enhance,
      );

      expect(result.jobId, 'job-1');
      expect(result.operation, ContentOperation.enhance);
      expect(result.resultText, '');
      expect(result.tokensUsed, null);
    });

    test('fromMap parses BE content row shape (body field)', () {
      final map = {
        'jobId': 'job-2',
        'operation': 'rewrite',
        'body': 'Regenerated body text',
        'updatedAt': '2024-01-15T10:00:00.000Z',
      };

      final result = ContentResult.fromMap(map);

      expect(result.jobId, 'job-2');
      expect(result.operation, ContentOperation.rewrite);
      expect(result.resultText, 'Regenerated body text');
      expect(result.processedAt.year, 2024);
    });

    test('fromMap accepts result_text fallback', () {
      final map = {
        'jobId': 'job-3',
        'operation': 'humanize',
        'result_text': 'Humanized output',
      };

      final result = ContentResult.fromMap(map);

      expect(result.resultText, 'Humanized output');
      expect(result.operation, ContentOperation.humanize);
    });

    test('fromMap defaults to enhance for unknown operation', () {
      final map = {'jobId': 'j', 'operation': 'unknown_op', 'body': 'x'};

      expect(ContentResult.fromMap(map).operation, ContentOperation.enhance);
    });

    test('fromMap keeps empty resultText when body missing', () {
      final map = {'jobId': 'j', 'operation': 'summarize'};

      expect(ContentResult.fromMap(map).resultText, '');
    });

    test('copyWith only overrides supplied fields', () {
      final base = ContentResult.jobCreated(
        jobId: 'j',
        operation: ContentOperation.enhance,
      );

      final updated = base.copyWith(resultText: 'final', tokensUsed: 42);

      expect(updated.jobId, 'j');
      expect(updated.operation, ContentOperation.enhance);
      expect(updated.resultText, 'final');
      expect(updated.tokensUsed, 42);
    });
  });
}
