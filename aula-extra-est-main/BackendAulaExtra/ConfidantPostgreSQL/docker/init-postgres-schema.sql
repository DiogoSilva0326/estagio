-- Confidant Postgres bootstrap
-- This file is executed by postgres docker-entrypoint-initdb.d when the DB is first created.

-- Common extensions (safe no-ops if unavailable)
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Namespace for AulaExtra platform schema to avoid conflicts with Confidant's public.* tables
CREATE SCHEMA IF NOT EXISTS aula_extra;

-- Default search_path (Confidant tables live in public.*; Aula Extra script sets its own search_path)
SET search_path TO public;
