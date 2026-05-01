import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/domain/entity/content/content_item.dart';
import 'package:boilerplate/domain/entity/content/content_operation.dart';
import 'package:boilerplate/domain/entity/content/content_request.dart';
import 'package:boilerplate/domain/entity/content/content_result.dart';
import 'package:boilerplate/domain/repository/content/content_repository.dart';
import 'package:boilerplate/domain/usecase/content/enhance_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/rewrite_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/humanize_content_usecase.dart';
import 'package:boilerplate/domain/usecase/content/summarize_content_usecase.dart';

class MockContentRepository implements ContentRepository {
  ContentRequest? lastRequest;
  ContentResult? resultToReturn;
  ContentResult? pollResultToReturn;
  List<Map<String, dynamic>> projectsToReturn = const [];
  List<ContentItem> contentsToReturn = const [];
  final List<ContentRequest> allRequests = [];

  @override
  Future<List<Map<String, dynamic>>> listProjects() async => projectsToReturn;

  @override
  Future<List<ContentItem>> listProjectContents(String projectId) async =>
      contentsToReturn;

  @override
  Future<ContentResult> startProcess(ContentRequest request) async {
    lastRequest = request;
    allRequests.add(request);
    return resultToReturn ??
        ContentResult.jobCreated(
          jobId: 'job-${request.contentId}',
          operation: request.operation,
        );
  }

  @override
  Future<ContentResult?> pollByJob(String jobId) async {
    return pollResultToReturn;
  }
}

void main() {
  ContentRequest req(ContentOperation op,
      {String contentId = 'cid-test', Map<String, dynamic>? options}) {
    return ContentRequest(
      contentId: contentId,
      operation: op,
      options: options,
    );
  }

  group('EnhanceContentUseCase', () {
    late MockContentRepository repo;
    late EnhanceContentUseCase useCase;

    setUp(() {
      repo = MockContentRepository();
      useCase = EnhanceContentUseCase(repo);
    });

    test('forces enhance operation regardless of incoming op', () async {
      await useCase.call(params: req(ContentOperation.rewrite));
      expect(repo.lastRequest!.operation, ContentOperation.enhance);
    });

    test('preserves contentId and options', () async {
      final options = {'tone': 'formal'};
      await useCase.call(
        params: req(ContentOperation.enhance,
            contentId: 'cid-1', options: options),
      );
      expect(repo.lastRequest!.contentId, 'cid-1');
      expect(repo.lastRequest!.options, options);
    });

    test('returns the job ack from the repository', () async {
      final ack = ContentResult.jobCreated(
        jobId: 'job-abc',
        operation: ContentOperation.enhance,
      );
      repo.resultToReturn = ack;
      final result = await useCase.call(params: req(ContentOperation.enhance));
      expect(result.jobId, 'job-abc');
      expect(result.operation, ContentOperation.enhance);
    });
  });

  group('RewriteContentUseCase', () {
    late MockContentRepository repo;
    late RewriteContentUseCase useCase;

    setUp(() {
      repo = MockContentRepository();
      useCase = RewriteContentUseCase(repo);
    });

    test('forces rewrite operation', () async {
      await useCase.call(params: req(ContentOperation.enhance));
      expect(repo.lastRequest!.operation, ContentOperation.rewrite);
    });

    test('preserves contentId', () async {
      await useCase.call(
        params: req(ContentOperation.rewrite, contentId: 'cid-rw'),
      );
      expect(repo.lastRequest!.contentId, 'cid-rw');
    });
  });

  group('HumanizeContentUseCase', () {
    late MockContentRepository repo;
    late HumanizeContentUseCase useCase;

    setUp(() {
      repo = MockContentRepository();
      useCase = HumanizeContentUseCase(repo);
    });

    test('forces humanize operation', () async {
      await useCase.call(params: req(ContentOperation.enhance));
      expect(repo.lastRequest!.operation, ContentOperation.humanize);
    });
  });

  group('SummarizeContentUseCase', () {
    late MockContentRepository repo;
    late SummarizeContentUseCase useCase;

    setUp(() {
      repo = MockContentRepository();
      useCase = SummarizeContentUseCase(repo);
    });

    test('forces summarize operation', () async {
      await useCase.call(params: req(ContentOperation.enhance));
      expect(repo.lastRequest!.operation, ContentOperation.summarize);
    });

    test('preserves length option', () async {
      await useCase.call(
        params: req(ContentOperation.summarize,
            options: {'length': 'short'}),
      );
      expect(repo.lastRequest!.options, {'length': 'short'});
    });
  });

  group('Content Use Cases Integration', () {
    test('each use case enforces its own operation', () async {
      final repo = MockContentRepository();
      final base = req(ContentOperation.enhance, contentId: 'cid-int');

      await EnhanceContentUseCase(repo).call(params: base);
      expect(repo.lastRequest!.operation, ContentOperation.enhance);

      await RewriteContentUseCase(repo).call(params: base);
      expect(repo.lastRequest!.operation, ContentOperation.rewrite);

      await HumanizeContentUseCase(repo).call(params: base);
      expect(repo.lastRequest!.operation, ContentOperation.humanize);

      await SummarizeContentUseCase(repo).call(params: base);
      expect(repo.lastRequest!.operation, ContentOperation.summarize);
    });

    test('mock tracks every dispatched request', () async {
      final repo = MockContentRepository();
      final r = req(ContentOperation.enhance);

      await EnhanceContentUseCase(repo).call(params: r);
      await RewriteContentUseCase(repo).call(params: r);
      await HumanizeContentUseCase(repo).call(params: r);

      expect(repo.allRequests.length, 3);
    });

    test('repository.pollByJob returns null while job is in flight', () async {
      final repo = MockContentRepository()..pollResultToReturn = null;
      final result = await repo.pollByJob('any');
      expect(result, isNull);
    });
  });
}
