# Data

Nothing under `raw/`, `interim/`, or `processed/` is committed — only `.gitkeep` placeholders are tracked (see the root [`.gitignore`](../../../.gitignore)).

## raw/

Place the instructor file here:

```text
data/raw/datos.RData
```

It is a labeled table of grayscale clothing images (784 pixel columns plus `label`). The file is about 45 MB and is not committed.

[`GenerarDatos.R`](GenerarDatos.R) loads that file from the project directory. With seed `29509` it keeps two classes, 10 of the 784 variables, 1,000 rows (`datos`), and a 75-row subset (`datosred`). The report sources it from [`notebooks/01_clustering_knn_naive_bayes.Rmd`](../notebooks/01_clustering_knn_naive_bayes.Rmd).

## interim/

Unused. Sampling stays in memory inside `GenerarDatos.R`.

## processed/

Unused. Cluster labels, the KNN bootstrap, and the Naive Bayes metrics are computed in the notebook and written into [`reports/clustering_knn_naive_bayes.pdf`](../reports/clustering_knn_naive_bayes.pdf).
