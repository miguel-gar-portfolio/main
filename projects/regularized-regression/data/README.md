# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the instructor file here:

```text
data/raw/AEM_03_Regularization_data.RData
```

It is about 1.2 MB. [`notebooks/01_regularized_regression.Rmd`](../notebooks/01_regularized_regression.Rmd) loads the object `datos` from that path. Six covariate columns are then dropped in memory; that reduced frame is not written back to disk.

## interim/

Unused.

## processed/

Unused. Coefficients, cross-validation curves, and the ten held-out predictions stay in the report [`reports/regularized_regression.pdf`](../reports/regularized_regression.pdf).
