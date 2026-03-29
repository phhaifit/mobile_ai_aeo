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
    test('constructor sets all fields correctly', () {
      final request = ContentRequest(
        text: 'Hello world',
        operation: ContentOperation.enhance,
      );

      expect(request.text, 'Hello world');
      expect(request.operation, ContentOperation.enhance);
      expect(request.options, null);
    });

    test('constructor with options', () {
      final options = {'tone': 'formal', 'length': 'short'};
      final request = ContentRequest(
        text: 'Test text',
        operation: ContentOperation.rewrite,
        options: options,
      );

      expect(request.text, 'Test text');
      expect(request.operation, ContentOperation.rewrite);
      expect(request.options, options);
    });

    test('toMap converts request without options to map', () {
      final request = ContentRequest(
        text: 'Sample text',
        operation: ContentOperation.humanize,
      );

      final map = request.toMap();

      expect(map['text'], 'Sample text');
      expect(map['operation'], 'humanize');
      expect(map.containsKey('options'), false);
    });

    test('toMap converts request with options to map', () {
      final options = {'level': 'advanced'};
      final request = ContentRequest(
        text: 'Complex text',
        operation: ContentOperation.summarize,
        options: options,
      );

      final map = request.toMap();

      expect(map['text'], 'Complex text');
      expect(map['operation'], 'summarize');
      expect(map['options'], options);
    });

    test('toMap includes all operation types correctly', () {
      final operations = [
        ContentOperation.enhance,
        ContentOperation.rewrite,
        ContentOperation.humanize,
        ContentOperation.summarize,
      ];

      for (final op in operations) {
        final request = ContentRequest(text: 'text', operation: op);
        final map = request.toMap();
        expect(map['operation'], op.apiPath);
      }
    });
  });

  group('ContentResult', () {
    test('constructor sets all fields correctly', () {
      final now = DateTime.now();
      final result = ContentResult(
        resultText: 'Enhanced text',
        operation: ContentOperation.enhance,
        tokensUsed: 50,
        processedAt: now,
      );

      expect(result.resultText, 'Enhanced text');
      expect(result.operation, ContentOperation.enhance);
      expect(result.tokensUsed, 50);
      expect(result.processedAt, now);
    });

    test('constructor without tokensUsed', () {
      final now = DateTime.now();
      final result = ContentResult(
        resultText: 'Result',
        operation: ContentOperation.rewrite,
        processedAt: now,
      );

      expect(result.resultText, 'Result');
      expect(result.tokensUsed, null);
    });

    test('fromMap parses resultText field', () {
      final map = {
        'result_text': 'Parsed result',
        'operation': 'enhance',
        'tokens_used': 100,
        'processed_at': '2024-01-15T10:00:00.000Z',
      };

      final result = ContentResult.fromMap(map);

      expect(result.resultText, 'Parsed result');
    });

    test('fromMap handles resultText without underscore', () {
      final map = {
        'resultText': 'Parsed result',
        'operation': 'rewrite',
      };

      final result = ContentResult.fromMap(map);

      expect(result.resultText, 'Parsed result');
    });

    test('fromMap defaults to empty string when result_text missing', () {
      final map = {
        'operation': 'humanize',
        'processed_at': '2024-01-15T10:00:00.000Z',
      };

      final result = ContentResult.fromMap(map);

      expect(result.resultText, '');
    });

    test('fromMap parses operation correctly', () {
      final operations = ['enhance', 'rewrite', 'humanize', 'summarize'];

      for (final opStr in operations) {
        final map = {
          'result_text': 'text',
          'operation': opStr,
        };

        final result = ContentResult.fromMap(map);

        expect(
          result.operation.apiPath,
          opStr,
          reason: 'Operation $opStr should parse correctly',
        );
      }
    });

    test('fromMap defaults to enhance for unknown operation', () {
      final map = {
        'result_text': 'text',
        'operation': 'unknown_operation',
      };

      final result = ContentResult.fromMap(map);

      expect(result.operation, ContentOperation.enhance);
    });

    test('fromMap defaults to enhance when operation missing', () {
      final map = {'result_text': 'text'};

      final result = ContentResult.fromMap(map);

      expect(result.operation, ContentOperation.enhance);
    });

    test('fromMap parses tokensUsed correctly', () {
      final map = {
        'result_text': 'text',
        'operation': 'enhance',
        'tokens_used': 250,
      };

      final result = ContentResult.fromMap(map);

      expect(result.tokensUsed, 250);
    });

    test('fromMap handles missing tokensUsed', () {
      final map = {
        'result_text': 'text',
        'operation': 'rewrite',
      };

      final result = ContentResult.fromMap(map);

      expect(result.tokensUsed, null);
    });

    test('fromMap parses ISO8601 datetime string', () {
      final dateStr = '2024-01-15T10:30:45.000Z';
      final map = {
        'result_text': 'text',
        'operation': 'humanize',
        'processed_at': dateStr,
      };

      final result = ContentResult.fromMap(map);

      expect(result.processedAt.year, 2024);
      expect(result.processedAt.month, 1);
      expect(result.processedAt.day, 15);
    });

    test('fromMap uses current time when processed_at missing', () {
      final beforeTime = DateTime.now();
      final map = {
        'result_text': 'text',
        'operation': 'summarize',
      };

      final result = ContentResult.fromMap(map);
      final afterTime = DateTime.now();

      expect(
        result.processedAt.isAfter(beforeTime.subtract(Duration(seconds: 1))),
        true,
      );
      expect(
        result.processedAt.isBefore(afterTime.add(Duration(seconds: 1))),
        true,
      );
    });

    test('fromMap round-trip with full data', () {
      final now = DateTime.now();
      final original = ContentResult(
        resultText: 'Full result',
        operation: ContentOperation.enhance,
        tokensUsed: 150,
        processedAt: now,
      );

      final map = {
        'result_text': original.resultText,
        'operation': original.operation.apiPath,
        'tokens_used': original.tokensUsed,
        'processed_at': original.processedAt.toIso8601String(),
      };

      final result = ContentResult.fromMap(map);

      expect(result.resultText, original.resultText);
      expect(result.operation, original.operation);
      expect(result.tokensUsed, original.tokensUsed);
      expect(
        result.processedAt.difference(original.processedAt).inMilliseconds,
        lessThan(100),
      );
    });
  });
}
