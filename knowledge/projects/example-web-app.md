# Example Web App

> This is an example project file. Copy this structure for your own projects.
> Delete this file once you have real projects.

## Context
- **What**: A Next.js web application with a PostgreSQL backend
- **Repo**: `github.com/yourname/example-web-app`
- **Stack**: Next.js 14, TypeScript, Prisma, PostgreSQL, Tailwind CSS

## Active Workstreams

| Branch | Status | Description |
|---|---|---|
| main | stable | Production branch |
| feat/user-dashboard | in-progress | New user dashboard with analytics widgets |

## Key Paths
- `src/app/` — Next.js app router pages
- `src/components/` — Shared React components
- `prisma/schema.prisma` — Database schema
- `src/lib/api/` — API route handlers
- `tests/` — Jest + React Testing Library tests

## Build & Test
```bash
npm run dev          # Local dev server (port 3000)
npm run build        # Production build
npm test             # Run all tests
npm test -- --watch  # Watch mode
npx prisma migrate dev  # Apply DB migrations
npx prisma studio    # Visual DB browser
```

## Known Issues
- Hot reload sometimes fails for Prisma schema changes — restart dev server
- `npm test` requires PostgreSQL running locally (or use `docker compose up db`)

## Architecture Notes
- API routes use middleware chain: auth -> validate -> handler -> serialize
- All DB queries go through Prisma — no raw SQL except in migrations
- Feature flags stored in `src/config/features.ts`, not environment variables
