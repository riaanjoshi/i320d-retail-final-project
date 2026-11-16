# Data dictionary — Retail source files

Nine CSV files, ~52,700 data rows. All files have a header row. Column order
below matches the file exactly and matches `sql/01_create_staging.sql`.

Types listed are the **intended** types after casting in the `stg_*` models.
Every column lands in staging as `VARCHAR` — see the design note in the DDL.

---

## `customers.csv` — 3,010 rows
**Grain:** one row per customer account.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `customer_id` | text (PK) | Business key for the customer | `CUS-000001` |
| `first_name` | text | Given name | `Owen` |
| `last_name` | text | Family name | `Thompson` |
| `email` | text | Email address — **mask in the report** | `owen.thompson1@example.com` |
| `state` | text | Two-letter US state code | `OH` |
| `loyalty_tier` | text | Loyalty program tier | `Basic` |
| `signup_date` | date | Account creation date | `2020-03-30` |
| `email_opt_in` | boolean | Marketing consent flag | `Y` |

---

## `stores.csv` — 10 rows
**Grain:** one row per physical store.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `store_id` | text (PK) | Business key for the store | `STR-01` |
| `store_name` | text | Store name | `Easton Town Center` |
| `city` | text | City | `Columbus` |
| `state` | text | Two-letter state code | `OH` |
| `region` | text | Region rollup | `Central` |
| `square_feet` | integer | Selling floor area | `42000` |
| `open_date` | date | Date the store opened | `2018-07-11` |

---

## `suppliers.csv` — 25 rows
**Grain:** one row per supplier.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `supplier_id` | text (PK) | Business key for the supplier | `SUP-001` |
| `supplier_name` | text | Supplier name | `Eastbrook Wholesale` |
| `supplier_country` | text | Country of origin | `Vietnam` |
| `lead_time_days` | integer | Quoted replenishment lead time | `25` |

---

## `product_categories.csv` — 14 rows
**Grain:** one row per category. Categories roll up to departments.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `category_id` | text (PK) | Business key for the category | `CAT-01` |
| `department_name` | text | Parent department | `Apparel` |
| `category_name` | text | Category label | `Men's Tops` |

---

## `payment_methods.csv` — 6 rows
**Grain:** one row per tender type.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `payment_method_id` | text (PK) | Business key for the method | `PAY-01` |
| `payment_method_name` | text | Display name | `Credit Card` |
| `is_electronic` | boolean | Electronic tender flag | `Y` |

---

## `products.csv` — 380 rows
**Grain:** one row per sellable product (SKU).

| Column | Intended type | Description | Example |
|---|---|---|---|
| `product_id` | text (PK) | Business key for the product | `PRD-1001` |
| `sku` | text | Stock keeping unit code | `SKU-100211` |
| `category_id` | text (FK) | → `product_categories.category_id` | `CAT-01` |
| `product_name` | text | Product name | `Alpine Flannel Shirt` |
| `brand` | text | Brand | `Juniper Lane` |
| `supplier_id` | text (FK) | → `suppliers.supplier_id` | `SUP-001` |
| `list_price` | numeric(10,2) | Current list price | `34.24` |
| `unit_cost` | numeric(10,2) | Unit cost of goods | `21.27` |
| `launch_date` | date | Date the product launched | `2019-02-22` |
| `product_status` | text | Lifecycle status | `Active` |

---

## `orders.csv` — 14,000 rows
**Grain:** one row per order header.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `order_id` | text (PK) | Business key for the order | `ORD-000001` |
| `customer_id` | text (FK) | → `customers.customer_id` | `CUS-001814` |
| `store_id` | text (FK) | → `stores.store_id` | `STR-04` |
| `order_date` | date | Date the order was placed | `2025-01-01` |
| `order_channel` | text | Sales channel | `In-Store` |
| `payment_method_id` | text (FK) | → `payment_methods.payment_method_id` | `PAY-01` |

---

## `order_lines.csv` — 31,459 rows
**Grain:** one row per line item on an order. **This is the transaction grain**
and the expected source of the primary sales fact table.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `order_line_id` | text (PK) | Business key for the line | `OLN-0000001` |
| `order_id` | text (FK) | → `orders.order_id` | `ORD-000001` |
| `product_id` | text (FK) | → `products.product_id` | `PRD-1246` |
| `quantity` | integer | Units on this line | `3` |
| `unit_price` | numeric(10,2) | Price charged per unit | `73.49` |
| `discount_pct` | numeric | Discount on this line — **confirm 0–1 vs 0–100** | `0` |
| `line_status` | text | Line outcome | `Returned` |

> **Watch:** `line_status` includes returns. Decide explicitly whether returned
> lines are excluded, counted negatively, or reported separately — and apply
> that rule consistently so revenue is not overstated.

---

## `inventory_snapshot.csv` — 3,800 rows
**Grain:** one row per product per store per snapshot date. This is a
**periodic snapshot** fact source; its measures are semi-additive (they can be
averaged across dates but not summed across them), so it must not be unioned
with the sales fact.

| Column | Intended type | Description | Example |
|---|---|---|---|
| `inventory_id` | text (PK) | Business key for the snapshot row | `INV-00001` |
| `store_id` | text (FK) | → `stores.store_id` | `STR-01` |
| `product_id` | text (FK) | → `products.product_id` | `PRD-1001` |
| `units_on_hand` | integer | Units available at snapshot time | `23` |
| `reorder_point` | integer | Replenishment trigger level | `4` |
| `last_received_date` | date | Date stock was last received | `2025-07-06` |
| `snapshot_date` | date | Date the snapshot was taken | `2025-12-31` |

---

## Known questions to resolve during profiling

Run `sql/03_verify_staging.sql` and confirm each of these:

1. Is `discount_pct` expressed as a fraction (0–1) or a percentage (0–100)?
2. Do any `order_lines` reference an order or product that does not exist?
3. Are there orders with no line items?
4. Are `loyalty_tier`, `order_channel`, `line_status` and `product_status`
   values consistently cased and free of stray whitespace?
5. What date range do `orders` and `inventory_snapshot` actually cover, and do
   they overlap enough to join on a shared date dimension?
6. Are there products whose `list_price` is below `unit_cost`?
7. Are there non-positive quantities, and do they correspond to returns?
