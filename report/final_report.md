# I320D Data Engineering — Retail Final Project Report

**Team:** _TODO_
**Repository:** https://github.com/riaanjoshi/i320d-retail-final-project
**Superset dashboard:** _TODO (paste direct URL; confirm instructor access)_
**Date:** _TODO_

---

## 1. Introduction and restatement of requirements

_2–3 paragraphs._

_Paragraph 1 — the assigned industry problem and its stakeholders._

_Paragraph 2 — restate the required analytical questions in your own words, as
a numbered list, so each can be pointed at later._

1. _TODO_
2. _TODO_
3. _TODO_

_Paragraph 3 — summarise the provided data, the planned warehouse structure, the
dimensional model, the data products and the dashboard._

---

## 2. Data ingestion

### 2.1 Source documentation

**(a) Concrete source rows.** _Paste real rows from each CSV, including nulls
and formats as they actually appear. Mask emails._

**(b) Conceptual ER diagram.** _Entities and relationships only, no
implementation detail._ → `docs/diagrams/conceptual_er_source.png`

**(c) Physical ER diagram.** _Actual tables, columns, data types, PKs, FKs and
cardinality._ → `docs/diagrams/physical_er_source.png`

**(d) Sample tables after loading.** _Query output or screenshots._

Per source: origin, format, field meanings, keys, row count, known quality
concerns. See `docs/data_dictionary.md`.

### 2.2 Staging DDL

Script: `sql/01_create_staging.sql`

_Paste the full script in a fenced SQL block. Explain: the repository path, how
the database connection is selected, the execution order, and how you verify the
tables exist._

_Explain the design decision that every staging column is `VARCHAR`, and why
that makes data quality measurable rather than fatal._

### 2.3 Bulk loading with `psql \copy`

Script: `sql/02_load_staging.psql`

_Paste the complete file as preformatted text — not an excerpt, not a
screenshot. State the path and the exact command used._

_Explain that `\copy` is a psql client-side meta-command: file paths resolve on
the client machine relative to where psql was launched, unlike server-side
`COPY`. State that every CSV has a header row and that column order matches the
destination table._

**Verification.** Script: `sql/03_verify_staging.sql`

_Show `SELECT COUNT(*)` per staging table, a few sample rows, null checks, and
any rejected-row or type-conversion issues. Explain the corrections made and why
the load is repeatable (DROP/CREATE in the DDL, TRUNCATE before each `\copy`)._

_No passwords anywhere in this report._

---

## 3. Data transformation: star schema

### 3.1 Facts, grain, dimensions

_~1 paragraph. State the fact grain in one unambiguous sentence, e.g. "one row
per order line." Identify the measures and the descriptive dimensions. Explain
how these choices answer the assigned questions and prevent double-counting —
including the rule applied to returned lines, and why the inventory snapshot is
a separate fact rather than part of the sales fact._

### 3.2 Transformation diagram

_Lineage diagram: each staging source → the derived dimensions and facts, with
arrows labelled for cleaning, joining, casting, deduplication and surrogate-key
generation. This must explain where each output attribute comes from, not just
restate the star ER diagram._ → `docs/diagrams/lineage.png`

### 3.3 Star schema documentation

Repeat all four artifacts for the dimensional model:

- Concrete rows from the fact and each dimension
- Conceptual star ER → `docs/diagrams/conceptual_er_star.png`
- Physical ER with columns, types, keys and FK relationships → `docs/diagrams/physical_er_star.png`
- Query output or screenshots from the built tables

_Distinguish business/source identifiers from surrogate keys. State whether
constraints are enforced by the database or validated with dbt tests, and show
`dbt build` output as evidence._

---

## 4. Data products

_For each reporting-ready table or view in `dbt/retail/models/products/`:_

| | |
|---|---|
| **Question answered** | _which numbered requirement_ |
| **Grain** | _one row per …_ |
| **Filters** | |
| **Measures** | |
| **Dimensions** | |
| **Supports which visualization** | |
| **Validation** | _how you confirmed the numbers are right_ |

_Include sample output rows for each._

---

## 5. Data analysis and visualization

_One subsection per restated requirement. For each chart: the question, the
dataset/data product behind it, the aggregation, axes, filters, units, the
observed result, and caveats._

_Embed the downloaded dashboard image and provide a direct clickable URL.
Confirm the instructor can open it._

_Discuss the chart alternatives considered and why the chosen one is better.
Explain the colour palette including accessibility and contrast, the labels,
column aliases and dashboard filter behaviour._

_Do not claim a trend or a causal explanation the data does not support._

### 5.1 Requirement 1 — _TODO_
### 5.2 Requirement 2 — _TODO_
### 5.3 Requirement 3 — _TODO_

---

## 6. Reflection and challenges addressed

_~200 words on concrete problems: how you detected them, how you fixed them, and
what you would change next time. Then a few sentences on specific
accomplishments._

---

## 7. GitHub repository and project organization

**Repository URL:** https://github.com/riaanjoshi/i320d-retail-final-project
**Visibility:** Private — instructor access granted _TODO: confirm_

_Describe how the project is organised, the team's collaboration process
(branches, pull requests, issues/project board), and where the scripts,
diagrams, models and report live._

_Confirm: the main branch holds the final deliverables, the README instructions
work from a clean clone, no secrets or restricted data are committed._

---

## Submission checklist

- [ ] 2–3 paragraph introduction and explicit restated questions
- [ ] Source examples, conceptual ER, physical ER, sample-table evidence
- [ ] Full staging DDL and complete `\copy` script, paths, commands, verification
- [ ] Facts, grain, dimensions and transformation diagram
- [ ] Star schema examples, conceptual ER, physical ER, sample tables
- [ ] Student-designed dbt models, explanations, evidence of successful transformations
- [ ] Data product rationale, grain, fields, sample outputs, validation
- [ ] Superset dashboard image, working URL, an answer for every requirement
- [ ] Chart choice, colour scheme, aliases, aggregation and filter rationale
- [ ] GitHub repo created, collaborators added, README and `.gitignore` included
- [ ] Repository URL and reproduction instructions included; no secrets committed
- [ ] ~200-word challenges reflection plus achievements
