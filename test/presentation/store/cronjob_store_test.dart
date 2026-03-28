import 'package:flutter_test/flutter_test.dart';
import 'package:boilerplate/presentation/cronjob/store/cronjob_store.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob.dart';
import 'package:boilerplate/domain/entity/cronjob/schedule.dart';
import 'package:boilerplate/domain/entity/cronjob/source_type.dart';
import 'package:boilerplate/domain/entity/cronjob/publishing_destination.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_all_cronjobs_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/get_cronjob_by_id_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/create_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/update_cronjob_usecase.dart';
import 'package:boilerplate/domain/usecase/cronjob/delete_cronjob_usecase.dart';

import 'package:boilerplate/domain/repository/cronjob_repository.dart';
import 'package:boilerplate/domain/entity/cronjob/cronjob_execution.dart';

// Custom mocks (no mockito dependency)
class MockCronjobRepository implements CronjobRepository {
  @override
  Future<Cronjob> createCronjob(Cronjob cronjob) async => cronjob;

  @override
  Future<void> deleteCronjob(String id) async {}

  @override
  Future<CronjobExecution> createExecution(CronjobExecution execution) async =>
      execution;

  @override
  Future<List<Cronjob>> getAllCronjobs() async => [];

  @override
  Future<Cronjob?> getCronjobById(String id) async => null;

  @override
  Future<List<CronjobExecution>> getCronjobExecutions(String cronjobId) async =>
      [];

  @override
  Future<Cronjob> updateCronjob(Cronjob cronjob) async => cronjob;

  @override
  Future<CronjobExecution?> getExecutionById(String id) async => null;
}

class MockGetAllCronjobsUseCase implements GetAllCronjobsUseCase {
  final List<Cronjob> mockCronjobs;
  bool shouldThrow = false;
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  MockGetAllCronjobsUseCase({this.mockCronjobs = const []});

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<List<Cronjob>> call() async {
    if (shouldThrow) {
      throw Exception('Failed to load cronjobs');
    }
    return mockCronjobs;
  }
}

class MockGetCronjobByIdUseCase implements GetCronjobByIdUseCase {
  final Map<String, Cronjob> mockCronjobs;
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  MockGetCronjobByIdUseCase({this.mockCronjobs = const {}});

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<Cronjob?> call(String id) async {
    return mockCronjobs[id];
  }
}

class MockCreateCronjobUseCase implements CreateCronjobUseCase {
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<Cronjob> call(Cronjob cronjob) async {
    return cronjob;
  }
}

class MockUpdateCronjobUseCase implements UpdateCronjobUseCase {
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<Cronjob> call(Cronjob cronjob) async {
    return cronjob;
  }
}

class MockDeleteCronjobUseCase implements DeleteCronjobUseCase {
  final MockCronjobRepository _mockRepository = MockCronjobRepository();

  @override
  CronjobRepository get repository => _mockRepository;

  @override
  Future<void> call(String id) async {
    // No-op for mock
  }
}

