.DEFAULT_GOAL := help

VENVPATH ?= venv_neutrality

ifeq ($(OS),Windows_NT)
	ACTIVATE_PATH := ../$(VENVPATH)/Scripts/activate
else
	ACTIVATE_PATH := ../$(VENVPATH)/bin/activate
endif


########################################################################
# Make data in pipeline
########################################################################
.PHONY: data
data: ## Run all notebooks, then run build.ipynb last
	@echo "==> Executing notebooks with runpynb in $(VENVPATH)"
	@mkdir -p logs
	. $(ACTIVATE_PATH) && \
	runpynb \
	  build-article-topics.ipynb \
	  build-article.ipynb \
	  build-linguistics.ipynb \
	  build-mp.ipynb \
	  build-semsim.ipynb \
	  build-speech-topics.ipynb \
	  build-verbatim-accuracy.ipynb && \
	runpynb build.ipynb


########################################################################
# Jupytext sync to .py
########################################################################
.PHONY: sync-setup
sync-setup: ## Set up jupytext sync for all notebooks (creates .py files in logs/)
	@echo "==> Setting up jupytext sync in $(VENVPATH)"
	@mkdir -p logs
	. $(ACTIVATE_PATH) && \
	jupytext --set-formats ipynb,.//py *.ipynb
	@echo "All notebooks now synced with Python files"

.PHONY: sync
sync: ## Manually sync w/ Jupytext all paired notebooks with their .py files
	@echo "==> Syncing notebooks with Python files"
	. $(ACTIVATE_PATH) && \
	jupytext --sync *.ipynb
	@echo "Sync complete"

########################################################################
# Pylint
########################################################################
UTIL := utilities.py

.PHONY: pylint
pylint: ## Run mypy, pyflakes, isort, black on utilities.py (same as GH action)
	. $(ACTIVATE_PATH) && \
	mypy --ignore-missing-imports --check-untyped-defs --exclude='.*__init__\.py$$' $(UTIL) && \
	pyflakes $(UTIL) && \
	isort $(UTIL) && \
	black -l 88 $(UTIL)

########################################################################
# Notebook lint
########################################################################
NOTEBOOKS := \
    ./0-get-subzones-from-records.ipynb \
    ./1-get-IDs.ipynb \
    ./2-get-devicehome.ipynb \
    ./3-get-movementcount.ipynb \
    ./4-postal-to-2014subzonename.ipynb \
    ./5-compile-POI-count.ipynb \
    ./6a-clean-housetype.ipynb \
    ./6b-map-weather.ipynb \
    ./7-merge.ipynb

.PHONY: lint-notebooks
lint-notebooks: ## Run nbqa pyflakes and black --check on selected notebooks
	@echo "==> NBQA pyflakes"
	. $(ACTIVATE_PATH) && nbqa pyflakes $(NOTEBOOKS)
	@echo "==> NBQA black"
	. $(ACTIVATE_PATH) && nbqa black $(NOTEBOOKS)

########################################################################
# Other utilities
########################################################################
.PHONY: help
help: ## Show this help message and exit
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'