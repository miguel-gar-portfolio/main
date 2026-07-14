# LaTeX report template

A professional, self-contained LaTeX report template shared across every project in this portfolio, so final write-ups look and read consistently. Copy it, fill in the `TODO`s, and build a PDF.

## Layout

```
templates/latex-report/
├── main.tex                 # master document — set title/author/date here
├── preamble.tex             # shared packages, color palette, header/footer, styles
├── sections/
│   ├── 00_titlepage.tex
│   ├── 01_abstract.tex
│   ├── 02_introduction.tex
│   ├── 03_data.tex
│   ├── 04_methodology.tex
│   ├── 05_results.tex
│   ├── 06_discussion.tex
│   └── 07_conclusion.tex
├── references.bib           # BibTeX entries (natbib), example entries included
├── figures/                  # put exported charts/images here
├── .latexmkrc                # latexmk build config (output to build/)
└── Makefile                  # `make`, `make clean`, `make distclean`
```

The section breakdown mirrors the required sections in a project's `README.md` (see [`docs/STRUCTURE.md`](../../docs/STRUCTURE.md)) — problem statement -> introduction, data, approach -> methodology, results -> results/discussion — so the notebook, the project README, and the formal report all tell the same story.

## Using it in a project

```bash
cp -r templates/latex-report projects/<project-name>/reports/report
cd projects/<project-name>/reports/report
```

Then:

1. Edit the metadata block at the top of `main.tex` (`\reporttitle`, `\reportsubtitle`, `\reportauthor`, `\reportdate`, `\reportrepolink`).
2. Fill in each file under `sections/`, replacing the `TODO` placeholders.
3. Drop exported charts into `figures/` and reference them with `\includegraphics{figures/your-file.png}`.
4. Replace the example entries in `references.bib` with your real citations and cite with `\citep{key}` / `\citet{key}`.

## Building

Requires a LaTeX distribution (TeX Live or MiKTeX) with `latexmk`, `pdflatex`, and `bibtex` on `PATH`, plus the `tcolorbox`, `titlesec`, `fancyhdr`, `lastpage`, `tocloft`, and `natbib` packages (all included in a standard/full TeX Live or MiKTeX install).

```bash
make            # builds build/main.pdf
make clean      # removes intermediate files, keeps the PDF
make distclean  # removes the whole build/ directory
```

Without `make`, the equivalent is:

```bash
latexmk main.tex
```

## Design notes

- **Palette**: a single accent color (`accent`, deep blue) drives section headings, rules, links, and callout boxes — defined once in `preamble.tex` so re-branding is a one-line change.
- **Callouts**: use the `notebox` environment for scope notes, caveats, or limitations:

  ```latex
  \begin{notebox}
  TODO: caveat text.
  \end{notebox}
  ```

- **Code snippets**: use the `lstlisting` environment (already styled) for short code excerpts; keep substantial code in `src/`, not the report.
- **Citations**: `natbib` + `bibtex` (not `biblatex`/`biber`) — chosen for the widest out-of-the-box compatibility across TeX Live/MiKTeX installs and CI images.
