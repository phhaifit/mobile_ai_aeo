# Phase 4: Presentation Layer

## Objective

Implement MobX stores for state management and update UI screens to consume API data.

## Overview

| Component       | Count    | Status  |
| --------------- | -------- | ------- |
| MobX Stores     | 7        | pending |
| UI Screens      | 7-10     | pending |
| Screen Updates  | 2-3      | pending |
| DI Registration | 1 module | pending |

---

## Step 1: Create MobX Stores

### 1.1 Brand Store

**File:** `lib/presentation/brand_setup/store/brand_store.dart` (NEW)

```dart
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/brand/brand.dart';
import 'package:boilerplate/domain/usecase/brand/brand_usecases.dart';
import 'package:mobx/mobx.dart';

part 'brand_store.g.dart';

class BrandStore = _BrandStore with _$BrandStore;

abstract class _BrandStore with Store {
  final ErrorStore errorStore;
  final GetBrandUseCase _getBrandUseCase;
  final ListBrandsUseCase _listBrandsUseCase;
  final CreateBrandUseCase _createBrandUseCase;
  final UpdateBrandUseCase _updateBrandUseCase;
  final DeleteBrandUseCase _deleteBrandUseCase;

  _BrandStore({
    required this.errorStore,
    required GetBrandUseCase getBrandUseCase,
    required ListBrandsUseCase listBrandsUseCase,
    required CreateBrandUseCase createBrandUseCase,
    required UpdateBrandUseCase updateBrandUseCase,
    required DeleteBrandUseCase deleteBrandUseCase,
  })  : _getBrandUseCase = getBrandUseCase,
        _listBrandsUseCase = listBrandsUseCase,
        _createBrandUseCase = createBrandUseCase,
        _updateBrandUseCase = updateBrandUseCase,
        _deleteBrandUseCase = deleteBrandUseCase;

  @observable
  Brand? currentBrand;

  @observable
  List<Brand> brands = [];

  @observable
  bool isLoading = false;

  @observable
  bool isSuccess = false;

  @computed
  bool get hasError => errorStore.hasError;

  @action
  Future<void> getBrand(String brandId) async {
    _setBusy(true);
    try {
      currentBrand = await _getBrandUseCase(
        GetBrandParams(brandId: brandId),
      );
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> listBrands() async {
    _setBusy(true);
    try {
      brands = await _listBrandsUseCase(NoParams());
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> createBrand({
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
  }) async {
    _setBusy(true);
    try {
      final brand = await _createBrandUseCase(
        CreateBrandParams(
          name: name,
          tagline: tagline,
          industry: industry,
          website: website,
          logoUrl: logoUrl,
        ),
      );
      brands = [...brands, brand];
      currentBrand = brand;
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> updateBrand({
    required String brandId,
    required String name,
    required String tagline,
    required String industry,
    required String website,
    String? logoUrl,
  }) async {
    _setBusy(true);
    try {
      final updatedBrand = await _updateBrandUseCase(
        UpdateBrandParams(
          brandId: brandId,
          name: name,
          tagline: tagline,
          industry: industry,
          website: website,
          logoUrl: logoUrl,
        ),
      );
      final index = brands.indexWhere((b) => b.id == brandId);
      if (index >= 0) {
        brands = [
          ...brands.sublist(0, index),
          updatedBrand,
          ...brands.sublist(index + 1),
        ];
      }
      currentBrand = updatedBrand;
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> deleteBrand(String brandId) async {
    _setBusy(true);
    try {
      await _deleteBrandUseCase(DeleteBrandParams(brandId: brandId));
      brands = brands.where((b) => b.id != brandId).toList();
      if (currentBrand?.id == brandId) {
        currentBrand = null;
      }
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    isLoading = value;
  }
}
```

### 1.2 Knowledge Base Store

**File:** `lib/presentation/brand_setup/store/knowledge_base_store.dart` (NEW)

