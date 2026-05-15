# Phase 5: Testing & Validation

## Objective

Implement comprehensive unit tests, integration tests, and validate API integration end-to-end.

## Overview

| Component         | Count | Coverage | Status  |
| ----------------- | ----- | -------- | ------- |
| Unit Tests        | 30+   | 80%+     | pending |
| Integration Tests | 5-10  | 70%+     | pending |
| Widget Tests      | 10+   | 60%+     | pending |
| Test Fixtures     | 7     | -        | pending |

---

## Step 1: Create Test Fixtures (Mocked Data)

### 1.1 Brand Test Fixtures

**File:** `test/fixtures/brand_fixtures.dart` (NEW)

```dart
import 'package:boilerplate/data/network/models/brand_dto.dart';
import 'package:boilerplate/domain/entity/brand/brand.dart';

class BrandFixtures {
  static final brandDto = BrandDto(
    id: 'brand-123',
    name: 'Tech Corp',
    tagline: 'Innovation at Scale',
    industry: 'Technology',
    website: 'https://techcorp.com',
    logoUrl: 'https://techcorp.com/logo.png',
    verified: true,
    createdAt: '2026-05-01T10:00:00Z',
    updatedAt: '2026-05-14T10:00:00Z',
  );

  static final brand = Brand(
    id: 'brand-123',
    name: 'Tech Corp',
    tagline: 'Innovation at Scale',
    industry: 'Technology',
    website: 'https://techcorp.com',
    logoUrl: 'https://techcorp.com/logo.png',
    verified: true,
    createdAt: DateTime.parse('2026-05-01T10:00:00Z'),
    updatedAt: DateTime.parse('2026-05-14T10:00:00Z'),
  );

  static final List<BrandDto> brandDtoList = [
    brandDto,
    BrandDto(
      id: 'brand-456',
      name: 'Design Studio',
      tagline: 'Creative Excellence',
      industry: 'Design',
      website: 'https://designstudio.com',
      logoUrl: null,
      verified: false,
      createdAt: '2026-05-10T10:00:00Z',
      updatedAt: '2026-05-14T10:00:00Z',
    ),
  ];

  static final List<Brand> brandList = [
    brand,
    Brand(
      id: 'brand-456',
      name: 'Design Studio',
      tagline: 'Creative Excellence',
      industry: 'Design',
      website: 'https://designstudio.com',
      logoUrl: null,
      verified: false,
      createdAt: DateTime.parse('2026-05-10T10:00:00Z'),
      updatedAt: DateTime.parse('2026-05-14T10:00:00Z'),
    ),
  ];
}
```

### 1.2 Other Test Fixtures

Create similar fixtures for:

- `test/fixtures/knowledge_base_fixtures.dart`
- `test/fixtures/link_fixtures.dart`
- `test/fixtures/rewrite_rule_fixtures.dart`
- `test/fixtures/llm_config_fixtures.dart`
- `test/fixtures/brand_positioning_fixtures.dart`
- `test/fixtures/project_fixtures.dart`

---

## Step 2: Unit Tests for API Classes

### 2.1 Brand API Tests

**File:** `test/data/network/apis/brand/brand_api_test.dart` (NEW)

