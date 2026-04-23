# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Backend API for AEO.how — a GEO (Generative Engine Optimization) platform that tracks brand visibility across AI chatbots (ChatGPT, Gemini, etc.) and generates SEO/AEO-optimized content. Built with NestJS 11, TypeScript, Supabase, BullMQ, and Redis.

**Business context:** AEO helps businesses monitor how AI chatbots talk about their brand, generate optimized content (blog posts, social media), and host public blogs with custom domains. The backend is the core API serving the Next.js frontend (port 3000) and coordinating with Python AI agents and N8N workflows.

## Commands

```bash
pnpm start:dev              # Start API server (watch mode) on port 3001
pnpm build                  # Production build
pnpm lint                   # ESLint with auto-fix
pnpm check:lint             # ESLint check only
pnpm check:types            # TypeScript type checking (tsc --noEmit)
pnpm check:format           # Prettier check
pnpm format                 # Prettier auto-format
pnpm test                   # Run Jest tests
pnpm test:watch             # Jest watch mode
pnpm test:cov               # Jest with coverage
pnpm test:e2e               # End-to-end tests
```

Run a single test file: `pnpm jest -- path/to/file.spec.ts`

### Workers (separate processes)

```bash
pnpm start:analyze:dev      # ProjectAnalysis worker (watch)
pnpm start:project:dev      # CreateProject worker (watch)
pnpm start:content:dev      # ContentGeneration worker (watch)
```

### Database

```bash
pnpm gen:types               # Regenerate Supabase TypeScript types
pnpm migrate:up              # Run pending migrations
pnpm create:migration        # Create new migration file
```

## Architecture

### Module Structure

Every module follows this pattern — no exceptions:

```
src/<module>/
├── <module>.controller.ts   — Routes, decorators, DTO validation
├── <module>.service.ts      — Business logic, orchestration
├── <module>.repository.ts   — ALL database queries (single source of DB access)
├── <module>.module.ts       — NestJS module wiring
└── dto/                     — Request/response DTOs with class-validator
```

### Key Modules (42 total)

| Module | Business Purpose |
|--------|-----------------|
| `auth/` | JWT + Google OAuth (PKCE). Global `JwtAuthGuard` on all routes. `@Public()` exempts public endpoints. |
| `project/` | Project lifecycle (DRAFT→ACTIVE→ARCHIVED). Holds LLM model selection, monitoring config. |
| `brand/` | Brand profile (1:1 with Project). Name, domain, industry, services, logo, blog settings, custom domain. |
| `topic/` | AI-generated topic suggestions per project. Each topic has prompts and keywords. |
| `prompt/` | Core visibility tracking. Types: AWARENESS/INTEREST/PURCHASE/LOYALTY. Lifecycle: suggest→track→delete→restore. |
| `content/` | Content generation + management. Triggers N8N webhooks, streams progress via SSE. Blog + social media. |
| `public-blog/` | **No auth.** Serves published articles at `/api/public/:brandSlug/articles`. Powers hosted blog feature. |
| `processors/` | BullMQ workers: `ProjectAnalysis`, `ContentGeneration`, `CreateProject`. Each runs as separate process. |
| `scheduler/` | Cron jobs: daily content auto-gen (4 AM), stale draft cleanup (2 AM), monthly analysis (15th, 3 AM). Asia/Ho_Chi_Minh TZ. |
| `n8n/` | Calls N8N webhook for content generation/rewriting. Sends payload with callbackUrl for progress updates. |
| `agent/` | HTTP client to Python agent server. Google ID token auth. |
| `sse/` | Server-Sent Events. Channels keyed by jobId for real-time content generation progress. |

### Request Flow

```
Frontend (port 3000) → Next.js API Route (BFF proxy, adds Bearer token)
  → NestJS Backend (port 3001) → Controller → Service → Repository → Supabase
```

### Async Job Flow

```
Controller → task-enqueue service → BullMQ queue → processors/ worker → task table
                                                         ↓
                                                   SSE channel → frontend
```

## Conventions

### Database Access

- **All queries** via `supabase-js` in `*.repository.ts` — never in services or controllers
- Supabase returns `{ data, error }` — **always check `error`** before using `data`
- Types generated from schema: `src/supabase/supabase.types.ts` (run `pnpm gen:types` after schema changes)
- Migrations: raw SQL in `supabase/migrations/` — no ORM, no TypeORM, no Prisma
- All tables: UUID primary keys, auto-managed `createdAt`/`updatedAt` via triggers

### Auth

- Global `JwtAuthGuard` on ALL routes by default
- Public endpoints: `@Public()` decorator
- Project-scoped routes: `ProjectMembershipGuard`
- Google OAuth: PKCE flow

### DTOs

```typescript
// Use class-validator decorators
export class CreateTopicDto {
  @IsString() @IsNotEmpty() name: string;
  @IsUUID() projectId: string;
  @IsOptional() @IsString() description?: string;
}
```

### Error Handling

- Use NestJS built-in exceptions (`NotFoundException`, `BadRequestException`, etc.)
- Don't swallow errors — always throw or handle explicitly
- Supabase errors: check `error` field, throw appropriate NestJS exception

### Code Style

- Prettier: trailing commas, single quotes
- Comment sparingly — only on complex logic
- Never modify/remove existing human comments unless directly related to your task

### General Principles

- Prioritize simple solutions over complex ones
- Avoid unnecessary backend calls or N+1 queries
- Keep services thin — orchestration only, delegate to repositories for data access

## Gotchas

- `supabase-js` returns `{ data, error }` not exceptions — forgetting to check `error` causes **silent failures**
- Don't create ORM-style migrations — use raw SQL only
- Scheduler cron jobs use `Asia/Ho_Chi_Minh` timezone, not UTC
- BullMQ workers must update task status to FAILED on errors — don't let jobs silently die
- N8N callbacks: if content stays in DRAFTING, the callback URL likely failed — check N8N execution logs
- `gen:types` must be re-run after any schema change or migration
- Workers run as separate processes — they have their own entry point (`worker.ts`), not `main.ts`

## Key Enums

- **Project.status:** DRAFT, ACTIVE, ARCHIVED
- **Prompt.type:** AWARENESS, INTEREST, PURCHASE, LOYALTY
- **Response.sentiment:** Negative, Neutral, Positive
- **Content.completionStatus:** DRAFTING, COMPLETE, PUBLISHED, FAILED
- **Content.contentType:** blog_post, social_media_post, email, copywriting
- **Content.platform:** facebook, zalo, linkedin (nullable)
- **Task.status:** PENDING, IN_PROGRESS, COMPLETED, FAILED
