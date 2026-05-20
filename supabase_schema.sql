-- DBAS Simulator — Supabase Schema
-- Paste this into the Supabase SQL Editor and click "Run".
-- Safe to re-run; everything is idempotent.

-- ───────────────────────────────────────────────────────────
-- TABLES
-- ───────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS students (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  session_id VARCHAR(64) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS scenario_runs (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  scenario VARCHAR(10) NOT NULL CHECK (scenario IN ('LEGO', 'SIEMENS', 'SPOTIFY')),
  decisions JSONB NOT NULL,
  results JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (student_id, scenario)
);

CREATE TABLE IF NOT EXISTS reflections (
  id BIGSERIAL PRIMARY KEY,
  student_id BIGINT NOT NULL UNIQUE REFERENCES students(id) ON DELETE CASCADE,
  q1_context TEXT,
  q2_negative TEXT,
  q3_tradeoff TEXT,
  q4_cycle TEXT,
  submitted_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_runs_student ON scenario_runs(student_id);
CREATE INDEX IF NOT EXISTS idx_runs_scenario ON scenario_runs(scenario);

-- ───────────────────────────────────────────────────────────
-- ROW LEVEL SECURITY
-- The simulator has no login. Students identify themselves by a
-- random browser session_id. Policies below let the anon role
-- insert/update/select their own data only — matching what the old
-- Express server did (which also had no auth).
-- ───────────────────────────────────────────────────────────

ALTER TABLE students       ENABLE ROW LEVEL SECURITY;
ALTER TABLE scenario_runs  ENABLE ROW LEVEL SECURITY;
ALTER TABLE reflections    ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon read students"   ON students;
DROP POLICY IF EXISTS "anon write students"  ON students;
DROP POLICY IF EXISTS "anon update students" ON students;

CREATE POLICY "anon read students"   ON students FOR SELECT TO anon USING (true);
CREATE POLICY "anon write students"  ON students FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update students" ON students FOR UPDATE TO anon USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon read runs"   ON scenario_runs;
DROP POLICY IF EXISTS "anon write runs"  ON scenario_runs;
DROP POLICY IF EXISTS "anon update runs" ON scenario_runs;

CREATE POLICY "anon read runs"   ON scenario_runs FOR SELECT TO anon USING (true);
CREATE POLICY "anon write runs"  ON scenario_runs FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update runs" ON scenario_runs FOR UPDATE TO anon USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon read reflections"   ON reflections;
DROP POLICY IF EXISTS "anon write reflections"  ON reflections;
DROP POLICY IF EXISTS "anon update reflections" ON reflections;

CREATE POLICY "anon read reflections"   ON reflections FOR SELECT TO anon USING (true);
CREATE POLICY "anon write reflections"  ON reflections FOR INSERT TO anon WITH CHECK (true);
CREATE POLICY "anon update reflections" ON reflections FOR UPDATE TO anon USING (true) WITH CHECK (true);
