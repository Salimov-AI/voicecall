-- ═══════════════════════════════════════════════════════════════════
-- Migration: Rename plan enum values
-- starter → basic, business → enterprise
-- Idempotent: safe to run on both fresh and existing databases
-- ═══════════════════════════════════════════════════════════════════

-- Step 1: Rename existing enum values (only if old values exist)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'starter' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'plan')) THEN
    ALTER TYPE plan RENAME VALUE 'starter' TO 'basic';
  END IF;
  IF EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'business' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'plan')) THEN
    ALTER TYPE plan RENAME VALUE 'business' TO 'enterprise';
  END IF;
END $$;

-- Step 2: Update pending_registrations text column (not enum — plain text)
UPDATE pending_registrations SET plan = 'basic' WHERE plan = 'starter';
UPDATE pending_registrations SET plan = 'pro' WHERE plan = 'professional';
UPDATE pending_registrations SET plan = 'enterprise' WHERE plan = 'business';

-- Step 3: Update license_keys text column
UPDATE license_keys SET plan = 'basic' WHERE plan = 'starter';
UPDATE license_keys SET plan = 'pro' WHERE plan = 'professional';
UPDATE license_keys SET plan = 'enterprise' WHERE plan = 'business';
