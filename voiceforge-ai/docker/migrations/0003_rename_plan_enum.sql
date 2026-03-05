-- ═══════════════════════════════════════════════════════════════════
-- Migration: Rename plan enum values
-- starter → basic, business → enterprise
-- ═══════════════════════════════════════════════════════════════════

-- Step 1: Rename existing enum values
ALTER TYPE plan RENAME VALUE 'starter' TO 'basic';
ALTER TYPE plan RENAME VALUE 'business' TO 'enterprise';

-- Step 2: Update pending_registrations text column (not enum — plain text)
UPDATE pending_registrations SET plan = 'basic' WHERE plan = 'starter';
UPDATE pending_registrations SET plan = 'pro' WHERE plan = 'professional';
UPDATE pending_registrations SET plan = 'enterprise' WHERE plan = 'business';

-- Step 3: Update license_keys text column
UPDATE license_keys SET plan = 'basic' WHERE plan = 'starter';
UPDATE license_keys SET plan = 'pro' WHERE plan = 'professional';
UPDATE license_keys SET plan = 'enterprise' WHERE plan = 'business';
