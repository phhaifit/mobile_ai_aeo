---
title: "Phase 1: Platform & Analytics Foundation"
status: pending
priority: P1
effort: 10h
issue: "#11"
---

# Phase 1: Platform & Analytics Foundation (Feature 13)

## Context Links

- [Issue #11](../../issues/11)
- [CLAUDE.md](../../CLAUDE.md) -- architecture reference
- [Endpoints](../../lib/data/network/constants/endpoints.dart)
- [Main entry](../../lib/main.dart)
- [Service Locator](../../lib/di/service_locator.dart)

## Overview

Bootstrap the app from boilerplate to Jarvis AEO identity. Add environment configuration, Firebase Analytics, Sentry error tracking, and CI/CD pipeline. This phase is foundational -- all other features depend on it.

## Key Insights

- Package name is still `boilerplate` everywhere (imports, pubspec)
- Android applicationId is `com.iotecksolutions.todoapp` -- must change
- App name is "Boilerplate Project" in `lib/constants/strings.dart`
- No environment configuration system exists -- base URL is hardcoded
- `main.dart` has no error zone or async error handling
- DioClient is a plain wrapper; needs interceptor for analytics/tracking

## Requirements

### Functional
- FR1: App branding updated (name, icons, splash)
- FR2: Environment config (dev/staging/prod) with separate API URLs
- FR3: Google Analytics (Firebase) tracking page views + key events
- FR4: Sentry captures unhandled exceptions + Dio network errors
- FR5: CI/CD pipeline builds, tests, and deploys (Android + iOS)

### Non-Functional
- NFR1: Analytics must not block UI thread
- NFR2: Sentry must capture breadcrumbs for debugging context
- NFR3: Environment secrets must NOT be committed to git

## Architecture

```
main.dart
  -> SentryFlutter.init() wraps runApp
  -> Firebase.initializeApp()
  -> ServiceLocator.configureDependencies()
     -> NetworkModule now reads env config for base URL
     -> AnalyticsModule (new) registers AnalyticsService
```

**New DI flow**: Data layer gets `EnvironmentConfig` + `AnalyticsModule`

## Related Code Files

### Files to MODIFY

| File | Changes |
|------|---------|
| `pubspec.yaml` | Add firebase_core, firebase_analytics, sentry_flutter, flutter_dotenv deps; rename package |
| `lib/main.dart` | Wrap with Sentry, init Firebase, load env |
| `lib/constants/strings.dart` | App name -> "Jarvis AEO" |
| `lib/data/network/constants/endpoints.dart` | Read base URL from env config instead of hardcode |
| `lib/data/di/module/network_module.dart` | Use env config for DioConfigs base URL |
| `lib/data/di/data_layer_injection.dart` | Register AnalyticsModule |
| `lib/di/service_locator.dart` | Init env before DI chain |
| `android/app/build.gradle` | Change applicationId, add firebase/sentry plugins |
| `ios/Runner/Info.plist` | Update bundle name and display name |
| `android/app/src/main/AndroidManifest.xml` | Update app label |

### Files to CREATE

| File | Purpose |
|------|---------|
| `lib/core/config/environment_config.dart` | Environment enum + config holder (baseUrl, sentryDsn, etc.) |
| `lib/core/config/app_config.dart` | Static app-wide config constants (app name, version) |
| `lib/data/di/module/analytics_module.dart` | DI registration for analytics + error tracking services |
| `lib/core/services/analytics_service.dart` | Abstraction over Firebase Analytics |
| `lib/core/services/error_tracking_service.dart` | Abstraction over Sentry |
| `lib/core/data/network/dio/interceptors/analytics_interceptor.dart` | Dio interceptor for network analytics breadcrumbs |
| `.env.dev` | Dev environment variables (git-ignored) |
| `.env.staging` | Staging environment variables (git-ignored) |
| `.env.prod` | Prod environment variables (git-ignored) |
| `.env.example` | Template showing required env vars (committed) |
| `.github/workflows/ci.yml` | GitHub Actions: lint, test, build |
| `.github/workflows/deploy-android.yml` | Android build + Play Store deploy |
| `.github/workflows/deploy-ios.yml` | iOS build + TestFlight deploy |

## Implementation Steps

### Step 1: Environment Configuration (2h)

1. Create `lib/core/config/environment_config.dart`:
   - `enum Environment { dev, staging, prod }`
   - `class EnvironmentConfig` with fields: `apiBaseUrl`, `sentryDsn`, `analyticsEnabled`
   - Factory `fromEnv()` reads from `flutter_dotenv`
2. Create `.env.example` with keys: `API_BASE_URL`, `SENTRY_DSN`, `ANALYTICS_ENABLED`
3. Create `.env.dev` with dev values (add `.env*` to `.gitignore`, except `.env.example`)
4. Add `flutter_dotenv: ^5.1.0` to `pubspec.yaml`
5. Update `pubspec.yaml` assets to include `.env` files
6. Update `lib/main.dart` to load dotenv before DI
7. Update `lib/data/network/constants/endpoints.dart`:
   - Remove hardcoded `baseUrl`
   - Read from `EnvironmentConfig` via getIt
8. Update `lib/data/di/module/network_module.dart`:
   - Register `EnvironmentConfig` singleton
   - Use config for `DioConfigs` base URL

### Step 2: App Branding (1h)

1. Update `lib/constants/strings.dart`: `appName = "Jarvis AEO"`
2. Create `lib/core/config/app_config.dart` with version, app name constants
3. Update `android/app/build.gradle`:
   - `applicationId` -> `com.jarvisaeo.app` (or actual ID when confirmed)
   - `namespace` -> match applicationId
4. Update `ios/Runner/Info.plist`:
   - `CFBundleName` -> "Jarvis AEO"
   - `CFBundleDisplayName` -> "Jarvis AEO"
5. Update `android/app/src/main/AndroidManifest.xml` `android:label`
6. Replace launcher icons (when assets provided) via `flutter_launcher_icons`

### Step 3: Firebase Analytics (2h)

1. Add to `pubspec.yaml`: `firebase_core: ^3.8.0`, `firebase_analytics: ^11.4.0`
2. Create `lib/core/services/analytics_service.dart`:
   - `class AnalyticsService` wrapping `FirebaseAnalytics`
   - Methods: `logScreenView(screenName)`, `logEvent(name, params)`, `setUserId(id)`
   - Guard all calls with `EnvironmentConfig.analyticsEnabled` check
3. Create `lib/data/di/module/analytics_module.dart`:
   - Register `AnalyticsService` singleton
4. Update `lib/data/di/data_layer_injection.dart` to call `AnalyticsModule`
5. Update `lib/main.dart`:
   - Add `await Firebase.initializeApp()` before DI
6. Add `NavigatorObserver` from FirebaseAnalytics to `MyApp` for auto screen tracking
7. Note: `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) must be provided separately and git-ignored

### Step 4: Sentry Error Tracking (2h)

1. Add to `pubspec.yaml`: `sentry_flutter: ^8.12.0`, `sentry_dio: ^8.12.0`
2. Create `lib/core/services/error_tracking_service.dart`:
   - `class ErrorTrackingService` wrapping Sentry
   - Methods: `captureException(error, stackTrace)`, `addBreadcrumb(message)`, `setUser(id, email)`
3. Update `lib/main.dart`:
   - Wrap `runApp` with `SentryFlutter.init()` using DSN from env config
   - Set `environment` from `EnvironmentConfig`
4. Create `lib/core/data/network/dio/interceptors/analytics_interceptor.dart`:
   - Logs Dio request/response as Sentry breadcrumbs
   - Captures failed requests as Sentry events
5. Update `lib/data/di/module/network_module.dart`:
   - Add analytics interceptor to Dio interceptor chain
6. Register `ErrorTrackingService` in `AnalyticsModule`

### Step 5: CI/CD Pipeline (3h)

1. Create `.github/workflows/ci.yml`:
   - Trigger: push to main, PRs
   - Steps: checkout, setup Flutter, pub get, analyze, test
2. Create `.github/workflows/deploy-android.yml`:
   - Trigger: tag push `v*`
   - Steps: build appbundle, sign, upload to Play Store (via fastlane or gradle)
3. Create `.github/workflows/deploy-ios.yml`:
   - Trigger: tag push `v*`
   - Steps: build ipa, sign, upload to TestFlight
4. Add secrets to GitHub: signing keys, Firebase config, Sentry DSN
5. Update `.gitignore` for generated/secret files

## Todo List

- [ ] Add flutter_dotenv, firebase_core, firebase_analytics, sentry_flutter, sentry_dio to pubspec.yaml
- [ ] Create EnvironmentConfig class with dotenv loading
- [ ] Create .env.example and .env.dev files
- [ ] Update .gitignore for .env files and Firebase configs
- [ ] Update Endpoints to use EnvironmentConfig
- [ ] Update NetworkModule to use EnvironmentConfig for base URL
- [ ] Update app name in strings.dart, Android manifest, iOS Info.plist
- [ ] Change Android applicationId from todoapp placeholder
- [ ] Create AnalyticsService wrapping Firebase Analytics
- [ ] Create ErrorTrackingService wrapping Sentry
- [ ] Create AnalyticsModule for DI registration
- [ ] Update main.dart with Firebase init, Sentry init, dotenv loading
- [ ] Create analytics Dio interceptor for breadcrumbs
- [ ] Add NavigatorObserver for screen tracking in MyApp
- [ ] Create CI workflow (.github/workflows/ci.yml)
- [ ] Create Android deploy workflow
- [ ] Create iOS deploy workflow
- [ ] Run `flutter pub get` and `flutter analyze` to verify
- [ ] Run `build_runner build` to regenerate .g.dart files if needed

## Success Criteria

- `flutter analyze` passes with no errors
- `flutter test` passes
- App launches with "Jarvis AEO" branding
- Analytics events fire in Firebase debug view
- Unhandled exceptions appear in Sentry dashboard
- CI pipeline runs on PR push

## Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| Firebase config files missing | Build fails | Provide .env.example, document setup steps |
| Sentry DSN not configured | Silent fail | EnvironmentConfig defaults to disabled |
| Package rename breaks imports | Compile error | Global find-replace `boilerplate` -> new name carefully |
| CI secrets not configured | Deploy fails | CI.yml works for lint/test without secrets; deploy jobs require secrets |

## Security Considerations

- `.env*` files (except `.env.example`) MUST be in `.gitignore`
- `google-services.json` and `GoogleService-Info.plist` MUST be in `.gitignore`
- Sentry DSN is not secret but should be env-specific
- Signing keys for app stores stored ONLY in CI secrets, never in repo
- Auth tokens stored via SharedPreferences (existing) -- consider secure_storage in future

## Next Steps

- After this phase, Phase 2 (Content Enhancement) and Phase 3 (Technical SEO) can begin in parallel
- Both will use the `EnvironmentConfig` for API URLs and `AnalyticsService` for tracking
