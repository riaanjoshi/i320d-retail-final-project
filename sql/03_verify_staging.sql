-- =====================================================================
-- 03_verify_staging.sql
-- I320D Data Engineering - Retail Final Project
-- Profiles the loaded staging tables so that data quality is MEASURED
-- before any modeling decisions are made. Every query below is
-- read-only. Paste the outputs into Section 3 of the final report as
-- evidence, and carry anything surprising into Section 7 (Reflection).
--
-- Run with:
--   psql -h <HOST> -U <YOUR_ROLE> -d <DATABASE> -f sql/03_verify_staging.sql
-- =====================================================================

\echo ''
\echo '############ 1. ROW COUNTS ############'

SELECT 'customers'          AS table_name, COUNT(*) AS rows FROM staging.customers
UNION ALL SELECT 'stores',              COUNT(*) FROM staging.stores
UNION ALL SELECT 'suppliers',           COUNT(*) FROM staging.suppliers
UNION ALL SELECT 'product_categories',  COUNT(*) FROM staging.product_categories
UNION ALL SELECT 'payment_methods',     COUNT(*) FROM staging.payment_methods
UNION ALL SELECT 'products',            COUNT(*) FROM staging.products
UNION ALL SELECT 'orders',              COUNT(*) FROM staging.orders
UNION ALL SELECT 'order_lines',         COUNT(*) FROM staging.order_lines
UNION ALL SELECT 'inventory_snapshot',  COUNT(*) FROM staging.inventory_snapshot
ORDER BY table_name;


\echo ''
\echo '############ 2. SAMPLE ROWS (for the report) ############'

SELECT * FROM staging.customers   LIMIT 5;
SELECT * FROM staging.orders      LIMIT 5;
SELECT * FROM staging.order_lines LIMIT 5;
SELECT * FROM staging.products    LIMIT 5;


\echo ''
\echo '############ 3. PRIMARY KEY UNIQUENESS ############'
\echo 'Each query should return ZERO rows. Any output is a duplicate key.'

SELECT 'customers.customer_id' AS key_checked, customer_id AS value, COUNT(*) AS copies
FROM staging.customers GROUP BY customer_id HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;

SELECT 'orders.order_id' AS key_checked, order_id AS value, COUNT(*) AS copies
FROM staging.orders GROUP BY order_id HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;

SELECT 'order_lines.order_line_id' AS key_checked, order_line_id AS value, COUNT(*) AS copies
FROM staging.order_lines GROUP BY order_line_id HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;

SELECT 'products.product_id' AS key_checked, product_id AS value, COUNT(*) AS copies
FROM staging.products GROUP BY product_id HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;

SELECT 'products.sku' AS key_checked, sku AS value, COUNT(*) AS copies
FROM staging.products GROUP BY sku HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;

SELECT 'inventory_snapshot (store,product,date)' AS key_checked,
       store_id || '|' || product_id || '|' || snapshot_date AS value, COUNT(*) AS copies
FROM staging.inventory_snapshot
GROUP BY 2 HAVING COUNT(*) > 1 ORDER BY copies DESC LIMIT 20;


\echo ''
\echo '############ 4. NULL / BLANK PROFILING ############'

SELECT 'customers' AS tbl, COUNT(*) AS rows,
       COUNT(*) FILTER (WHERE customer_id  IS NULL) AS null_customer_id,
       COUNT(*) FILTER (WHERE email        IS NULL) AS null_email,
       COUNT(*) FILTER (WHERE state        IS NULL) AS null_state,
       COUNT(*) FILTER (WHERE loyalty_tier IS NULL) AS null_loyalty_tier,
       COUNT(*) FILTER (WHERE signup_date  IS NULL) AS null_signup_date
FROM staging.customers;

SELECT 'orders' AS tbl, COUNT(*) AS rows,
       COUNT(*) FILTER (WHERE order_id          IS NULL) AS null_order_id,
       COUNT(*) FILTER (WHERE customer_id       IS NULL) AS null_customer_id,
       COUNT(*) FILTER (WHERE store_id          IS NULL) AS null_store_id,
       COUNT(*) FILTER (WHERE order_date        IS NULL) AS null_order_date,
       COUNT(*) FILTER (WHERE payment_method_id IS NULL) AS null_payment_method
