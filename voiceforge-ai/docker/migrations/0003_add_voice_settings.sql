-- Migration: Add voice_stability, voice_similarity columns and fix voice_speed type
-- These support fine-tuning ElevenLabs TTS voice settings per agent

-- Change voice_speed from integer to real for fractional values (0.7-1.3)
ALTER TABLE agents ALTER COLUMN voice_speed TYPE REAL USING voice_speed::REAL;
ALTER TABLE agents ALTER COLUMN voice_speed SET DEFAULT 0.95;

-- Add new voice tuning columns
ALTER TABLE agents
  ADD COLUMN IF NOT EXISTS voice_stability REAL NOT NULL DEFAULT 0.6,
  ADD COLUMN IF NOT EXISTS voice_similarity REAL NOT NULL DEFAULT 0.8;

-- Update default TTS model from eleven_flash_v2_5 to eleven_v3_conversational for existing agents
UPDATE agents SET model = 'eleven_v3_conversational' WHERE model = 'eleven_flash_v2_5';

-- Set sensible defaults for existing agents
UPDATE agents SET voice_speed = 0.95 WHERE voice_speed = 1;
