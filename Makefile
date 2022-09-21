# Minimal makefile for nominal-set.agda-lib
.ONESHELL:
SHELL := /bin/bash
SRC = $(wildcard src/*.agda)

all: nominalset

nominalset: $(SRC)
	@echo $(SRC)

clean:
	rm -rf _build

generate: $(SRC)
	find src/ -type f -name "*.agda" | xargs -0 | sed 's/src\///g; s/\.agda//g; s/\//./g; /^$$/d' | awk '{print "import " $$0}' > Everything.agda
