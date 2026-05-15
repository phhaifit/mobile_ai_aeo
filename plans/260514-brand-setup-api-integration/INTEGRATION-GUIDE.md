# Phase 2 - Integration Guide & Next Steps

## 🎯 Current Status

**Implementation Level:** 85% Complete (Phase 2)  
**What's Done:** All infrastructure, API clients, domain logic, and state management  
**What's Needed:** UI screens, route integration, and testing

---

## 📋 Immediate Integration Steps

### Step 1: Register DI Modules

Edit `lib/di/service_locator.dart` and add the following:

```dart
// In your domain layer initialization (after existing modules)
await BrandSetupModule.configureBrandSetupModuleInjection();

// In your presentation layer initialization (after existing modules)
await BrandSetupPresentationModule.configureBrandSetupPresentationModuleInjection();
```

**Location to find:** Look for where other modules like `RepositoryModule` are called.

### Step 2: Verify Compilation

```bash
flutter analyze
flutter pub get
flutter run
```

If there are no errors, the DI is properly configured!

---

## 🛠️ Creating UI Screens

### Pattern to Follow

Each feature needs screens following this structure:

```dart
// lib/presentation/brand_setup/screen/brand_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_profile_store.dart';

class BrandProfileScreen extends StatefulWidget {
  @override
  State<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends State<BrandProfileScreen> {
  late BrandProfileStore _store;
  final String _projectId = '...'; // Get from navigation args

  @override
  void initState() {
    super.initState();
    _store = context.read<BrandProfileStore>();
    _store.getBrandProfile(_projectId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Brand Profile')),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (_store.errorMessage != null) {
            return Center(
              child: Text('Error: ${_store.errorMessage}'),
            );
          }

          // Your UI here using _store.brandProfile
          return _buildProfileUI();
        },
      ),
    );
  }

  Widget _buildProfileUI() {
    // Implement your UI
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          child: Column(
            children: [
              // Form fields
              TextFormField(
                // initialization from _store.brandProfile
              ),
              // ... more fields
              ElevatedButton(
                onPressed: () => _store.updateBrandProfile(
                  _projectId,
                  // form data
                ),
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Screens Needed (8 Main Screens)

| Feature           | Screen Name                | Store                    | Actions                      |
| ----------------- | -------------------------- | ------------------------ | ---------------------------- |
| Brand Profile     | BrandProfileScreen         | BrandProfileStore        | View, Save, Update           |
| Knowledge Base    | KnowledgeBaseListScreen    | KnowledgeBaseStore       | List, Add, Edit, Delete      |
| URL Links         | UrlLinkManagementScreen    | UrlLinkStore             | List, Add, Edit, Delete      |
| URL Rewrites      | UrlRewriteManagementScreen | UrlRewriteStore          | List, Add, Edit, Delete      |
| LLM Monitoring    | LlmMonitoringToggleScreen  | LlmMonitoringStore       | View, Toggle                 |
| Polling Config    | LlmPollingFrequencyScreen  | LlmPollingFrequencyStore | View, Update                 |
| Brand Positioning | BrandPositioningScreen     | BrandPositioningStore    | View, Save, Update           |
| Projects          | ProjectManagementScreen    | ProjectStore             | List, Create, Switch, Delete |

---

## 🔀 Navigation Integration

### Add Routes

Create or update your route file (e.g., `lib/routes/routes.dart`):

```dart
class Routes {
  // Brand Setup routes
  static const brandProfileScreen = '/brand-setup/profile';
  static const knowledgeBaseScreen = '/brand-setup/knowledge-base';
  static const urlLinkManagementScreen = '/brand-setup/url-links';
  static const urlRewriteManagementScreen = '/brand-setup/url-rewrites';
  static const llmMonitoringScreen = '/brand-setup/llm-monitoring';
  static const llmPollingFrequencyScreen = '/brand-setup/polling-frequency';
  static const brandPositioningScreen = '/brand-setup/positioning';
  static const projectManagementScreen = '/brand-setup/projects';
}
```

### Register Routes with Navigation

Add in your navigation setup (GoRouter/GetX/etc.):

```dart
// Example with GoRouter
GoRoute(
  path: '/brand-setup/profile',
  builder: (context, state) => BrandProfileScreen(
    projectId: state.extra as String,
  ),
),
// ... repeat for other screens
```

---

## 🧪 Testing Strategy

### Repository Tests

```dart
// test/data/repository/brand_setup/brand_profile_repository_impl_test.dart
void main() {
  group('BrandProfileRepositoryImpl', () {
    late BrandProfileRepositoryImpl repository;
    late MockBrandProfileApi mockApi;

    setUp(() {
      mockApi = MockBrandProfileApi();
      repository = BrandProfileRepositoryImpl(mockApi);
    });

    test('getBrandProfile returns BrandProfile', () async {
      // Arrange
      final mockProfile = BrandProfile(...);
      when(mockApi.getBrandProfile(any)).thenAnswer((_) async => mockProfile);

      // Act
      final result = await repository.getBrandProfile('project-1');

      // Assert
      expect(result, equals(mockProfile));
      verify(mockApi.getBrandProfile('project-1')).called(1);
    });
  });
}
```

### Store Tests

```dart
// test/presentation/brand_setup/store/brand_profile_store_test.dart
void main() {
  group('BrandProfileStore', () {
    late BrandProfileStore store;
    late MockGetBrandProfileUseCase mockGetUseCase;

    setUp(() {
      mockGetUseCase = MockGetBrandProfileUseCase();
      store = BrandProfileStore(mockGetUseCase, ...);
    });

    test('getBrandProfile updates state', () async {
      // Arrange
      final mockProfile = BrandProfile(...);
      when(mockGetUseCase.call(any)).thenAnswer((_) async => mockProfile);

      // Act
      await store.getBrandProfile('project-1');

      // Assert
      expect(store.brandProfile, equals(mockProfile));
      expect(store.isLoading, false);
    });
  });
}
```

---

## 📝 Feature Implementation Checklist

### For Each Feature:

- [ ] Create screen widget
- [ ] Implement form with validation
- [ ] Wire store with Observer
- [ ] Handle loading state
- [ ] Handle error display
- [ ] Add navigation routes
- [ ] Create unit tests (store)
- [ ] Create widget tests (screen)
- [ ] Add integration tests
- [ ] Document API interactions

---

## 🚨 Common Issues & Solutions

### Issue: "Store not found in context"

**Solution:** Make sure DI modules are registered in service_locator.dart

### Issue: "API returns error 401"

**Solution:** Check that AuthInterceptor is properly injected. Token should be in SharedPreferences.

### Issue: "List not updating in UI"

**Solution:** Ensure you're using `ObservableList.of()` to create a new observable list instance when updating.

### Issue: "Build runner not generating .g.dart files"

**Solution:**

```bash
flutter packages pub run build_runner clean
flutter packages pub run build_runner build --delete-conflicting-outputs
```

---

## 📚 File Reference Guide

### Domain Layer

- **Entities:** `lib/domain/entity/brand_setup/*.dart`
- **Repositories:** `lib/domain/repository/brand_setup/*.dart`
- **Use Cases:** `lib/domain/usecase/brand_setup/*.dart`
- **DI Module:** `lib/domain/di/module/brand_setup_module.dart`

### Data Layer

- **APIs:** `lib/data/network/apis/brand_setup/*_api.dart`
- **Implementations:** `lib/data/repository/brand_setup/*_impl.dart`
- **Endpoints:** `lib/data/network/constants/endpoints.dart`

### Presentation Layer

- **Stores:** `lib/presentation/brand_setup/store/*_store.dart`
- **Screens:** `lib/presentation/brand_setup/screen/*.dart` (to be created)
- **DI Module:** `lib/presentation/brand_setup/di/brand_setup_presentation_module.dart`

---

## 🔗 Backend API Integration

The backend API is at: https://github.com/GEO-Brand-Visibility/geo-brand-visibility-be

### Expected API Endpoints

All endpoints are defined in `lib/data/network/constants/endpoints.dart`:

- `GET /api/projects/{projectId}/brand-profile` - Get brand profile
- `POST /api/projects/{projectId}/brand-profile` - Create/save profile
- `PUT /api/projects/{projectId}/brand-profile` - Update profile
- (and similar for other features...)

### Authentication

- Uses `AuthInterceptor` to add auth token to requests
- Token is fetched from `SharedPreferenceHelper.authToken`
- Ensure user is authenticated before making API calls

---

## 📦 Dependencies Used

The implementation uses these existing dependencies:

- `flutter_mobx` - State management
- `mobx` - Reactive programming
- `dio` - HTTP client
- `json_annotation` / `json_serializable` - JSON serialization
- `get_it` - Dependency injection

All are already in your `pubspec.yaml`!

---

## 🎓 Learning Resources

### Clean Architecture

- [Resocoder - Clean Architecture Course](https://resocoder.com/)
- Repository pattern, use cases, and entity concepts

### MobX

- [MobX Docs](https://mobx.surge.sh/)
- Observable, actions, and reactions

### Flutter Best Practices

- Follow existing patterns in `lib/presentation/` for other features
- Check how other stores like `AnalyticsStore` are implemented

---

## ✅ Completion Checklist

Before considering Phase 2 complete:

- [ ] All DI modules registered in service_locator
- [ ] No compilation errors (`flutter analyze`)
- [ ] All UI screens implemented
- [ ] Navigation routes configured
- [ ] API calls working (test with backend)
- [ ] Error handling verified
- [ ] Loading states working
- [ ] Unit tests written (70%+ coverage)
- [ ] Integration tests written
- [ ] Code review completed
- [ ] Documentation updated

---

## 📞 Support & Debugging

### Enable Logging

```dart
// In DioClin t initialization
mainClient.addInterceptors([
  getIt<LoggingInterceptor>(),
  // ... other interceptors
]);
```

### Check Network Calls

Use DevTools or Fiddler to inspect:

- Request headers (auth token)
- Request body/response
- Response status codes

### Test Stores in Isolation

Use `@observable` getters and setters in tests to verify state changes.

---

## 🚀 Deployment Readiness

Before deploying to production:

1. Ensure all error states are handled gracefully
2. Add proper logging for debugging
3. Test with actual backend API
4. Verify auth token refresh logic
5. Test on multiple devices/screen sizes
6. Performance test with large lists
7. Add error reporting/analytics
8. Security review (no hardcoded secrets)

---

**Next Step:** Create the first UI screen and test store integration! 🎉

Generated: 2025-05-14
