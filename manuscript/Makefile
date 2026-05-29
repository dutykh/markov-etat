# Makefile for A Cohn-tree reduction of the Frobenius–Markov uniqueness conjecture
# Author: Dr. Denys Dutykh (Khalifa University of Science and Technology, Abu Dhabi, UAE)

TYPST := typst
DOC := DD-LV-Markov
SRC := $(DOC).typ
PDF := $(DOC).pdf

# Project root for typst's --root. The manuscript bundle is self-contained
# (its only asset is the local refs.bib), so the root is this directory.
ROOT := .

.PHONY: all clean

all: $(PDF)

$(PDF): $(SRC)
	$(TYPST) compile --root $(ROOT) $< $@

clean:
	rm -f $(PDF)
