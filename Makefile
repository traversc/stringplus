SHELL   := /bin/bash
PACKAGE := $(shell perl -aF: -ne 'print, exit if s/^Package:\s+//' DESCRIPTION)
VERSION := $(shell perl -aF: -ne 'print, exit if s/^Version:\s+//' DESCRIPTION)
BUILD   := $(PACKAGE)_$(VERSION).tar.gz

.PHONY: build install $(BUILD)

build:
	Rscript -e "roxygen2::roxygenise('.');"
	R CMD build .

install:
	Rscript -e "roxygen2::roxygenise('.');"
	R CMD build .
	R CMD INSTALL $(BUILD)