```dart
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/knowledge_base/knowledge_base_entry.dart';
import 'package:boilerplate/domain/usecase/knowledge_base/knowledge_base_usecases.dart';
import 'package:mobx/mobx.dart';

part 'knowledge_base_store.g.dart';

class KnowledgeBaseStore = _KnowledgeBaseStore with _$KnowledgeBaseStore;

abstract class _KnowledgeBaseStore with Store {
  final ErrorStore errorStore;
  // Inject use cases...

  _KnowledgeBaseStore({
    required this.errorStore,
    // Inject use cases as parameters
  });

  @observable
  List<KnowledgeBaseEntry> entries = [];

  @observable
  KnowledgeBaseEntry? selectedEntry;

  @observable
  bool isLoading = false;

  @observable
  bool isSuccess = false;

  @computed
  bool get hasError => errorStore.hasError;

  @action
  Future<void> listEntries(String brandId) async {
    _setBusy(true);
    try {
      entries = await _listEntriesUseCase(
        ListKbEntriesParams(brandId: brandId),
      );
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> createEntry({
    required String brandId,
    required String title,
    required String type,
    required String content,
    String? url,
    String? category,
    List<String>? tags,
  }) async {
    _setBusy(true);
    try {
      final entry = await _createEntryUseCase(
        CreateKbEntryParams(
          brandId: brandId,
          title: title,
          type: type,
          content: content,
          url: url,
          category: category,
          tags: tags,
        ),
      );
      entries = [...entries, entry];
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> updateEntry({
    required String brandId,
    required String entryId,
    required String title,
    required String type,
    required String content,
    String? url,
    String? category,
    List<String>? tags,
  }) async {
    _setBusy(true);
    try {
      final updated = await _updateEntryUseCase(
        UpdateKbEntryParams(
          brandId: brandId,
          entryId: entryId,
          title: title,
          type: type,
          content: content,
          url: url,
          category: category,
          tags: tags,
        ),
      );
      final index = entries.indexWhere((e) => e.id == entryId);
      if (index >= 0) {
        entries = [
          ...entries.sublist(0, index),
          updated,
          ...entries.sublist(index + 1),
        ];
      }
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  @action
  Future<void> deleteEntry({required String brandId, required String entryId}) async {
    _setBusy(true);
    try {
      await _deleteEntryUseCase(
        DeleteKbEntryParams(brandId: brandId, entryId: entryId),
      );
      entries = entries.where((e) => e.id != entryId).toList();
      isSuccess = true;
      errorStore.clearError();
    } catch (e) {
      errorStore.setError(e);
    } finally {
      _setBusy(false);
    }
  }

  void _setBusy(bool value) {
    isLoading = value;
  }
}
```

### 1.3-1.7 Other Stores (Similar Pattern)

Create the following stores with same pattern:

- `lib/presentation/brand_setup/store/link_store.dart`
- `lib/presentation/brand_setup/store/rewrite_rule_store.dart`
- `lib/presentation/brand_setup/store/llm_config_store.dart`
- `lib/presentation/brand_setup/store/brand_positioning_store.dart`
- `lib/presentation/brand_setup/store/project_store.dart`

---

## Step 2: Update Main Brand Setup Store

**File:** `lib/presentation/brand_setup/store/brand_setup_store.dart` (UPDATE)

Integrate all sub-stores into main store:

```dart
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/knowledge_base_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/link_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/rewrite_rule_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/llm_config_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_positioning_store.dart';
import 'package:boilerplate/presentation/brand_setup/store/project_store.dart';
import 'package:mobx/mobx.dart';

part 'brand_setup_store.g.dart';

class BrandSetupStore = _BrandSetupStore with _$BrandSetupStore;

abstract class _BrandSetupStore with Store {
  final ErrorStore errorStore;
  final BrandStore brandStore;
  final KnowledgeBaseStore knowledgeBaseStore;
  final LinkStore linkStore;
  final RewriteRuleStore rewriteRuleStore;
  final LlmConfigStore llmConfigStore;
  final BrandPositioningStore brandPositioningStore;
  final ProjectStore projectStore;

  _BrandSetupStore({
    required this.errorStore,
    required this.brandStore,
    required this.knowledgeBaseStore,
    required this.linkStore,
    required this.rewriteRuleStore,
    required this.llmConfigStore,
    required this.brandPositioningStore,
    required this.projectStore,
  });

  @observable
  int selectedTabIndex = 0;

  @action
  void selectTab(int index) {
    selectedTabIndex = index;
  }

  @computed
  bool get isLoading =>
      brandStore.isLoading ||
      knowledgeBaseStore.isLoading ||
      linkStore.isLoading ||
      rewriteRuleStore.isLoading ||
      llmConfigStore.isLoading ||
      brandPositioningStore.isLoading ||
      projectStore.isLoading;
}
```

---

## Step 3: Create/Update UI Screens

### 3.1 Brand Setup Main Screen

**File:** `lib/presentation/brand_setup/screen/brand_setup_screen.dart` (UPDATE)