```dart
import 'package:boilerplate/core/data/network/dio/dio_client.dart';
import 'package:boilerplate/data/network/apis/brand/brand_api.dart';
import 'package:boilerplate/data/network/constants/endpoints.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('BrandApi', () {
    late BrandApi brandApi;
    late MockDioClient mockDioClient;

    setUp(() {
      mockDioClient = MockDioClient();
      brandApi = BrandApi(mockDioClient);
    });

    group('getBrand', () {
      test('returns Brand when API call succeeds', () async {
        // Arrange
        const brandId = 'brand-123';
        final mockResponse = Response(
          data: BrandFixtures.brandDto.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: Endpoints.getBrand(brandId)),
        );

        when(mockDioClient.dio.get(Endpoints.getBrand(brandId)))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await brandApi.getBrand(brandId);

        // Assert
        expect(result.id, 'brand-123');
        expect(result.name, 'Tech Corp');
        verify(mockDioClient.dio.get(Endpoints.getBrand(brandId))).called(1);
      });

      test('throws exception when API fails', () async {
        // Arrange
        const brandId = 'brand-123';
        when(mockDioClient.dio.get(Endpoints.getBrand(brandId)))
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => brandApi.getBrand(brandId),
          throwsException,
        );
      });
    });

    group('listBrands', () {
      test('returns list of Brands', () async {
        // Arrange
        final mockResponse = Response(
          data: BrandFixtures.brandDtoList
              .map((b) => b.toJson())
              .toList(),
          statusCode: 200,
          requestOptions: RequestOptions(path: Endpoints.brandBase),
        );

        when(mockDioClient.dio.get(Endpoints.brandBase))
            .thenAnswer((_) async => mockResponse);

        // Act
        final result = await brandApi.listBrands();

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Tech Corp');
        verify(mockDioClient.dio.get(Endpoints.brandBase)).called(1);
      });
    });

    group('createBrand', () {
      test('creates brand successfully', () async {
        // Arrange
        final mockResponse = Response(
          data: BrandFixtures.brandDto.toJson(),
          statusCode: 201,
          requestOptions: RequestOptions(path: Endpoints.brandBase),
        );

        when(mockDioClient.dio.post(
          Endpoints.brandBase,
          data: anyNamed('data'),
        )).thenAnswer((_) async => mockResponse);

        // Act
        final result = await brandApi.createBrand(
          name: 'Tech Corp',
          tagline: 'Innovation at Scale',
          industry: 'Technology',
          website: 'https://techcorp.com',
          logoUrl: 'https://techcorp.com/logo.png',
        );

        // Assert
        expect(result.id, 'brand-123');
        expect(result.name, 'Tech Corp');
        verify(mockDioClient.dio.post(
          Endpoints.brandBase,
          data: anyNamed('data'),
        )).called(1);
      });
    });

    // Similar tests for updateBrand, deleteBrand...
  });
}

// Mock classes
class MockDioClient extends Mock implements DioClient {}
```

### 2.2 Additional API Tests

Create tests for all API classes:

- `test/data/network/apis/knowledge_base/knowledge_base_api_test.dart`
- `test/data/network/apis/link/link_api_test.dart`
- `test/data/network/apis/rewrite_rule/rewrite_rule_api_test.dart`
- `test/data/network/apis/llm_config/llm_config_api_test.dart`
- `test/data/network/apis/brand_positioning/brand_positioning_api_test.dart`
- `test/data/network/apis/project/project_api_test.dart`

---

## Step 3: Unit Tests for Repositories

### 3.1 Brand Repository Tests

**File:** `test/data/repository/brand/brand_repository_test.dart` (NEW)

```dart
import 'package:boilerplate/data/network/apis/brand/brand_api.dart';
import 'package:boilerplate/data/repository/brand/brand_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('BrandRepository', () {
    late BrandRepositoryImpl repository;
    late MockBrandApi mockBrandApi;

    setUp(() {
      mockBrandApi = MockBrandApi();
      repository = BrandRepositoryImpl(mockBrandApi);
    });

    group('getBrand', () {
      test('converts BrandDto to Brand entity', () async {
        // Arrange
        const brandId = 'brand-123';
        when(mockBrandApi.getBrand(brandId))
            .thenAnswer((_) async => BrandFixtures.brandDto);

        // Act
        final result = await repository.getBrand(brandId);

        // Assert
        expect(result.id, 'brand-123');
        expect(result.name, 'Tech Corp');
        verify(mockBrandApi.getBrand(brandId)).called(1);
      });
    });

    group('listBrands', () {
      test('converts list of DTOs to entities', () async {
        // Arrange
        when(mockBrandApi.listBrands())
            .thenAnswer((_) async => BrandFixtures.brandDtoList);

        // Act
        final result = await repository.listBrands();

        // Assert
        expect(result.length, 2);
        expect(result[0].name, 'Tech Corp');
        expect(result[1].name, 'Design Studio');
      });
    });

    // Similar tests for create, update, delete...
  });
}

class MockBrandApi extends Mock implements BrandApi {}
```

---

