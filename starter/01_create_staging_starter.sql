-- ============================================================================
-- STARTER SNIPPET 1 of 4 : staging DDL  (Retail - Dinosaurs)
-- Run from the project folder:
--   psql -h <HOST> -U <YOUR_ROLE> -d dataeng -f starter/01_create_staging_starter.sql
-- This creates ONE example table so you can see the pattern. YOU must write the
-- DDL for every other CSV in /data, choosing sensible data types.
-- If your instructor gave you your own schema (e.g. student_jdoe), replace
-- 'staging' below with that schema name.
-- Never put passwords in this file.
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.customers;
CREATE TABLE staging.customers (
    customer_id  VARCHAR(20),
    first_name   VARCHAR(100),
    last_name    VARCHAR(100),
    email        VARCHAR(100),
    state        VARCHAR(100),
    loyalty_tier VARCHAR(100),
    signup_date  DATE,
    email_opt_in VARCHAR(100)
);

-- Staging tables mirror the CSV exactly. We deliberately do NOT add PRIMARY KEY
-- or NOT NULL here: a staging table must accept whatever the source sends so you
-- can measure its quality afterwards (see 03_verify_starter.sql).

-- TODO: one CREATE TABLE per remaining CSV file (look at each header + data first!)