```dart
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_setup_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BrandSetupScreen extends StatefulWidget {
  const BrandSetupScreen({Key? key}) : super(key: key);

  @override
  State<BrandSetupScreen> createState() => _BrandSetupScreenState();
}

class _BrandSetupScreenState extends State<BrandSetupScreen> {
  late final BrandSetupStore _store;

  @override
  void initState() {
    super.initState();
    _store = getIt<BrandSetupStore>();
    _loadInitialData();
  }

  void _loadInitialData() {
    _store.brandStore.listBrands();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Setup'),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_store.errorStore.hasError) {
            return Center(
              child: Text('Error: ${_store.errorStore.errorMessage}'),
            );
          }

          return TabBarView(
            children: [
              _buildBrandTab(),
              _buildKnowledgeBaseTab(),
              _buildLinksTab(),
              _buildRewriteRulesTab(),
              _buildLlmConfigTab(),
              _buildPositioningTab(),
              _buildProjectsTab(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBrandTab() {
    return Observer(
      builder: (_) => ListView(
        children: [
          ..._store.brandStore.brands.map((brand) {
            return ListTile(
              title: Text(brand.name),
              subtitle: Text(brand.tagline),
              onTap: () {
                // Navigate to brand detail
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildKnowledgeBaseTab() {
    return Observer(
      builder: (_) => ListView(
        children: [
          ..._store.knowledgeBaseStore.entries.map((entry) {
            return ListTile(
              title: Text(entry.title),
              subtitle: Text(entry.type),
              trailing: Text(entry.status),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Implement other tabs similarly...
  Widget _buildLinksTab() => const SizedBox();
  Widget _buildRewriteRulesTab() => const SizedBox();
  Widget _buildLlmConfigTab() => const SizedBox();
  Widget _buildPositioningTab() => const SizedBox();
  Widget _buildProjectsTab() => const SizedBox();
}
```

### 3.2 Brand Create/Edit Screen

**File:** `lib/presentation/brand_setup/screen/brand_detail_screen.dart` (NEW)

```dart
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/brand_setup/store/brand_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class BrandDetailScreen extends StatefulWidget {
  final String? brandId;

  const BrandDetailScreen({Key? key, this.brandId}) : super(key: key);

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  late final BrandStore _store;
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _store = getIt<BrandStore>();
    if (widget.brandId != null) {
      _store.getBrand(widget.brandId!).then((_) {
        if (_store.currentBrand != null) {
          _populateFields(_store.currentBrand!);
        }
      });
    }
  }

  void _populateFields(Brand brand) {
    _nameController.text = brand.name;
    _taglineController.text = brand.tagline;
    _industryController.text = brand.industry;
    _websiteController.text = brand.website;
    _logoUrlController.text = brand.logoUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brandId == null ? 'Create Brand' : 'Edit Brand'),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextfieldWidget(
                    hint: 'Brand Name',
                    controller: _nameController,
                  ),
                  const SizedBox(height: 16),
                  TextfieldWidget(
                    hint: 'Tagline',
                    controller: _taglineController,
                  ),
                  const SizedBox(height: 16),
                  TextfieldWidget(
                    hint: 'Industry',
                    controller: _industryController,
                  ),
                  const SizedBox(height: 16),
                  TextfieldWidget(
                    hint: 'Website URL',
                    controller: _websiteController,
                  ),
                  const SizedBox(height: 16),
                  TextfieldWidget(
                    hint: 'Logo URL (optional)',
                    controller: _logoUrlController,
                  ),
                  const SizedBox(height: 24),
                  RoundedButtonWidget(
                    buttonText: widget.brandId == null ? 'Create' : 'Update',
                    onPressed: _onSave,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _onSave() async {
    if (widget.brandId == null) {
      await _store.createBrand(
        name: _nameController.text,
        tagline: _taglineController.text,
        industry: _industryController.text,
        website: _websiteController.text,
        logoUrl: _logoUrlController.text.isEmpty ? null : _logoUrlController.text,
      );
    } else {
      await _store.updateBrand(
        brandId: widget.brandId!,
        name: _nameController.text,
        tagline: _taglineController.text,
        industry: _industryController.text,
        website: _websiteController.text,
        logoUrl: _logoUrlController.text.isEmpty ? null : _logoUrlController.text,
      );
    }

    if (_store.isSuccess && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }
}
```

### 3.3 Similar Screens to Create

Create detailed screens for:

- Knowledge Base entry management
- Link management
- Rewrite rule management
- LLM configuration
- Brand positioning
- Project management

Each following similar pattern: detail form + CRUD operations via store.

---

## Step 4: Update DI Registration