## Step 4: Unit Tests for Use Cases

### 4.1 Brand Use Case Tests

**File:** `test/domain/usecase/brand/get_brand_usecase_test.dart` (NEW)

```dart
import 'package:boilerplate/domain/repository/brand/brand_repository.dart';
import 'package:boilerplate/domain/usecase/brand/get_brand_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetBrandUseCase', () {
    late GetBrandUseCase useCase;
    late MockBrandRepository mockRepository;

    setUp(() {
      mockRepository = MockBrandRepository();
      useCase = GetBrandUseCase(mockRepository);
    });

    test('calls repository.getBrand with correct id', () async {
      // Arrange
      const params = GetBrandParams(brandId: 'brand-123');
      when(mockRepository.getBrand('brand-123'))
          .thenAnswer((_) async => BrandFixtures.brand);

      // Act
      final result = await useCase(params);

      // Assert
      expect(result.id, 'brand-123');
      verify(mockRepository.getBrand('brand-123')).called(1);
    });

    test('propagates exceptions from repository', () async {
      // Arrange
      const params = GetBrandParams(brandId: 'invalid');
      when(mockRepository.getBrand('invalid'))
          .thenThrow(Exception('Brand not found'));

      // Act & Assert
      expect(() => useCase(params), throwsException);
    });
  });
}

class MockBrandRepository extends Mock implements BrandRepository {}
```

---

## Step 5: MobX Store Tests

### 5.1 Brand Store Tests

**File:** `test/presentation/brand_setup/store/brand_store_test.dart` (NEW)

```dart
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/usecase/brand/brand_usecases.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('BrandStore', () {
    late BrandStore store;
    late MockErrorStore mockErrorStore;
    late MockGetBrandUseCase mockGetBrandUseCase;
    late MockListBrandsUseCase mockListBrandsUseCase;
    late MockCreateBrandUseCase mockCreateBrandUseCase;
    late MockUpdateBrandUseCase mockUpdateBrandUseCase;
    late MockDeleteBrandUseCase mockDeleteBrandUseCase;

    setUp(() {
      mockErrorStore = MockErrorStore();
      mockGetBrandUseCase = MockGetBrandUseCase();
      mockListBrandsUseCase = MockListBrandsUseCase();
      mockCreateBrandUseCase = MockCreateBrandUseCase();
      mockUpdateBrandUseCase = MockUpdateBrandUseCase();
      mockDeleteBrandUseCase = MockDeleteBrandUseCase();

      store = BrandStore(
        errorStore: mockErrorStore,
        getBrandUseCase: mockGetBrandUseCase,
        listBrandsUseCase: mockListBrandsUseCase,
        createBrandUseCase: mockCreateBrandUseCase,
        updateBrandUseCase: mockUpdateBrandUseCase,
        deleteBrandUseCase: mockDeleteBrandUseCase,
      );
    });

    group('listBrands', () {
      test('updates brands list on success', () async {
        // Arrange
        when(mockListBrandsUseCase(any))
            .thenAnswer((_) async => BrandFixtures.brandList);

        // Act
        await store.listBrands();

        // Assert
        expect(store.brands.length, 2);
        expect(store.isSuccess, true);
        verify(mockErrorStore.clearError()).called(1);
      });

      test('sets error on failure', () async {
        // Arrange
        final exception = Exception('Network error');
        when(mockListBrandsUseCase(any)).thenThrow(exception);

        // Act
        await store.listBrands();

        // Assert
        expect(store.isSuccess, false);
        verify(mockErrorStore.setError(exception)).called(1);
      });

      test('sets loading state correctly', () async {
        // Arrange
        when(mockListBrandsUseCase(any))
            .thenAnswer((_) async => BrandFixtures.brandList);

        // Act & Assert
        expect(store.isLoading, false);
        final future = store.listBrands();
        // Note: MobX runs synchronously in tests by default
        await future;
        expect(store.isLoading, false);
      });
    });

    group('createBrand', () {
      test('adds new brand to list', () async {
        // Arrange
        when(mockCreateBrandUseCase(any))
            .thenAnswer((_) async => BrandFixtures.brand);

        // Act
        await store.createBrand(
          name: 'Tech Corp',
          tagline: 'Innovation',
          industry: 'Tech',
          website: 'https://techcorp.com',
        );

        // Assert
        expect(store.brands.length, 1);
        expect(store.currentBrand?.id, 'brand-123');
      });
    });

    // Similar tests for updateBrand, deleteBrand...
  });
}

class MockErrorStore extends Mock implements ErrorStore {}
class MockGetBrandUseCase extends Mock implements GetBrandUseCase {}
class MockListBrandsUseCase extends Mock implements ListBrandsUseCase {}
class MockCreateBrandUseCase extends Mock implements CreateBrandUseCase {}
class MockUpdateBrandUseCase extends Mock implements UpdateBrandUseCase {}
class MockDeleteBrandUseCase extends Mock implements DeleteBrandUseCase {}
```

