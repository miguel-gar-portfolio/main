#!/usr/bin/env perl
# latexmk configuration for the portfolio report template.
# Usage: latexmk            (build)
#        latexmk -c         (clean intermediates, keep PDF)
#        latexmk -C         (clean everything, including the PDF)

$pdf_mode = 1;                 # produce PDF via pdflatex
$out_dir  = 'build';           # keep build artifacts out of the source tree
$bibtex_use = 2;                # rerun bibtex whenever the .aux changes
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 -halt-on-error %O %S';

# Also remove these on `latexmk -c`.
$clean_ext = 'bbl run.xml synctex.gz';
