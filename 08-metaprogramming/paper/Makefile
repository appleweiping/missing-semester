# Makefile for the metaprogramming lecture.
#   paper.pdf : the final artifact
#   plot.png  : generated from data.dat by plot-data.py
#   clean     : Ex1 — remove every rebuilt (git-untracked-generatable) file.
#
# PYTHON can be overridden, e.g.:
#   make PYTHON=/path/to/python
PYTHON ?= python
LATEX  ?= pdflatex

.PHONY: all clean

all: paper.pdf

paper.pdf: paper.tex plot.png
	$(LATEX) -interaction=nonstopmode -halt-on-error paper.tex

plot.png: plot-data.py data.dat
	$(PYTHON) plot-data.py data.dat plot.png

# Ex1: a `clean` target, declared .PHONY, that removes the rebuilt files.
# `git ls-files` lists the tracked (source) files; everything else that our
# rules produce is generated and safe to delete.
clean:
	rm -f plot.png paper.pdf paper.aux paper.log paper.out paper.fls \
	      paper.fdb_latexmk texput.log
