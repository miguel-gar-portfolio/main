# Customer propensity

Imbalanced classification of the propensity for a company to become a customer, plus a methodological proposal for detecting legal company names in legal texts.

## Problem statement

Exercise 1 predicts whether a company will become a customer of an advertiser. The target is binary and highly imbalanced: a company is a positive if its id appears in the customer file. Exercise 2 is a written proposal for detecting legal company names (for example `BANCO SANTANDER S.L.`) in legal documents. The problem statements are in [`exercise.md`](exercise.md). The written answers are in [`solutions.md`](solutions.md).

## Data

- **Source:** private local CSVs.
- **Files:** `BD_DC.csv` (company universe and features) and `BD_clientes.csv` (ids of companies that are already customers). Both are tab-separated.
- **Size:** the universe file is about 30 MB; the customer-id file is about 30 KB.
- See [`data/README.md`](data/README.md) for where to place the files locally. Git tracks only the `.gitkeep` placeholders under `data/`.

## Approach

The notebook [`notebooks/01_analysis.ipynb`](notebooks/01_analysis.ipynb) builds the target by joining the universe to the customer ids, engineers company age from the founding year, drops high-missing and redundant columns, and uses one stratified 70/15/15 train/validation/test split for both models.

A logistic regression (imputation, scaling, and one-hot encoding inside a pipeline fitted on train only) is the baseline. XGBoost is trained on the full feature set, including columns the baseline drops, with hyperparameters from grid search stored in [`reports/best_xgb_params.json`](reports/best_xgb_params.json). The decision threshold is chosen with a fictitious business metric: one advertising impact costs 10 monetary units and winning a customer yields 200. SHAP is used to describe the preferred customer profile.

Exercise 2 proposes a regex baseline on legal suffixes (`S.A.`, `S.L.`, and similar), then a NER model such as BERT or RoBERTa. Details are in [`solutions.md`](solutions.md).

## Results

On the shared test set ([`reports/metrics_comparison.json`](reports/metrics_comparison.json)):

| Model | Threshold | F1 | Precision | Recall | ROC-AUC | PR-AUC |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Logistic regression | 0.50 | 0.180 | 0.104 | 0.665 | 0.735 | 0.132 |
| XGBoost | 0.044 | 0.335 | 0.209 | 0.839 | 0.931 | 0.679 |

The business score on that test set is 1,001,580 for the baseline and 1,296,250 for XGBoost. Exported charts, if saved from the notebook, go under [`reports/figures/`](reports/figures/).

## How to run

From this directory, with the CSVs already in `data/raw/` (see [`data/README.md`](data/README.md)):

```bash
uv sync
uv run jupyter lab   # open notebooks/01_analysis.ipynb and run cells in order
uv run pytest
```

The notebook reads and writes paths relative to this directory. The XGBoost grid search can take a while. Python 3.12 is the version this project was tested with; `uv sync` provisions it.
