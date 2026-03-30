# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Jarvis AEO** — a Flutter mobile app for Ask Engine Optimization (AEO). Helps businesses monitor and optimize brand visibility across AI chat engines (ChatGPT, Gemini, Perplexity, etc.). Currently built on a MobX + Clean Architecture boilerplate (`package:boilerplate`).

Dart SDK: `>=3.0.6 <4.0.0` | Targets: Android, iOS, Web, macOS, Linux, Windows

## Common Commands

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run                    # default device
flutter run -d chrome          # web
flutter run -d macos            # macOS

# Code generation (MobX stores, JSON serializable)
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch mode for codegen
flutter packages pub run build_runner watch --delete-conflicting-outputs

# Analyze / lint
flutter analyze

# Run tests
flutter test                   # all tests
flutter test test/widget_test.dart  # single test

# Generate launcher icons
flutter packages pub run flutter_launcher_icons:main
```

## Architecture

Clean Architecture with three layers, each with its own DI module. Dependency injection via `get_it`. Entry: `lib/di/service_locator.dart` chains layer injection in order: Data → Domain → Presentation.

### Layer Structure (`lib/`)

**`data/`** — Data layer
- `network/` — Dio HTTP client, API classes (`PostApi`), endpoints, interceptors
- `local/` — Sembast database datasources, DB constants
- `sharedpref/` — SharedPreferences helper, preference key constants
- `repository/` — Repository implementations (implement domain interfaces)
- `di/module/` — DI registration: `LocalModule`, `NetworkModule`, `RepositoryModule`

**`domain/`** — Domain layer (no Flutter imports)
- `entity/` — Data models (`Post`, `PostList`, `User`, `Language`)
- `repository/` — Abstract repository interfaces
- `usecase/` — Business logic use cases extending `UseCase<T, P>` from `core/`
- `di/module/` — `UseCaseModule` registers all use cases

**`presentation/`** — UI layer
- `my_app.dart` — Root MaterialApp widget with theme/locale observers
- `login/`, `home/`, `post/` — Screens with co-located MobX stores (`*_store.dart`)
- `di/module/` — `StoreModule` registers all MobX stores

**`core/`** — Shared base classes
- `data/network/dio/` — Base DioClient, configs, auth/logging/retry interceptors
- `data/local/` — SembastClient, XXTEA encryption
- `stores/` — `ErrorStore`, `FormStore` (reusable MobX stores)
- `domain/usecase/use_case.dart` — Abstract `UseCase<T, P>` base class
- `widgets/` — Reusable widgets (buttons, text fields, progress indicator)

**`constants/`** — App-wide constants (theme, colors, dimens, strings, fonts, assets)
**`utils/`** — Localization, device utils, route definitions, Dio error utilities

### Key Patterns

- **State management**: MobX — stores live next to their screens, generated `.g.dart` files via `build_runner`
- **DI**: `get_it` singleton — access via `getIt<Type>()`. Registration order matters (Data → Domain → Presentation)
- **Networking**: Dio with interceptor chain (Auth → Error → Logging). Base URL: jsonplaceholder (placeholder API)
- **Local storage**: Sembast (document DB) for structured data, SharedPreferences for key-value (auth tokens, settings)
- **Encryption**: XXTEA for local data encryption
- **Localization**: JSON-based (`assets/lang/{en,es,da}.json`) with custom `AppLocalizations` delegate
- **Routing**: Named routes defined in `utils/routes/routes.dart`

### Adding a New Feature

1. Create entity in `domain/entity/`
2. Define repository interface in `domain/repository/`
3. Implement repository in `data/repository/` (register in `RepositoryModule`)
4. Create use cases in `domain/usecase/` (register in `UseCaseModule`)
5. Create MobX store in `presentation/<feature>/store/` (register in `StoreModule`)
6. Build UI screen in `presentation/<feature>/`
7. Add route in `utils/routes/routes.dart`
8. Run `build_runner build` to generate `.g.dart` files

### Submodule

`injection/inject.dart` — Google's inject.dart (referenced in `.gitmodules`)