**File:** `lib/presentation/di/module/store_module.dart` (UPDATE)

```dart
class StoreModule {
  static Future<void> configurePresentationLayerInjection() async {
    // ─── Existing stores ──────────────────────────────────────────────
    // ... existing code ...

    // ─── Brand Setup Sub-Stores (NEW) ─────────────────────────────────
    getIt.registerSingleton(
      BrandStore(
        errorStore: getIt(),
        getBrandUseCase: getIt(),
        listBrandsUseCase: getIt(),
        createBrandUseCase: getIt(),
        updateBrandUseCase: getIt(),
        deleteBrandUseCase: getIt(),
      ),
    );

    getIt.registerSingleton(
      KnowledgeBaseStore(
        errorStore: getIt(),
        getEntryUseCase: getIt(),
        listEntriesUseCase: getIt(),
        createEntryUseCase: getIt(),
        updateEntryUseCase: getIt(),
        deleteEntryUseCase: getIt(),
        bulkDeleteEntriesUseCase: getIt(),
      ),
    );

    // Register other stores similarly...
    getIt.registerSingleton(LinkStore(...));
    getIt.registerSingleton(RewriteRuleStore(...));
    getIt.registerSingleton(LlmConfigStore(...));
    getIt.registerSingleton(BrandPositioningStore(...));
    getIt.registerSingleton(ProjectStore(...));

    // ─── Main Brand Setup Store (UPDATE) ──────────────────────────────
    getIt.registerSingleton(
      BrandSetupStore(
        errorStore: getIt(),
        brandStore: getIt(),
        knowledgeBaseStore: getIt(),
        linkStore: getIt(),
        rewriteRuleStore: getIt(),
        llmConfigStore: getIt(),
        brandPositioningStore: getIt(),
        projectStore: getIt(),
      ),
    );
  }
}
```

---

## Complete Presentation Layer Checklist

### MobX Stores to Create (7 files)

- [ ] `lib/presentation/brand_setup/store/brand_store.dart`
- [ ] `lib/presentation/brand_setup/store/knowledge_base_store.dart`
- [ ] `lib/presentation/brand_setup/store/link_store.dart`
- [ ] `lib/presentation/brand_setup/store/rewrite_rule_store.dart`
- [ ] `lib/presentation/brand_setup/store/llm_config_store.dart`
- [ ] `lib/presentation/brand_setup/store/brand_positioning_store.dart`
- [ ] `lib/presentation/brand_setup/store/project_store.dart`

### UI Screens to Create (7-10 files)

- [ ] `lib/presentation/brand_setup/screen/brand_detail_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/knowledge_base_list_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/knowledge_base_detail_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/link_list_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/link_detail_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/rewrite_rule_list_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/rewrite_rule_detail_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/llm_config_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/brand_positioning_screen.dart`
- [ ] `lib/presentation/brand_setup/screen/project_list_screen.dart`

### Files to Update

- [ ] `lib/presentation/brand_setup/store/brand_setup_store.dart` - Integrate sub-stores
- [ ] `lib/presentation/brand_setup/screen/brand_setup_screen.dart` - Add tabs, data binding
- [ ] `lib/presentation/di/module/store_module.dart` - Register all stores
- [ ] `lib/utils/routes/routes.dart` - Add new routes

### After Implementation

```bash
# Generate MobX observables
flutter packages pub run build_runner build --delete-conflicting-outputs

# Verify compilation
flutter analyze

# Check for unused code
# dart tool/analyze_unused.dart
```

---

## Design Patterns

### Observable Pattern (MobX)

```dart
@observable
List<Item> items = [];

@action
void addItem(Item item) {
  items = [...items, item];
}

@computed
int get itemCount => items.length;
```

### Error Handling in Stores

```dart
@action
Future<void> doSomething() async {
  try {
    // operation
    isSuccess = true;
    errorStore.clearError();
  } catch (e) {
    errorStore.setError(e);
    isSuccess = false;
  } finally {
    isLoading = false;
  }
}
```

### UI Binding

```dart
Observer(
  builder: (_) {
    if (store.isLoading) return LoadingWidget();
    if (store.hasError) return ErrorWidget();
    return DataWidget(data: store.data);
  },
)
```

---

## Screen Structure

Each detail screen follows:

1. **Load state** if editing (fetch current data)
2. **Form fields** for input
3. **Save button** triggering store action
4. **Success feedback** (toast/dialog or navigate back)
5. **Error feedback** via errorStore

Prefer composition over large monolithic screens.
