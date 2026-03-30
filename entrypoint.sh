#!/bin/sh
# =============================================================================
# entrypoint.sh — Backend Container Startup Script
# =============================================================================
# Runs BEFORE the main NestJS application starts.
# Handles database migrations so the schema is always current on deploy.
#
# Why not put migrations in the Dockerfile?
# → DATABASE_URL is only available at RUNTIME (injected by App Runner),
#   not at build time. So migrations must run when the container starts.
#
# Why is this safe to run on every container start?
# → `prisma migrate deploy` is idempotent: if migrations are already applied,
#   it does nothing. It never rolls back or destroys data.
# =============================================================================

set -e  # Stop immediately if any command fails

echo "========================================"
echo "  Linker Backend — Starting Up"
echo "========================================"
echo "  Environment : ${NODE_ENV:-development}"
echo "  Port        : ${PORT:-3001}"
echo "========================================"

# ── Validate required environment variables ──────────────────────────────────
if [ -z "$DATABASE_URL" ]; then
  echo ""
  echo "❌ FATAL: DATABASE_URL is not set!"
  echo "   For local dev: check your .env file"
  echo "   For App Runner: check Secrets Manager + service configuration"
  echo ""
  exit 1
fi

# ── Run Prisma migrations ─────────────────────────────────────────────────────
echo ""
echo "📦 Running database migrations..."
npx prisma migrate deploy

if [ $? -eq 0 ]; then
  echo "✅ Migrations completed successfully"
else
  echo "❌ Migration failed — check DATABASE_URL and database connectivity"
  exit 1
fi

# ── Start the NestJS server ───────────────────────────────────────────────────
echo ""
echo "🚀 Starting NestJS on port ${PORT:-3001}..."
echo ""

exec node dist/main.js