---

## Step 6: Widget Tests

### 6.1 Brand Setup Screen Test

**File:** `test/presentation/brand_setup/screen/brand_setup_screen_test.dart` (NEW)

```dart
import 'package:boilerplate/presentation/brand_setup/screen/brand_setup_screen.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_setup_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('BrandSetupScreen', () {
    late MockBrandSetupStore mockStore;

    setUp(() {
      mockStore = MockBrandSetupStore();
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      // Arrange
      when(mockStore.isLoading).thenReturn(true);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BrandSetupScreen(),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message', (WidgetTester tester) async {
      // Arrange
      when(mockStore.isLoading).thenReturn(false);
      when(mockStore.errorStore.hasError).thenReturn(true);
      when(mockStore.errorStore.errorMessage).thenReturn('Error message');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BrandSetupScreen(),
        ),
      );

      // Assert
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays brands list', (WidgetTester tester) async {
      // Arrange
      when(mockStore.isLoading).thenReturn(false);
      when(mockStore.brandStore.brands).thenReturn(BrandFixtures.brandList);

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BrandSetupScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ListTile), findsWidgets);
    });
  });
}

class MockBrandSetupStore extends Mock implements BrandSetupStore {}
```

---

## Step 7: Integration Tests

### 7.1 Brand Setup Integration Test

**File:** `test/integration/brand_setup_integration_test.dart` (NEW)

```dart
import 'package:boilerplate/data/repository/brand/brand_repository_impl.dart';
import 'package:boilerplate/domain/usecase/brand/list_brands_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('Brand Setup Integration', () {
    late ListBrandsUseCase listBrandsUseCase;
    late MockBrandRepository mockRepository;

    setUp(() {
      mockRepository = MockBrandRepository();
      listBrandsUseCase = ListBrandsUseCase(mockRepository);
    });

    test('full flow: list brands → update → verify', () async {
      // Arrange
      when(mockRepository.listBrands())
          .thenAnswer((_) async => BrandFixtures.brandList);

      // Act
      final brands = await listBrandsUseCase(NoParams());

      // Assert
      expect(brands.length, greaterThan(0));
      expect(brands[0].name, isNotEmpty);
    });
  });
}

class MockBrandRepository extends Mock implements BrandRepository {}
```

---

## Step 8: Test Configuration

### 8.1 Test Setup File

**File:** `test/test_setup.dart` (NEW)

```dart
import 'package:mockito/mockito.dart';

// Setup global test configuration
void setupTestEnvironment() {
  // Mock setup
  provideDummy<List<Brand>>(const []);
  provideDummy<List<KnowledgeBaseEntry>>(const []);
  // ... other dummies
}
```

### 8.2 Test Helpers

**File:** `test/helpers/test_helpers.dart` (NEW)

```dart
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpTestApp(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: widget,
    ),
  );
}

Future<void> pumpAndSettle(WidgetTester tester) async {
  await tester.pumpAndSettle();
}
```

---

## Step 9: Run Tests

```bash
# Run all tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/data/network/apis/brand/brand_api_test.dart

# Run tests by pattern
flutter test --name="Brand"

# Generate coverage report
lcov --list coverage/lcov.info
```

---

## Test Coverage Goals

