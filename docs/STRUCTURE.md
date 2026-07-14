# Repository conventions

This document describes the conventions every project under [`projects/`](../projects/) follows. Copy [`projects/_template`](../projects/_template) (or run `scripts/new_project.py`) to start a new one.

## Folder layout

Each project is fully self-contained:

```
projects/<project-name>/
├── README.md              # see "Project README" below
├── pyproject.toml         # uv-managed deps, isolated from every other project
├── .env.example           # documents required environment variables
├── data/
│   ├── raw/               # untouched, exactly-as-downloaded data (never committed)
│   ├── interim/           # intermediate, partially-cleaned data (never committed)
│   ├── processed/         # final, model-ready data (never committed)
│   └── README.md          # where to get the data / how to regenerate it
├── notebooks/             # exploration and reporting notebooks
├── src/<package_name>/    # reusable, importable code (functions, classes, pipelines)
├── tests/                 # pytest tests for src/
└── reports/
    └── figures/           # exported charts/images referenced from the README or notebooks
```

## Data policy

- Nothing under `data/raw`, `data/interim`, or `data/processed` is committed to git (only `.gitkeep` placeholders are tracked; see the root [`.gitignore`](../.gitignore)).
- `data/README.md` in each project must explain where to download the raw data from, or how to regenerate it (script, API, public dataset link).
- If a small sample is genuinely needed for demos/tests, keep it under a few hundred KB and put it in `tests/fixtures/` instead of `data/`.
- Never commit credentials, connection strings, or API keys — use `.env` (gitignored) with `.env.example` documenting the expected variables.

## Notebooks

- Numbered by pipeline stage, e.g. `01_exploration.ipynb`, `02_feature_engineering.ipynb`, `03_modeling.ipynb`, `04_evaluation.ipynb`.
- Notebooks are for exploration and narrative reporting; code meant to be reused should be refactored into `src/<package_name>/` and imported.
- Outputs are stripped automatically via `nbstripout` (configured in `.gitattributes` and `.pre-commit-config.yaml`) so diffs stay readable.

## Source code (`src/`)

- One importable package per project, installed in editable mode via `uv sync`.
- Keep notebooks thin: data loading, feature engineering, and model code belongs in `src/`, covered by tests in `tests/`.

## Project README

Every project's `README.md` must include:

1. **Problem statement** — what question is being answered / what's being predicted or analyzed.
2. **Data** — source, size, and how to obtain it (link to `data/README.md` for details).
3. **Approach** — brief description of the method(s) used.
4. **Results** — key metrics/figures, with a link to `reports/figures/` where relevant.
5. **How to run** — exact `uv` commands to set up the environment and reproduce the results.

## Formal reports (optional)

If a project warrants a polished, PDF write-up (beyond the README/notebooks), copy [`templates/latex-report`](../templates/latex-report) into that project's `reports/` folder — see [`templates/latex-report/README.md`](../templates/latex-report/README.md) for usage. It gives every project the same title page, section structure, and styling, so reports stay consistent across the portfolio.

## Tooling

- **uv** manages dependencies and the virtual environment per project (`uv sync`, `uv run ...`).
- **ruff** lints and formats; **mypy** (optional per project) type-checks.
- **pytest** runs the test suite (`uv run pytest`).
- **pre-commit** (configured at the repo root) enforces formatting, linting, and notebook stripping before every commit.
- **LaTeX** (`latexmk` + `pdflatex` + `bibtex`) builds the optional formal report from `templates/latex-report`.
