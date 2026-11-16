# `data/` — supplied CSV files

The nine CSVs for this project are **intentionally not committed**. They are
course-supplied data, and `.gitignore` excludes `data/*.csv`.

## How to populate this folder

The files were provided in the course environment at `~/retail/data/`. Copy them
into this folder before running the pipeline:

```bash
cp ~/retail/data/*.csv data/
```

Expected files and row counts (excluding the header row):

| File | Data rows |
|---|---:|
| `customers.csv` | 3,010 |
| `inventory_snapshot.csv` | 3,800 |
| `order_lines.csv` | 31,459 |
| `orders.csv` | 14,000 |
| `payment_methods.csv` | 6 |
| `product_categories.csv` | 14 |
| `products.csv` | 380 |
| `stores.csv` | 10 |
| `suppliers.csv` | 25 |

Every file has a header row, and column order matches the staging table
definitions in `sql/01_create_staging.sql`.

## Confirm before loading

```bash
wc -l data/*.csv      # row counts include the header
head -2 data/*.csv    # header + first data row
```