| Layer                      | Target Coverage | Files     |
| -------------------------- | --------------- | --------- |
| Data (APIs & Repositories) | 85%+            | 14 files  |
| Domain (Use Cases)         | 90%+            | 25 files  |
| Presentation (Stores)      | 80%+            | 7 files   |
| Widget Tests               | 60%+            | 10 files  |
| **Overall**                | **80%+**        | 56+ files |

---

## Complete Testing Checklist

### Fixtures (7 files)

- [ ] `test/fixtures/brand_fixtures.dart`
- [ ] `test/fixtures/knowledge_base_fixtures.dart`
- [ ] `test/fixtures/link_fixtures.dart`
- [ ] `test/fixtures/rewrite_rule_fixtures.dart`
- [ ] `test/fixtures/llm_config_fixtures.dart`
- [ ] `test/fixtures/brand_positioning_fixtures.dart`
- [ ] `test/fixtures/project_fixtures.dart`

### API Tests (7 files)

- [ ] `test/data/network/apis/brand/brand_api_test.dart`
- [ ] `test/data/network/apis/knowledge_base/knowledge_base_api_test.dart`
- [ ] `test/data/network/apis/link/link_api_test.dart`
- [ ] `test/data/network/apis/rewrite_rule/rewrite_rule_api_test.dart`
- [ ] `test/data/network/apis/llm_config/llm_config_api_test.dart`
- [ ] `test/data/network/apis/brand_positioning/brand_positioning_api_test.dart`
- [ ] `test/data/network/apis/project/project_api_test.dart`

### Repository Tests (7 files)

- [ ] `test/data/repository/brand/brand_repository_test.dart`
- [ ] `test/data/repository/knowledge_base/knowledge_base_repository_test.dart`
- [ ] `test/data/repository/link/link_repository_test.dart`
- [ ] `test/data/repository/rewrite_rule/rewrite_rule_repository_test.dart`
- [ ] `test/data/repository/llm_config/llm_config_repository_test.dart`
- [ ] `test/data/repository/brand_positioning/brand_positioning_repository_test.dart`
- [ ] `test/data/repository/project/project_repository_test.dart`

### Use Case Tests (25+ files)

- [ ] Create test files for all 25+ use cases

### Store Tests (7 files)

- [ ] `test/presentation/brand_setup/store/brand_store_test.dart`
- [ ] `test/presentation/brand_setup/store/knowledge_base_store_test.dart`
- [ ] `test/presentation/brand_setup/store/link_store_test.dart`
- [ ] `test/presentation/brand_setup/store/rewrite_rule_store_test.dart`
- [ ] `test/presentation/brand_setup/store/llm_config_store_test.dart`
- [ ] `test/presentation/brand_setup/store/brand_positioning_store_test.dart`
- [ ] `test/presentation/brand_setup/store/project_store_test.dart`

### Widget Tests (10+ files)

- [ ] `test/presentation/brand_setup/screen/brand_setup_screen_test.dart`
- [ ] `test/presentation/brand_setup/screen/brand_detail_screen_test.dart`
- [ ] `test/presentation/brand_setup/screen/knowledge_base_list_screen_test.dart`
- [ ] (and more for other screens)

### Integration Tests (5+ files)

- [ ] `test/integration/brand_setup_integration_test.dart`
- [ ] `test/integration/knowledge_base_integration_test.dart`
- [ ] `test/integration/full_flow_integration_test.dart`

### Configuration (2 files)

- [ ] `test/test_setup.dart`
- [ ] `test/helpers/test_helpers.dart`

---

## Validation Checklist

Before marking testing complete:

- [ ] All unit tests passing (100%)
- [ ] All integration tests passing
- [ ] Code coverage ≥80%
- [ ] No compilation errors
- [ ] No analyzer warnings
- [ ] All mocks working correctly
- [ ] Test execution time < 2 minutes
- [ ] CI/CD pipeline green

---

## Notes

- Use `@GenerateMocks()` for Mockito mock generation
- Leverage `test` fixtures for consistent test data
- Mock external dependencies (APIs, repositories)
- Test both success and failure paths
- Validate loading/error states
- Use `pumpAndSettle()` for async widgets
- Keep tests focused and independent
