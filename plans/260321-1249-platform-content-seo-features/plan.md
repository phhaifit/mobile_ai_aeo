---
title: "Platform, Content Enhancement & Technical SEO Features"
description: "Implementation plan for analytics/error-tracking foundation, AI content tools, and technical SEO audit features"
status: pending
priority: P1
effort: 32h
branch: main
tags: [analytics, sentry, firebase, content-ai, seo, clean-architecture]
created: 2026-03-21
---

# Platform, Content Enhancement & Technical SEO Features

## Overview

Three features for Jarvis AEO Flutter app, ordered by dependency:
1. **Platform & Analytics** (Feature 13) -- foundation infra all other features depend on
2. **Content Enhancement** (Feature 8) -- AI-powered content tools
3. **Technical SEO** (Feature 12) -- website audit & optimization tools

## Current State

- Boilerplate Flutter app with Clean Architecture (Data/Domain/Presentation)
- MobX state management, get_it DI, Dio HTTP, Sembast local DB
- Package name still `boilerplate`, app name "Boilerplate Project"
- Base URL: jsonplaceholder.typicode.com (placeholder)
- Android applicationId: `com.iotecksolutions.todoapp` (needs changing)
- User entity is empty; auth is mock SharedPreferences only
- No analytics, no error tracking, no CI/CD

## Phases

| # | Phase | Status | Effort | File |
|---|-------|--------|--------|------|
| 1 | Platform & Analytics Foundation | pending | 10h | [phase-01](./phase-01-platform-analytics.md) |
| 2 | Content Enhancement | pending | 10h | [phase-02](./phase-02-content-enhancement.md) |
| 3 | Technical SEO | pending | 8h | [phase-03](./phase-03-technical-seo.md) |
| 4 | Testing & Integration | pending | 4h | [phase-04](./phase-04-testing-integration.md) |

## Key Dependencies

- Phase 1 MUST complete first (provides API client config, error tracking, analytics)
- Phase 2 & 3 can proceed in parallel after Phase 1
- Phase 4 runs after all implementation phases

## Architecture Decisions

- **API Base URL**: Configurable via environment/flavor (dev/staging/prod)
- **AI Integration**: Dedicated `AiApiClient` with separate base URL for AI services
- **Error Tracking**: Sentry for crash/error reporting
- **Analytics**: Firebase Analytics (Google Analytics for Firebase)
- **CI/CD**: GitHub Actions for build, test, deploy

## Unresolved Questions

1. What is the actual backend API base URL for Jarvis AEO services?
2. Which AI service provider for content enhancement (OpenAI, Gemini, custom)?
3. App bundle IDs for iOS/Android (currently placeholder IDs)?
4. Firebase project configuration (google-services.json / GoogleService-Info.plist)?
5. Sentry DSN for error tracking?
6. App Store / Play Store accounts and signing keys?
