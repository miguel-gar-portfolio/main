# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

The notebook expects two private, tab-separated files:

| File | Role |
| --- | --- |
| `BD_DC.csv` | Company universe and features |
| `BD_clientes.csv` | Ids of companies that are already customers |

Copy your local copies here:

```text
data/raw/BD_DC.csv
data/raw/BD_clientes.csv
```

The notebook reads them with `sep="\t"` from those paths.

## interim/

Unused. Cleaning and feature construction happen in [`notebooks/01_analysis.ipynb`](../notebooks/01_analysis.ipynb) and stay in memory.

## processed/

Unused. Model-ready frames stay in memory in the notebook. Metrics and the chosen XGBoost parameters are written to [`reports/`](../reports/).
