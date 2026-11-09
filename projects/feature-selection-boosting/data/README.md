# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the instructor file here:

```text
data/raw/datos.RData
```

It is the same clothing-pixel table used by the clustering project (about 45 MB). This project keeps its own copy. [`GenerarDatos.R`](GenerarDatos.R) loads it from the project directory and, with seed `29509`, keeps two classes, 10 of 784 variables, and 1,000 rows.

## interim/

Unused. The 75/25 split stays in memory in [`notebooks/01_feature_selection_boosting.Rmd`](../notebooks/01_feature_selection_boosting.Rmd).

## processed/

Unused. Metrics and ROC curves are written into [`reports/feature_selection_boosting.pdf`](../reports/feature_selection_boosting.pdf).