FROM staging.orders;

SELECT 'order_lines' AS tbl, COUNT(*) AS rows,
       COUNT(*) FILTER (WHERE order_id     IS NULL) AS null_order_id,
       COUNT(*) FILTER (WHERE product_id   IS NULL) AS null_product_id,
       COUNT(*) FILTER (WHERE quantity     IS NULL) AS null_quantity,
       COUNT(*) FILTER (WHERE unit_price   IS NULL) AS null_unit_price,
       COUNT(*) FILTER (WHERE discount_pct IS NULL) AS null_discount_pct
FROM staging.order_lines;

SELECT 'products' AS tbl, COUNT(*) AS rows,
       COUNT(*) FILTER (WHERE category_id IS NULL) AS null_category_id,
       COUNT(*) FILTER (WHERE supplier_id IS NULL) AS null_supplier_id,
       COUNT(*) FILTER (WHERE list_price  IS NULL) AS null_list_price,
       COUNT(*) FILTER (WHERE unit_cost   IS NULL) AS null_unit_cost
FROM staging.products;


\echo ''
\echo '############ 5. TYPE-CONVERSION SAFETY ############'
\echo 'Values that will NOT cast cleanly downstream. Expect zero rows.'

SELECT 'orders.order_date' AS column_checked, order_date AS bad_value, COUNT(*) AS n
FROM staging.orders
WHERE order_date IS NOT NULL AND order_date !~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY order_date ORDER BY n DESC LIMIT 20;

SELECT 'customers.signup_date' AS column_checked, signup_date AS bad_value, COUNT(*) AS n
FROM staging.customers
WHERE signup_date IS NOT NULL AND signup_date !~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY signup_date ORDER BY n DESC LIMIT 20;

SELECT 'inventory_snapshot.snapshot_date' AS column_checked, snapshot_date AS bad_value, COUNT(*) AS n
FROM staging.inventory_snapshot
WHERE snapshot_date IS NOT NULL AND snapshot_date !~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY snapshot_date ORDER BY n DESC LIMIT 20;

SELECT 'order_lines.quantity' AS column_checked, quantity AS bad_value, COUNT(*) AS n
FROM staging.order_lines
WHERE quantity IS NOT NULL AND quantity !~ '^-?\d+$'
GROUP BY quantity ORDER BY n DESC LIMIT 20;

SELECT 'order_lines.unit_price' AS column_checked, unit_price AS bad_value, COUNT(*) AS n
FROM staging.order_lines
WHERE unit_price IS NOT NULL AND unit_price !~ '^-?\d+(\.\d+)?$'
GROUP BY unit_price ORDER BY n DESC LIMIT 20;

SELECT 'order_lines.discount_pct' AS column_checked, discount_pct AS bad_value, COUNT(*) AS n
FROM staging.order_lines
WHERE discount_pct IS NOT NULL AND discount_pct !~ '^-?\d+(\.\d+)?$'
GROUP BY discount_pct ORDER BY n DESC LIMIT 20;

SELECT 'products.list_price' AS column_checked, list_price AS bad_value, COUNT(*) AS n
FROM staging.products
WHERE list_price IS NOT NULL AND list_price !~ '^-?\d+(\.\d+)?$'
GROUP BY list_price ORDER BY n DESC LIMIT 20;


\echo ''
\echo '############ 6. REFERENTIAL INTEGRITY (orphan checks) ############'
\echo 'Each query should return ZERO rows.'

\echo '-- order_lines with no matching order'
SELECT COUNT(*) AS orphan_order_lines
FROM staging.order_lines ol
LEFT JOIN staging.orders o USING (order_id)
WHERE o.order_id IS NULL;

\echo '-- order_lines pointing at a product that does not exist'
SELECT COUNT(*) AS orphan_product_refs
FROM staging.order_lines ol
LEFT JOIN staging.products p USING (product_id)
WHERE p.product_id IS NULL;

