# Makefile                                                       -*-makefile-*-

# Based on https://github.com/nobiot/org-transclusion/blob/main/Makefile

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.DEFAULT_GOAL := test

EMACS := $(shell command -v emacs 2> /dev/null)

PYEXECPATH ?= $(shell which python3.13 || which python3.12 || which python3.11 || which python3.10 || which python3.9 || which python3.8 || which python3)
PYTHON ?= $(notdir $(PYEXECPATH))
VENV := .venv
UV := $(shell command -v uv 2> /dev/null)
ACTIVATE := $(UV) run
PYEXEC := $(UV) run python
MARKER = .initialized.venv.stamp

PRE_COMMIT := $(UV) run pre-commit

.PHONY: all
all: test

README-elpa: README.org
	$(EMACS) --batch -Q \
		--visit README.org \
		--eval "(require 'ox-ascii)" \
		--eval "(setq org-ascii-charset 'utf-8)" \
		--eval "(setq coding-system-for-write 'utf-8)" \
		--funcall org-ascii-export-to-ascii
	mv README.txt $@

.PHONY: test-compile
test-compile: ## compile everything
	$(EMACS) --batch --eval "(add-to-list 'load-path default-directory)" \
	      -f batch-byte-compile ./*.el
	# Check declare-function
	$(EMACS) --batch --eval "(check-declare-directory default-directory)"

.PHONY: realclean
realclean: ## Clean up everything

.PHONY: clean
clean: ## clean up
	find . -name "*.elc" -delete
realclean: clean

.PHONY: test
test: ## Run test compile and clean up
test: test-compile clean

ifeq ($(EMACS),)

define emacs_error_message

'emacs' command not found.
Please install emacs or set the EMACS variable to the path of the emacs binary.
endef

$(warn "$(emacs_error_message)")
endif

.PHONY: env
env:
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))
.PHONY: venv
venv: ## Create python virtual env
venv: $(VENV)/$(MARKER)

.PHONY: clean-venv
clean-venv: ## Delete python virtual env
	-rm -rf $(VENV)

realclean: clean-venv

.PHONY: show-venv
show-venv: venv
show-venv: ## Debugging target - show venv details
	$(PYEXEC) -c "import sys; print('Python ' + sys.version.replace('\n',''))"
	@echo venv: $(VENV)

uv.lock: pyproject.toml
	$(UV) lock

$(VENV):
	$(UV) venv --python $(PYTHON)

$(VENV)/$(MARKER): uv.lock | $(VENV)
	$(UV) sync
	touch $(VENV)/$(MARKER)

.PHONY: dev-shell
dev-shell: venv
dev-shell: ## Shell with the venv activated
	$(ACTIVATE) $(notdir $(SHELL))

.PHONY: bash zsh
bash zsh: venv
bash zsh: ## Run bash or zsh with the venv activated
	$(ACTIVATE) $@

.PHONY: lint
lint: venv
lint: ## Run all configured tools in pre-commit
	$(PRE_COMMIT) run -a

.PHONY: lint-manual
lint-manual: venv
lint-manual: ## Run all manual tools in pre-commit
	$(PRE_COMMIT) run --hook-stage manual -a

ifeq ($(UV),)
define install_uv_cmd
pipx install uv
endef

define uv_error_message

'uv' command not found.
Please install uv or set the UV variable to the path of the uv binary.
The makefile target "install-uv" will run ``$(install_uv_cmd)''
endef

$(warn "$(uv_error_message)")
endif

.PHONY: install-uv
install-uv: ## install uv via `pipx install uv`
	$(install_uv_cmd)

# Help target
.PHONY: help
help: ## Show this help.
@awk 'BEGIN {FS = ":.*?## "} /^[.a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'  $(MAKEFILE_LIST) | sort
