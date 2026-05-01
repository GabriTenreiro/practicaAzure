# Laptop Price Prediction — Data Pipeline & ML

Data pipeline built with **PySpark** on **Azure Synapse Analytics** for ingesting, cleaning, and transforming laptop scraping data, followed by a machine learning model for price prediction.

## Problem

Predict laptop prices based on technical specifications (CPU, GPU, RAM, storage, screen size, etc.) to help consumers and retailers identify over/underpriced devices.

## Dataset

| Metric | Value |
|---|---|
| Source | Scraped from online laptop stores |
| Rows | 1,563 |
| Columns | 21 |
| Target | Price (regression) |

## Architecture

### Medallion Datalake (ADLS Gen2)

```
raw/ ──────▶ processed/ ──────▶ curated/
  │
  └──▶ quarantine/ ──────▶ rejected/
```

| Zone | Format | Content |
|---|---|---|
| **Raw** | CSV | Source data, no transformations |
| **Processed** | Parquet (snappy) | Clean data, standardized types, HHD→HDD rename |
| **Curated** | Parquet (snappy), partitioned by Company | Deduplicated + 6 derived columns |
| **Quarantine** | Parquet (snappy) | Anomalous but recoverable records |
| **Rejected** | Parquet (snappy) | Irrecoverable records (100% NULL) |

### ETL Pipeline

```
┌──────────────────────────┐
│  01: Raw → Processed     │
│  Schema validation       │
│  Quality checks          │
│  Split: clean/quarantine │
└──────────┬───────────────┘
           │
    ┌──────┴──────┐
    ▼             ▼
┌─────────┐  ┌──────────────────┐
│ 02:     │  │ If quarantine>0  │
│ Curated │  │ → 03: Rejected   │
└─────────┘  └──────────────────┘
```

## Project Structure

```
├── notebooks/
│   ├── 01_ingesta_raw_a_processed.ipynb   # CSV → quality → processed + quarantine
│   ├── 02_processed_to_curated.ipynb      # Deduplicate + derived columns + partition
│   ├── 03_quarantine_to_rejected.ipynb    # Split recoverable vs irrecoverable
│   └── ml_feature_engineering_and_training.ipynb  # Feature engineering + ML models
├── infra/
│   ├── deploy.bicep                       # Azure infrastructure (Bicep)
│   └── laptop_data_pipeline.json          # Synapse pipeline definition
├── docs/
│   ├── modelo_de_datos.md                 # Data model, schemas, quality rules
│   ├── plan_de_pruebas.md                 # Test plan (10 tests)
│   └── evidencias_pruebas.md              # Test evidence template
├── dashboard/
│   └── README.md                          # Power BI dashboard guide
├── datalake/
│   └── raw/
│       └── laptop_scrap_data.csv          # Source dataset
├── pyproject.toml
└── README.md
```

## Infrastructure

| Resource | Name |
|---|---|
| Resource Group | `rg-gabritenreiro` |
| Storage Account | `stgabritenreiroprueba` (ADLS Gen2) |
| Synapse Workspace | `syn-laptop-dl-dev-001` |
| Spark Pool | `sparkpoollaptop` (Small, 3 nodes, auto-shutdown 15min) |

### Deploy

```bash
az deployment group create --resource-group rg-gabritenreiro --template-file infra/deploy.bicep
```

## Getting Started

### Prerequisites

- Python 3.12+
- [uv](https://github.com/astral-sh/uv) package manager
- Azure CLI (`az`)
- Azure subscription with Synapse Analytics access

### Local Setup

```bash
# Install dependencies
uv sync

# Run notebooks locally (requires HADOOP_HOME on Windows)
# See notebooks/ for execution instructions
```

### Synapse Execution

1. Open Synapse Studio: https://web.azuresynapse.net
2. Import notebooks from `notebooks/`
3. Import pipeline from `infra/laptop_data_pipeline.json`
4. Upload `datalake/raw/laptop_scrap_data.csv` to the `raw` container
5. Execute the pipeline or run notebooks individually

## Data Quality

| Rule | Criteria | Action |
|---|---|---|
| Price valid | NOT NULL AND > 0 | → Quarantine |
| Ram_GB valid | NOT NULL AND > 0 | → Quarantine |
| Weight_kg valid | NOT NULL AND > 0 | → Quarantine |
| Inches valid | NOT NULL AND > 0 | → Quarantine |
| All columns NULL | 100% NULL | → Rejected |

## Machine Learning

The `ml_feature_engineering_and_training.ipynb` notebook covers:

1. **Feature Engineering** — Distributions, correlations, PCA analysis, target balance
2. **Training** — Random Forest vs Neural Network (MLPRegressor)
3. **Evaluation** — R², MAE, RMSE comparison
4. **Deployment** — FastAPI REST endpoint + Docker containerization

## Documentation

| Document | Description |
|---|---|
| [Data Model](docs/modelo_de_datos.md) | Medallion architecture, schemas, quality rules |
| [Test Plan](docs/plan_de_pruebas.md) | 10 tests: integrity, uniqueness, completeness, consistency |
| [Test Evidence](docs/evidencias_pruebas.md) | Results template with pass/fail criteria |
| [Dashboard Guide](dashboard/README.md) | Step-by-step Power BI dashboard creation |

## License

This project is part of a master's degree final practice.
