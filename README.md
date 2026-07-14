# Data Science Portfolio

A monorepo collecting my data science and machine learning projects. Each project lives in its own folder under [`projects/`](projects/), is fully self-contained (own dependencies, own virtual environment, own tests), and follows the same conventions described in [`docs/STRUCTURE.md`](docs/STRUCTURE.md).

## Repository structure

```
portfolio/
├── README.md
├── LICENSE
├── docs/
│   └── STRUCTURE.md          # conventions followed by every project
├── scripts/
│   └── new_project.py        # scaffolds a new project from the template
├── templates/
│   └── latex-report/         # shared LaTeX template for formal PDF write-ups
└── projects/
    ├── _template/            # copy this to start a new project
    └── <project-name>/       # one folder per real project
```

## Projects

| Project | Description | Tech | Status |
| --- | --- | --- | --- |
| _none yet_ | — | — | — |

New projects will be listed here as they're added.

## Tech stack

- **Python** 3.11+
- **[uv](https://docs.astral.sh/uv/)** for dependency management and virtual environments (one per project)
- **[ruff](https://docs.astral.sh/ruff/)** for linting and formatting
- **[pytest](https://docs.pytest.org/)** for testing
- **[pre-commit](https://pre-commit.com/)** for local quality gates
- **[nbstripout](https://github.com/kynan/nbstripout)** to keep notebook diffs clean
- **LaTeX** (`latexmk`/`pdflatex`/`bibtex`) for optional, consistently-styled formal PDF reports

## Getting started

### Adding a new project

```bash
python scripts/new_project.py my-new-project
cd projects/my-new-project
uv sync
```

This copies [`projects/_template`](projects/_template) into `projects/my-new-project`, renames the source package, and fills in the project name across the template files.

### Working on an existing project

```bash
cd projects/<project-name>
uv sync
uv run pytest
uv run jupyter lab
```

### Repo-wide checks

```bash
pip install pre-commit
pre-commit install
pre-commit run --all-files
```

### Writing a formal report

```bash
cp -r templates/latex-report projects/<project-name>/reports/report
cd projects/<project-name>/reports/report
latexmk main.tex
```

See [`templates/latex-report/README.md`](templates/latex-report/README.md) for the full layout and design notes.

## Conventions

See [`docs/STRUCTURE.md`](docs/STRUCTURE.md) for the full set of conventions: folder layout, data policy, notebook numbering, and the required sections in each project's README.

## License

This repository is licensed under the [MIT License](LICENSE).
