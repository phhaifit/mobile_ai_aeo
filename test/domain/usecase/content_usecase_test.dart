import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';

// Mock repository for testing
class MockContentRepository implements ContentRepository {
  ContentRequest? lastRequest;
  ContentResult? resultToReturn;
  List<ContentRequest> allRequests = [];

  @override
  Future<ContentResult> processContent(ContentRequest request) async {
    lastRequest = request;
    allRequests.add(request);
    return resultToReturn!;
  }
}

void main() {
  group('EnhanceContentUseCase', () {
    late MockContentRepository mockRepository;
    late EnhanceContentUseCase useCase;
    late ContentResult mockResult;

    setUp(() {
      mockRepository = MockContentRepository();
      useCase = EnhanceContentUseCase(mockRepository);
      mockResult = ContentResult(
        resultText: 'Enhanced content',
        operation: ContentOperation.enhance,
        tokensUsed: 50,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;
    });

    test('call enforces enhance operation', () async {
      final request = ContentRequest(
        text: 'Original text',
        operation: ContentOperation.rewrite,
      );

      final result = await useCase.call(params: request);

      expect(mockRepository.lastRequest!.operation, ContentOperation.enhance);
      expect(result.operation, ContentOperation.enhance);
    });

    test('call preserves text from request', () async {
      final inputText = 'Text to enhance';
      final request = ContentRequest(
        text: inputText,
        operation: ContentOperation.summarize,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.text, inputText);
    });

    test('call preserves options from request', () async {
      final options = {'tone': 'formal', 'length': 'long'};
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.rewrite,
        options: options,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.options, options);
    });

    test('call returns result from repository', () async {
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.rewrite,
      );

      final result = await useCase.call(params: request);

      expect(result, mockResult);
      expect(result.resultText, 'Enhanced content');
    });

    test('call without options passes null options', () async {
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.rewrite,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.options, null);
    });
  });

  group('RewriteContentUseCase', () {
    late MockContentRepository mockRepository;
    late RewriteContentUseCase useCase;
    late ContentResult mockResult;

    setUp(() {
      mockRepository = MockContentRepository();
      useCase = RewriteContentUseCase(mockRepository);
      mockResult = ContentResult(
        resultText: 'Rewritten content',
        operation: ContentOperation.rewrite,
        tokensUsed: 60,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;
    });

    test('call enforces rewrite operation', () async {
      final request = ContentRequest(
        text: 'Original text',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(mockRepository.lastRequest!.operation, ContentOperation.rewrite);
      expect(result.operation, ContentOperation.rewrite);
    });

    test('call preserves text from request', () async {
      final inputText = 'Text to rewrite';
      final request = ContentRequest(
        text: inputText,
        operation: ContentOperation.humanize,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.text, inputText);
    });

    test('call preserves options from request', () async {
      final options = {'style': 'casual', 'complexity': 'high'};
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.enhance,
        options: options,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.options, options);
    });

    test('call returns result from repository', () async {
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(result, mockResult);
      expect(result.resultText, 'Rewritten content');
    });
  });

  group('HumanizeContentUseCase', () {
    late MockContentRepository mockRepository;
    late HumanizeContentUseCase useCase;
    late ContentResult mockResult;

    setUp(() {
      mockRepository = MockContentRepository();
      useCase = HumanizeContentUseCase(mockRepository);
      mockResult = ContentResult(
        resultText: 'Humanized content',
        operation: ContentOperation.humanize,
        tokensUsed: 40,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;
    });

    test('call enforces humanize operation', () async {
      final request = ContentRequest(
        text: 'Robotic text',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(mockRepository.lastRequest!.operation, ContentOperation.humanize);
      expect(result.operation, ContentOperation.humanize);
    });

    test('call preserves text from request', () async {
      final inputText = 'Text to humanize';
      final request = ContentRequest(
        text: inputText,
        operation: ContentOperation.rewrite,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.text, inputText);
    });

    test('call preserves options from request', () async {
      final options = {'warmth': 'high'};
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.summarize,
        options: options,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.options, options);
    });

    test('call returns result from repository', () async {
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(result, mockResult);
      expect(result.resultText, 'Humanized content');
    });
  });

  group('SummarizeContentUseCase', () {
    late MockContentRepository mockRepository;
    late SummarizeContentUseCase useCase;
    late ContentResult mockResult;

    setUp(() {
      mockRepository = MockContentRepository();
      useCase = SummarizeContentUseCase(mockRepository);
      mockResult = ContentResult(
        resultText: 'Summarized content',
        operation: ContentOperation.summarize,
        tokensUsed: 30,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;
    });

    test('call enforces summarize operation', () async {
      final request = ContentRequest(
        text: 'Long content',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(mockRepository.lastRequest!.operation, ContentOperation.summarize);
      expect(result.operation, ContentOperation.summarize);
    });

    test('call preserves text from request', () async {
      final inputText = 'Long text to summarize';
      final request = ContentRequest(
        text: inputText,
        operation: ContentOperation.humanize,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.text, inputText);
    });

    test('call preserves options from request', () async {
      final options = {'length': 'short', 'bulletPoints': true};
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.rewrite,
        options: options,
      );

      await useCase.call(params: request);

      expect(mockRepository.lastRequest!.options, options);
    });

    test('call returns result from repository', () async {
      final request = ContentRequest(
        text: 'Text',
        operation: ContentOperation.enhance,
      );

      final result = await useCase.call(params: request);

      expect(result, mockResult);
      expect(result.resultText, 'Summarized content');
    });
  });

  group('Content Use Cases Integration', () {
    late MockContentRepository mockRepository;

    setUp(() {
      mockRepository = MockContentRepository();
    });

    test('each use case enforces correct operation', () async {
      final mockResult = ContentResult(
        resultText: 'Result',
        operation: ContentOperation.enhance,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;

      final request = ContentRequest(
        text: 'Input',
        operation: ContentOperation.enhance,
      );

      final enhance = EnhanceContentUseCase(mockRepository);
      final rewrite = RewriteContentUseCase(mockRepository);
      final humanize = HumanizeContentUseCase(mockRepository);
      final summarize = SummarizeContentUseCase(mockRepository);

      await enhance.call(params: request);
      expect(mockRepository.lastRequest!.operation, ContentOperation.enhance);

      await rewrite.call(params: request);
      expect(mockRepository.lastRequest!.operation, ContentOperation.rewrite);

      await humanize.call(params: request);
      expect(mockRepository.lastRequest!.operation, ContentOperation.humanize);

      await summarize.call(params: request);
      expect(mockRepository.lastRequest!.operation, ContentOperation.summarize);
    });

    test('all requests are tracked by mock repository', () async {
      final mockResult = ContentResult(
        resultText: 'Result',
        operation: ContentOperation.enhance,
        processedAt: DateTime.now(),
      );
      mockRepository.resultToReturn = mockResult;

      final request = ContentRequest(text: 'Text', operation: ContentOperation.enhance);

      final enhance = EnhanceContentUseCase(mockRepository);
      final rewrite = RewriteContentUseCase(mockRepository);

      await enhance.call(params: request);
      await rewrite.call(params: request);

      expect(mockRepository.allRequests.length, 2);
      expect(mockRepository.allRequests[0].operation, ContentOperation.enhance);
      expect(mockRepository.allRequests[1].operation, ContentOperation.rewrite);
    });
  });
}
