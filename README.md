# I320D Data Engineering — Retail Final Project

Reproducible data pipeline for the retail industry problem: raw CSV ingestion
into a Postgres staging schema, a dbt-managed dimensional model, reporting-ready
data products, and Superset dashboards.

> **Status:** scaffolding complete; modeling not yet started.
> The assigned problem statement has not been added to this repo yet — see
> [Open items](#open-items).

---

## Team

| Name | GitHub | Role |
|---|---|---|
| Riaan Joshi | @riaanjoshi | |
| | | |

---

## The problem

_TODO: paste the assigned industry problem statement here, then restate the
required analytical questions as a numbered list. Every data product, model and
chart in this repo should trace back to one of these numbered questions._

1. _TODO_
2. _TODO_
3. _TODO_

**Stakeholders:** _TODO_

---

## Data sources

Nine CSV files supplied by the course, ~52,700 rows total. They are **not**
committed to this repository — see [`data/README.md`](data/README.md).

| File | Rows | Grain |
|---|---:|---|
| `order_lines.csv` | 31,459 | one line item on an order |
| `orders.csv` | 14,000 | one customer order header |
| `inventory_snapshot.csv` | 3,800 | one product × store × snapshot date |
| `customers.csv` | 3,010 | one customer account |
| `products.csv` | 380 | one sellable product (SKU) |
| `suppliers.csv` | 25 | one supplier |
| `product_categories.csv` | 14 | one category (rolls up to a department) |
| `stores.csv` | 10 | one store location |
| `payment_methods.csv` | 6 | one tender type |

Relationships: `order_lines → orders → {customers, stores, payment_methods}`,
`order_lines → products → {product_categories, suppliers}`, and
`inventory_snapshot → {stores, products}`.

Full column-level documentation: [`docs/data_dictionary.md`](docs/data_dictionary.md).

---

## Repository layout

```
.
├── data/                   # supplied CSVs (gitignored) + how to obtain them
├── sql/
│   ├── 01_create_staging.sql     # staging schema + 9 tables, re-runnable
│   ├── 02_load_staging.psql      # \copy loader, re-runnable
│   └── 03_verify_staging.sql     # row counts, keys, nulls, orphans, profiling
├── dbt/retail/             # dbt project
│   ├── dbt_project.yml
│   ├── profiles.yml.example      # copy to ~/.dbt/profiles.yml (never commit)
│   ├── packages.yml
│   └── models/
│       ├── staging/_sources.yml  # all 9 sources declared + key/FK tests
│       ├── staging/              # stg_* : clean, cast, rename
│       ├── star/                 # dim_* / fct_* : the dimensional model
│       └── products/             # reporting-ready data products for Superset
├── docs/
│   ├── data_dictionary.md
│   ├── diagrams/           # conceptual ER, physical ER, lineage
│   └── screenshots/        # evidence for the report
├── report/
│   └── final_report.md     # report skeleton, section-by-section
└── starter/                # instructor-supplied starter snippets (unmodified)
```

---

## Prerequisites

- Access to the course Postgres host (`info-smith-i320.inf.utexas.edu:5432`)
- `psql` client
- `dbt-postgres` (already installed at `~/.local/bin/dbt`)
- Superset account

---

## Reproducing the pipeline

### 0. Credentials (one time)

Never commit a password. Create a `~/.pgpass` entry instead:

```bash
echo 'info-smith-i320.inf.utexas.edu:5432:*:YOUR_ROLE:YOUR_PASSWORD' >> ~/.pgpass
chmod 600 ~/.pgpass
```

Then copy the `retail:` block from `dbt/retail/profiles.yml.example` into
`~/.dbt/profiles.yml` and fill in the `TODO` values.

### 1. Place the data

Copy the nine supplied CSVs into `data/` (see `data/README.md`).

### 2. Create and load staging

Run from the **repository root** — `\copy` resolves paths relative to the
directory `psql` was launched from, so `data/...` only works from here:

```bash
cd /path/to/i320d-retail-final-project

psql -h info-smith-i320.inf.utexas.edu -U YOUR_ROLE -d DATABASE \
     -f sql/01_create_staging.sql

psql -h info-smith-i320.inf.utexas.edu -U YOUR_ROLE -d DATABASE \
     -f sql/02_load_staging.psql
```

Both scripts are re-runnable: the DDL drops and recreates each table, and the
loader truncates before each `\copy`, so repeated runs never double the rows.

### 3. Verify the load

```bash
psql -h info-smith-i320.inf.utexas.edu -U YOUR_ROLE -d DATABASE \
     -f sql/03_verify_staging.sql > docs/verification_output.txt
```

This profiles row counts, key uniqueness, nulls, type-cast safety, orphaned
foreign keys, categorical values and value ranges. Record every non-zero result
— it becomes evidence in report sections 3 and 7.

### 4. Build the dbt models

```bash
cd dbt/retail
export PGPASSWORD='your-password'   # only if not using ~/.pgpass
dbt debug          # confirm the connection
dbt deps           # install dbt_utils
dbt build          # run models + tests
dbt docs generate && dbt docs serve
```

### 5. Superset

_TODO: register the `products` schema tables as datasets, build the charts,
assemble the dashboard, and record the dashboard URL here._

---

## Open items

- [ ] Add the assigned problem statement and restated analytical questions
- [ ] Confirm target database (`dataeng` vs `postgres`) and schema name
- [ ] Write `stg_*` models (cast, trim, standardise categorical values)
- [ ] Decide fact grain and write `dim_*` / `fct_*` models
- [ ] Build data products keyed to each analytical question
- [ ] Build Superset dashboard; add URL + instructor access
- [ ] Draw conceptual ER, physical ER and lineage diagrams into `docs/diagrams/`
- [ ] Invite group members as collaborators; grant instructor access

---

## Conventions

- **Staging is text-only.** Every staging column is `VARCHAR` so the load cannot
  fail on a malformed value; casting happens in `stg_*` models. This makes data
  quality measurable instead of fatal.
- **Business keys vs surrogate keys.** Source identifiers (`CUS-000001`) are
  business keys. If surrogate keys are introduced in the star schema, they are
  named `*_sk` and generated with `dbt_utils.generate_surrogate_key`.
- **Commits** are small and descriptively messaged; work happens on branches and
  merges via pull request.
- **No secrets, ever.** Passwords, tokens and connection strings stay out of the
  repository — see `.gitignore`.
