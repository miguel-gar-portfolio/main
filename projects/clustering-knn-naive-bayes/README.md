# Clustering, KNN, and Naive Bayes

K-means, hierarchical clustering, weighted KNN, and kernel Naive Bayes on a two-class clothing sample.

## Problem statement

Three exercises use one sampled data set. Exercise 1 clusters `datosred` without the label, using K-means and agglomerative hierarchical clustering. Exercise 2 fits a weighted KNN on `datosred` and estimates generalisation with the bootstrap 632+ method. Exercise 3 fits a kernel Naive Bayes model on a 75/25 split of the larger frame `datos` and reports accuracy, the ROC curve, and AUC. The instructor statement is [`ML1_Enunciado_RPM_MDCV.pdf`](ML1_Enunciado_RPM_MDCV.pdf).

## Data

- **Source:** `datos.RData`, placed locally in `data/raw/`. [`data/GenerarDatos.R`](data/GenerarDatos.R) samples it with seed `29509`.
- **Sample:** two clothing classes (Pullover and Ankle boot), 10 of 784 pixel variables, 1,000 rows in `datos`, and 75 rows in `datosred`.
- See [`data/README.md`](data/README.md). `datos.RData` is not committed.

## Approach

The report is [`notebooks/01_clustering_knn_naive_bayes.Rmd`](notebooks/01_clustering_knn_naive_bayes.Rmd). The same analysis as a script is [`notebooks/clustering_knn_naive_bayes.R`](notebooks/clustering_knn_naive_bayes.R). A Jupyter notebook is [`notebooks/02_trabajo_clustering_knn_naive_bayes.ipynb`](notebooks/02_trabajo_clustering_knn_naive_bayes.ipynb).

Features are scaled before clustering. K-means uses k = 2. Hierarchical clustering uses Ward's method and cuts the tree at 2 clusters. Weighted KNN is tuned with `kknn` (rectangular kernel, k = 2). Kernel Naive Bayes uses `naivebayes` on a 75/25 split of `datos`, and `pROC` draws the ROC curve. Other packages used in the report are `ggplot2`, `cluster`, `factoextra`, `ks`, and `cat`.

## Results

Clustering agrees with the true labels only slightly better than chance. Hierarchical clustering is a little stronger than K-means. Weighted KNN has an empirical error of 0 on `datosred` and a bootstrap 632+ error of 7.6%. Kernel Naive Bayes reaches about 90% test accuracy, about 86% on Ankle boot, with a very high AUC. Charts are in [`reports/clustering_knn_naive_bayes.pdf`](reports/clustering_knn_naive_bayes.pdf). [`reports/figures/`](reports/figures/) has no separate image files.

## How to run

From this directory, with `datos.RData` in `data/raw/` and the R packages `ggplot2`, `cluster`, `factoextra`, `ks`, `kknn`, `cat`, `naivebayes`, `pROC`, and `rmarkdown` installed:

```r
rmarkdown::render(
  "notebooks/01_clustering_knn_naive_bayes.Rmd",
  output_format = "pdf_document",
  output_file = "clustering_knn_naive_bayes.pdf",
  output_dir = "reports"
)
```

```bash
uv sync
uv run pytest
```

`uv sync` and `uv run pytest` cover the placeholder Python package. Run `notebooks/clustering_knn_naive_bayes.R` from this directory so `source("data/GenerarDatos.R")` resolves.