void main() {
  late CronjobStore store;
  late MockGetAllCronjobsUseCase mockGetAllUseCase;
  late MockGetCronjobByIdUseCase mockGetByIdUseCase;
  late MockCreateCronjobUseCase mockCreateUseCase;
  late MockUpdateCronjobUseCase mockUpdateUseCase;
  late MockDeleteCronjobUseCase mockDeleteUseCase;

  final testCronjob1 = Cronjob(
    id: 'cron-1',
    name: 'Daily Job',
    schedule: Schedule.daily,
    schedulePattern: '0 9 * * *',
    sourceType: SourceType.promptLibrary,
    sourceUrl: null,
    articleCountPerRun: 5,
    destinations: [PublishingDestination.website],
    isEnabled: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  final testCronjob2 = Cronjob(
    id: 'cron-2',
    name: 'Weekly Job',
    schedule: Schedule.weekly,
    schedulePattern: '0 9 * * 0',
    sourceType: SourceType.website,
    sourceUrl: 'https://example.com',
    articleCountPerRun: 10,
    destinations: [PublishingDestination.facebook],
    isEnabled: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockGetAllUseCase = MockGetAllCronjobsUseCase(
      mockCronjobs: [testCronjob1, testCronjob2],
    );
    mockGetByIdUseCase = MockGetCronjobByIdUseCase(
      mockCronjobs: {'cron-1': testCronjob1, 'cron-2': testCronjob2},
    );
    mockCreateUseCase = MockCreateCronjobUseCase();
    mockUpdateUseCase = MockUpdateCronjobUseCase();
    mockDeleteUseCase = MockDeleteCronjobUseCase();

    store = CronjobStore(
      getAllCronjobsUseCase: mockGetAllUseCase,
      getCronjobByIdUseCase: mockGetByIdUseCase,
      createCronjobUseCase: mockCreateUseCase,
      updateCronjobUseCase: mockUpdateUseCase,
      deleteCronjobUseCase: mockDeleteUseCase,
    );
  });

  group('CronjobStore Tests', () {
    test('loadCronjobs fetches and updates list', () async {
      // Act
      await store.loadCronjobs();

      // Assert
      expect(store.cronjobs.length, 2);
      expect(store.cronjobs[0].id, 'cron-1');
      expect(store.cronjobs[1].id, 'cron-2');
      expect(store.isLoading, false);
      expect(store.errorMessage, null);
    });

    test('loadCronjobs handles errors gracefully', () async {
      // Arrange
      mockGetAllUseCase.shouldThrow = true;

      // Act
      await store.loadCronjobs();

      // Assert
      expect(store.errorMessage, isNotNull);
      expect(store.errorMessage!.contains('Failed to load cronjobs'), true);
      expect(store.isLoading, false);
    });

    test('createCronjob adds to list and clears selection', () async {
      // Arrange
      await store.loadCronjobs();
      store.selectCronjob('cron-1');

      final newCronjob = Cronjob(
        id: 'cron-3',
        name: 'New Job',
        schedule: Schedule.monthly,
        schedulePattern: '0 9 1 * *',
        sourceType: SourceType.promptLibrary,
        sourceUrl: null,
        articleCountPerRun: 3,
        destinations: [PublishingDestination.website],
        isEnabled: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      await store.createCronjob(newCronjob);

      // Assert
      expect(store.cronjobs.length, 3);
      expect(store.cronjobs.last.id, 'cron-3');
      expect(store.selectedCronjob, null);
      expect(store.errorMessage, null);
    });

    test('updateCronjob updates in list and selected', () async {
      // Arrange
      await store.loadCronjobs();
      store.selectCronjob('cron-1');

      final updated = testCronjob1.copyWith(name: 'Updated Daily Job');

      // Act
      await store.updateCronjob(updated);

      // Assert
      expect(store.cronjobs[0].name, 'Updated Daily Job');
      expect(store.selectedCronjob?.name, 'Updated Daily Job');
      expect(store.errorMessage, null);
    });

    test('deleteCronjob removes from list and clears selection', () async {
      // Arrange
      await store.loadCronjobs();
      store.selectCronjob('cron-1');

      // Act
      await store.deleteCronjob('cron-1');

      // Assert
      expect(store.cronjobs.length, 1);
      expect(store.cronjobs[0].id, 'cron-2');
      expect(store.selectedCronjob, null);
      expect(store.errorMessage, null);
    });

    test('selectCronjob updates selected', () async {
      // Arrange
      await store.loadCronjobs();

      // Act
      store.selectCronjob('cron-2');

      // Assert
      expect(store.selectedCronjob?.id, 'cron-2');
      expect(store.selectedCronjob?.name, 'Weekly Job');
      expect(store.errorMessage, null);
    });

    test('clearError resets error message', () async {
      // Arrange
      mockGetAllUseCase.shouldThrow = true;
      await store.loadCronjobs();
      expect(store.errorMessage, isNotNull);

      // Act
      store.clearError();

      // Assert
      expect(store.errorMessage, null);
    });

    test('enabledCount computed filters correctly', () async {
      // Arrange
      await store.loadCronjobs();

      // Act & Assert
      expect(store.enabledCount, 1); // Only cron-1 is enabled
      expect(store.disabledCount, 1); // Only cron-2 is disabled
      expect(store.totalCronjobs, 2);
    });
  });
}

// Extension to support copyWith pattern
extension CronjobCopyWith on Cronjob {
  Cronjob copyWith({
    String? id,
    String? name,
    String? description,
    Schedule? schedule,
    String? schedulePattern,
    SourceType? sourceType,
    String? sourceUrl,
    int? articleCountPerRun,
    List<PublishingDestination>? destinations,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cronjob(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      schedule: schedule ?? this.schedule,
      schedulePattern: schedulePattern ?? this.schedulePattern,
      sourceType: sourceType ?? this.sourceType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      articleCountPerRun: articleCountPerRun ?? this.articleCountPerRun,
      destinations: destinations ?? this.destinations,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
