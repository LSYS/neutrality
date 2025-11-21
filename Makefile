.DEFAULT_GOAL := help

########################################################################\
Make gitignore file
########################################################################
.PHONY: giti
giti: ## Make .gitignore from gitignore.io
	@echo "==> $@"
	rm -rf .gitignore
	echo "venv*" > .gitignore
	echo "Copy*.ipynb" >> .gitignore
	echo "scratch/*" >> .gitignore
	echo "*xlsx" >> .gitignore
	echo "**/*.tar.gz" >> .gitignore
	echo "**/*.csv*" >> .gitignore
	echo "**/*.xls" >> .gitignore
	echo "**/*.xlsx" >> .gitignore
	curl https://www.toptal.com/developers/gitignore/api/python >> .gitignore
	curl https://www.toptal.com/developers/gitignore/api/jupyternotebooks >> .gitignore
	curl https://www.toptal.com/developers/gitignore/api/tex >> .gitignore


# ============================================================================
# Set up the Python virtual environment and prepare the Jupyter distribution
# Installs packages from requirements.txt
# ============================================================================
.PHONY: setup
VENVPATH ?= venv_neutrality
ifeq ($(OS),Windows_NT)
	VENVPATH :=  c:/users/admin/$(VENVPATH)
	ACTIVATE_PATH := $(VENVPATH)/Scripts/activate
else
	ACTIVATE_PATH := $(VENVPATH)/bin/activate
endif
REQUIREMENTS := ./assets/requirements.txt
setup: ## Set up venv	
setup: $(REQUIREMENTS)
	@echo "==> $@"
	@echo "==> Creating and initializing virtual environment..."
	rm -rf $(VENVPATH)
	python -m venv $(VENVPATH)
	. $(ACTIVATE_PATH) && \
		pip install --upgrade pip && \
		which pip && \
		pip list && \
		echo "==> Installing requirements" && \
		pip install -r $< && \
		jupyter contrib nbextensions install --sys-prefix --skip-running-check && \
		python -m ipykernel install --user --name=$(VENVPATH) --display-name "Python ($(VENVPATH))" && \
		echo "==> Packages available:" && \
		which pip && \
		pip list && \
		which jupyter && \
		deactivate
	@echo "==> Setup complete."


# ============================================================================
# Open Jupyter notebook in the venv
# ============================================================================
.PHONY: jn
jn: ## Launch jupyter notebook in venv
	@echo "==> $@"
	if [ -f $(VENVPATH)/Scripts/activate ]; then \
		. $(VENVPATH)/Scripts/activate && jupyter notebook; \
	elif [ -f $(VENVPATH)/bin/activate ]; then \
		. $(VENVPATH)/bin/activate && jupyter notebook; \
	else \
		@echo "No venv found"; \
	fi

########################################################################
# 'Freeze' current venv packages
########################################################################
LOCKFILE := ./assets/requirements-locked.txt
.PHONY: pipfreeze
pipfreeze: ## Write specific pkg versions to assets/requirements-locked.txt
	@echo "==> $@"
	@echo "==> Freezing packages from $(VENVPATH)"
	@. $(ACTIVATE_PATH) && python -m pip freeze > $(LOCKFILE)
	@echo; echo "Contents of $(LOCKFILE):"; cat $(LOCKFILE)
	@cat $(LOCKFILE)

########################################################################
# Other utilities
########################################################################
.PHONY: help
help: ## Show this help message and exit
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'