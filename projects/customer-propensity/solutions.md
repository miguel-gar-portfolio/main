# EXERCISE ONE

The target variable is the propensity of a company to become a customer of an advertiser. The variable is binary and highly imbalanced.

## Descriptive analysis

In this sample descriptive analysis (a real model should be more exhaustive), the starting point is how advertising behaves by target. The distributions are clearly different. When the target is 1, the distribution concentrates around the values 1 and 2 (Q1 and Q3 respectively) with a very small interquartile variance. When the target is 0, the distribution has greater variance and 0 is included as the lower bound. The target is 1 only when advertising impacts are at least one.

Sales range also shows differentiated distributions. When the target is 1, the values concentrate around higher values than when the target is 0.

Looking at the province variable, the provinces are represented unevenly. Barcelona and Madrid account for most of the companies in the dataset, which may be due to greater industrial and economic activity in these urban centers. Looking at the percentage of each province, Barcelona has a larger share when target = 1 than when target is 0. That is interesting and could imply that province is a discriminating variable, largely because of Barcelona.

Finally, for office type there are no significant differences between the distributions in the two groups, which could indicate that it is a useful variable for classifying the target.

## Data treatment

1. **Target construction**
  `BD_DC` is joined with `BD_clientes` on `id`: `target = 1` if the company is in the customer file, `0` otherwise. `id` is dropped after the target is created.
2. **Age feature engineering**
  `anyofundacion` is parsed as a date (`dd/mm/YYYY`) and transformed into `company_age_years` relative to a fixed observation date (`2024-01-01`). `anyofundacion` and the auxiliary date are dropped.
3. **Missing-value analysis and treatment**
  The percentage of missing values is analyzed by variable and by target class. Rows with no value in key variables are dropped: `universo`, `actcnae`, `mercado`, `rangoventas`. The variable `riesgo` is discarded because 99% of its values are missing and the difference between groups is practically null. The remaining missing values are left for XGBoost (it supports missing values); the baseline imputes the remaining NaNs inside the pipeline (using train statistics only).
4. **Geographic dimensionality reduction**
  `municipio`, `codpostal`, and `comunidadautonoma` are dropped; province is kept as a sufficient geographic level.
5. **Redundant categorical activity-type variables**
  After reviewing cardinality and overlap, `actcnae` and `mercado` are dropped, and `cnae_mercado` is kept.
6. **Baseline features**
  The baseline excludes `tendenciaempleados` and `tendenciaingresos` (~50%+ missing) and uses `SimpleImputer` (median / mode) + `StandardScaler` / `OneHotEncoder` inside a `Pipeline` fitted on train only.
7. **Shared stratified split**
  A single 70% train / 15% validation / 15% test split (stratified by `target`). Both models are evaluated on the same test indices; XGBoost uses all features (including the tendencia* columns), and the baseline uses the same rows without those columns.
8. **No data leakage**
  A single split is used so both models can be evaluated on the same test-set rows. That is why value imputation is used.



## Selected model

First, a model is built to serve as a reference to beat. If the company already had a model, that model would be used. Here, because there is no preexisting model, a simple logistic regression is used as the reference. It applies only basic operations, such as one-hot encoding and data scaling. As mentioned above, missing values are also imputed.

Once the baseline is in place, an XGBoost model is trained. This choice is motivated both by its generally strong performance on binary classification problems and by the presence of several variables with missing values. XGBoost is a strong candidate for the optimal model because it can natively accept missing values and use them as information when building probabilities. To find the best possible model, the best parameters are searched with cross-validation.

The main obstacle in this problem, as is common in binary classification, is that the positive class is a very small minority, so the classification rule has to be chosen to meet business needs. After obtaining the XGBoost probabilities, the best threshold is selected with a fictitious business metric, using this logic: one advertising impact costs 10 monetary units, and winning a customer yields 200 units. An objective function based on that logic is used to calculate the optimal classification threshold.

## Choice of potential customers

According to the importance plot and the SHAP values, companies with the following profile are preferred:

A company with between 1 and 11 impacts

`cnae_mercado` of type wholesale or retail trade, or public administration

Between 5 and 15 years old (reference date 2024)

From the province of Barcelona

Universe of type active_business

With the highest possible sales range

With a positive `tendencia_empleados` of any type

With a positive `tendencia_ingresos`, preferably linear

With more than 120 employees

With email

This would be the ideal profile according to the analysis.

## Applying the model to new data

The data show that the company acquires customers once it advertises to the target companies. That is why the `impactos_publicidad` variable can raise doubts as an explanatory variable. It is still one of the most relevant variables for classifying companies that are likely to become customers. The model needs that information in order to predict accurately, so the implication is methodological at prediction time. Every variable is passed through as usual to obtain a prediction, except `impactos_publicidad`, which is increased by one unit, simulating that the company has been advertised to. This keeps the model, possible data leakage from this variable, and the business evaluation function consistent. That function is based on the cost of advertising and the benefit of acquiring a new customer.

## Highest-probability predictions

The top 5 predictions with the highest probability show a profile very close to the ideal profile defined above, and they are very similar to each other. That confirms that the conclusions are correct, at least on this dataset.

# EXERCISE TWO



## Detecting legal company names in legal documents

For a series of legal documents, the legal company names of the companies mentioned in the text need to be detected.

## Prompt

Write a short description of:

- The possible ways to approach the problem.
- The methodologies that could be used.
- Which option or options would be the most interesting.
- Why those options would be the most appropriate.



## Proposal

The problem is to identify the legal entities in the given texts, for example BANCO SANTANDER S.L.

First, for methodological consistency, a baseline could be built by detecting these entities with regular expressions that look for patterns using suffixes such as "S.A.", "S.L.", and so on. This method is not robust to language variation, but it would be useful as a baseline.

After the baseline, a more robust approach would be NLP with architectures that use attention mechanisms. BERT or RoBERTa would be good candidates. The scientific literature supports this choice [https://www.alphaxiv.org/abs/2112.00405](https://www.alphaxiv.org/abs/2112.00405). This problem specifically calls for a NER-BERT style model, which in essence requires a training set with entity tokens — legal company names, in this case — in each sentence. The model then learns the structural patterns that define the identity and, according to the paper, needs minimal fine-tuning and generalizes better to new domains. A BERT or RoBERTa architecture would add a classification layer through suitable labeling of the set, for example:

```
Construcciones → B-ORG
del            → I-ORG
Sur            → I-ORG
S.L.           → I-ORG
firmó          → O
el             → O
contrato       → O
```

Evaluation could then use the usual binary classification metrics: precision, recall, and F1. Another approach would be to allow an inexact match with IoU (Intersection over Union); favoring an exact match seems more appropriate.

Another option would be to use an LLM with fine-tuning, but for such a specific task that can add unnecessary complexity and cost. In the LLM setting, prompting could also be used.