\echo '-- orders pointing at a customer that does not exist'
SELECT COUNT(*) AS orphan_customer_refs
FROM staging.orders o
LEFT JOIN staging.customers c USING (customer_id)
WHERE c.customer_id IS NULL;

\echo '-- orders pointing at a store that does not exist'
SELECT COUNT(*) AS orphan_store_refs
FROM staging.orders o
LEFT JOIN staging.stores s USING (store_id)
WHERE s.store_id IS NULL;

\echo '-- orders pointing at a payment method that does not exist'
SELECT COUNT(*) AS orphan_payment_refs
FROM staging.orders o
LEFT JOIN staging.payment_methods pm USING (payment_method_id)
WHERE pm.payment_method_id IS NULL;

\echo '-- products pointing at a category that does not exist'
SELECT COUNT(*) AS orphan_category_refs
FROM staging.products p
LEFT JOIN staging.product_categories pc USING (category_id)
WHERE pc.category_id IS NULL;

\echo '-- products pointing at a supplier that does not exist'
SELECT COUNT(*) AS orphan_supplier_refs
FROM staging.products p
LEFT JOIN staging.suppliers s USING (supplier_id)
WHERE s.supplier_id IS NULL;

\echo '-- orders with no line items (possible but worth knowing)'
SELECT COUNT(*) AS orders_without_lines
FROM staging.orders o
LEFT JOIN staging.order_lines ol USING (order_id)
WHERE ol.order_id IS NULL;


\echo ''
\echo '############ 7. CATEGORICAL VALUE PROFILING ############'
\echo 'Look for inconsistent casing, stray whitespace, unexpected labels.'

SELECT 'customers.loyalty_tier' AS column_checked, loyalty_tier AS value, COUNT(*) AS n
FROM staging.customers GROUP BY loyalty_tier ORDER BY n DESC;

SELECT 'customers.email_opt_in' AS column_checked, email_opt_in AS value, COUNT(*) AS n
FROM staging.customers GROUP BY email_opt_in ORDER BY n DESC;

SELECT 'orders.order_channel' AS column_checked, order_channel AS value, COUNT(*) AS n
FROM staging.orders GROUP BY order_channel ORDER BY n DESC;

SELECT 'order_lines.line_status' AS column_checked, line_status AS value, COUNT(*) AS n
FROM staging.order_lines GROUP BY line_status ORDER BY n DESC;

SELECT 'products.product_status' AS column_checked, product_status AS value, COUNT(*) AS n
FROM staging.products GROUP BY product_status ORDER BY n DESC;

SELECT 'stores.region' AS column_checked, region AS value, COUNT(*) AS n
FROM staging.stores GROUP BY region ORDER BY n DESC;

SELECT 'payment_methods' AS column_checked, payment_method_name AS value, is_electronic AS flag
FROM staging.payment_methods ORDER BY payment_method_id;


\echo ''
\echo '############ 8. RANGE / PLAUSIBILITY CHECKS ############'

\echo '-- date coverage'
SELECT MIN(order_date) AS first_order, MAX(order_date) AS last_order FROM staging.orders;
SELECT MIN(snapshot_date) AS first_snapshot, MAX(snapshot_date) AS last_snapshot FROM staging.inventory_snapshot;

\echo '-- negative or zero quantities (returns? data error?)'
SELECT line_status, COUNT(*) AS n
FROM staging.order_lines
WHERE quantity ~ '^-?\d+$' AND quantity::int <= 0
GROUP BY line_status ORDER BY n DESC;

\echo '-- discount percentages outside 0-1 and outside 0-100'
SELECT MIN(discount_pct::numeric) AS min_discount,
       MAX(discount_pct::numeric) AS max_discount
FROM staging.order_lines
WHERE discount_pct ~ '^-?\d+(\.\d+)?$';

\echo '-- products priced below cost (margin sanity)'
SELECT COUNT(*) AS products_priced_below_cost
FROM staging.products
WHERE list_price ~ '^-?\d+(\.\d+)?$' AND unit_cost ~ '^-?\d+(\.\d+)?$'
  AND list_price::numeric < unit_cost::numeric;

\echo ''
\echo '=== Verification complete. Record every non-zero result. ==='
