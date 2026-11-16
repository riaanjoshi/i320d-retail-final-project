-- =====================================================================
-- 01_create_staging.sql
-- I320D Data Engineering - Retail Final Project
-- Creates the staging schema and one table per supplied CSV file.
--
-- Run with:
--   psql -h <HOST> -U <YOUR_ROLE> -d <DATABASE> -f sql/01_create_staging.sql
--
-- DESIGN NOTE (important, and worth repeating in the report):
-- Staging tables mirror each CSV *exactly* - same column names, same
-- column order - and every column is declared VARCHAR. No PRIMARY KEY,
-- no NOT NULL, no CHECK constraints. This is deliberate: a staging
-- table must accept whatever the source actually sends, so that data
-- quality can be MEASURED (see 03_verify_staging.sql) rather than
-- causing the load itself to fail. Type casting, trimming, null
-- handling and key enforcement all happen downstream in the dbt
-- staging models.
--
-- This script is re-runnable: DROP TABLE IF EXISTS precedes each
-- CREATE TABLE, so you can reload from scratch at any time.
-- Never put passwords in this file.
-- =====================================================================

CREATE SCHEMA IF NOT EXISTS staging;


-- ---------------------------------------------------------------------
-- customers.csv        (~3,010 data rows)
-- One row per retail customer account.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.customers;
CREATE TABLE staging.customers (
    customer_id   VARCHAR(50),
    first_name    VARCHAR(200),
    last_name     VARCHAR(200),
    email         VARCHAR(320),
    state         VARCHAR(100),
    loyalty_tier  VARCHAR(100),
    signup_date   VARCHAR(50),
    email_opt_in  VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- stores.csv           (~10 data rows)
-- One row per physical store location.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.stores;
CREATE TABLE staging.stores (
    store_id      VARCHAR(50),
    store_name    VARCHAR(200),
    city          VARCHAR(200),
    state         VARCHAR(100),
    region        VARCHAR(100),
    square_feet   VARCHAR(50),
    open_date     VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- suppliers.csv        (~25 data rows)
-- One row per product supplier.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.suppliers;
CREATE TABLE staging.suppliers (
    supplier_id       VARCHAR(50),
    supplier_name     VARCHAR(200),
    supplier_country  VARCHAR(100),
    lead_time_days    VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- product_categories.csv   (~14 data rows)
-- One row per merchandise category, rolling up to a department.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.product_categories;
CREATE TABLE staging.product_categories (
    category_id      VARCHAR(50),
    department_name  VARCHAR(200),
    category_name    VARCHAR(200)
);


-- ---------------------------------------------------------------------
-- payment_methods.csv  (~6 data rows)
-- One row per tender type accepted at checkout.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.payment_methods;
CREATE TABLE staging.payment_methods (
    payment_method_id    VARCHAR(50),
    payment_method_name  VARCHAR(200),
    is_electronic        VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- products.csv         (~380 data rows)
-- One row per sellable product (SKU).
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.products;
CREATE TABLE staging.products (
    product_id      VARCHAR(50),
    sku             VARCHAR(100),
    category_id     VARCHAR(50),
    product_name    VARCHAR(300),
    brand           VARCHAR(200),
    supplier_id     VARCHAR(50),
    list_price      VARCHAR(50),
    unit_cost       VARCHAR(50),
    launch_date     VARCHAR(50),
    product_status  VARCHAR(100)
);


-- ---------------------------------------------------------------------
-- orders.csv           (~14,000 data rows)
-- One row per customer order header.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.orders;
CREATE TABLE staging.orders (
    order_id           VARCHAR(50),
    customer_id        VARCHAR(50),
    store_id           VARCHAR(50),
    order_date         VARCHAR(50),
    order_channel      VARCHAR(100),
    payment_method_id  VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- order_lines.csv      (~31,459 data rows)
-- One row per line item on an order. This is the transaction grain
-- and the expected source of the primary fact table.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.order_lines;
CREATE TABLE staging.order_lines (
    order_line_id  VARCHAR(50),
    order_id       VARCHAR(50),
    product_id     VARCHAR(50),
    quantity       VARCHAR(50),
    unit_price     VARCHAR(50),
    discount_pct   VARCHAR(50),
    line_status    VARCHAR(100)
);


-- ---------------------------------------------------------------------
-- inventory_snapshot.csv   (~3,800 data rows)
-- One row per product per store per snapshot date.
-- A periodic snapshot fact source - do NOT union it with sales.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS staging.inventory_snapshot;
CREATE TABLE staging.inventory_snapshot (
    inventory_id        VARCHAR(50),
    store_id            VARCHAR(50),
    product_id          VARCHAR(50),
    units_on_hand       VARCHAR(50),
    reorder_point       VARCHAR(50),
    last_received_date  VARCHAR(50),
    snapshot_date       VARCHAR(50)
);


-- ---------------------------------------------------------------------
-- Confirm all nine tables exist.
-- ---------------------------------------------------------------------
\echo '--- staging tables created ---'
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'staging'
ORDER BY table_name;
