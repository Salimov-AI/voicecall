# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

VoiceForge AI — White-label AI Voice Receptionist SaaS for Greek SMEs. All code lives under `voiceforge-ai/`.

## Commands

All commands run from `voiceforge-ai/` directory:

```bash
pnpm install                # Install all dependencies
pnpm dev                    # API server only (port 3001)
pnpm dev:web                # Next.js frontend only (port 3000)
pnpm dev:all                # Both API + Web in parallel
pnpm build                  # Build all packages
pnpm typecheck              # TypeScript checking across all packages
pnpm lint                   # Lint all packages
pnpm db:push                # Push Drizzle schema to PostgreSQL
pnpm db:studio              # Open Drizzle Studio (DB browser)
```

Single-package commands:
```bash
pnpm --filter @voiceforge/api typecheck
pnpm --filter @voiceforge/web lint
```

Database requires Docker: `docker compose up -d postgres`

## Architecture

**pnpm workspace monorepo** (no Turborepo) with three packages:

- **`apps/api`** (`@voiceforge/api`) — Hono.js REST API on port 3001. Uses `@hono/node-server`, Drizzle ORM with PostgreSQL, Zod validation. Entry: `src/index.ts`, built with `tsup`.
- **`apps/web`** (`@voiceforge/web`) — Next.js 15 (App Router) + React 19 + Tailwind CSS 4. State via Zustand. i18n: Greek (primary) + English via custom provider in `src/lib/i18n/`.
- **`packages/shared`** (`@voiceforge/shared`) — Shared TypeScript types, constants, and templates. Referenced as `workspace:*`.

## Key Patterns

- **API routes**: Each file in `apps/api/src/routes/` exports a Hono router. Routes are mounted in `src/index.ts`.
- **DB schema**: Drizzle schema files in `apps/api/src/db/schema/`, re-exported from `schema/index.ts`. 12 tables.
- **Services**: `apps/api/src/services/` wraps external APIs (ElevenLabs, Telnyx, Stripe, Resend).
- **Auth**: Dual mode — Supabase (production) or JWT dev auth (`NEXT_PUBLIC_DEV_AUTH=true`). Dev auth routes in `routes/dev-auth.ts`, frontend logic in `web/src/lib/dev-auth.ts`.
- **Middleware**: Auth extraction in `middleware/auth.ts`, rate limiting in `middleware/rate-limit.ts`, Telnyx Ed25519 webhook verification in `middleware/webhook-verify.ts`.
- **Frontend pages**: Next.js App Router groups: `(auth)/` for login/register, `(dashboard)/` for main app, `admin/` for admin panel.
- **API client**: `web/src/lib/api-client.ts` — centralized fetch wrapper for calling the API from the frontend.
- **Encryption**: AES-256-GCM for stored API keys via `services/encryption.ts`.

## External Services

Telnyx (telephony), ElevenLabs (AI voice), Stripe (billing), Resend (email), OpenAI (support chatbot). All keys configured via `.env`. Features degrade gracefully without keys.

## Environment

- Node.js 20+, pnpm 9+
- PostgreSQL 16 via Docker (`docker-compose.yml`)
- Dev auth enabled by default (`NEXT_PUBLIC_DEV_AUTH=true`)
- SQL migrations in `docker/migrations/`, applied manually via `docker exec`