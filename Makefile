# Makefile                                                       -*-makefile-*-

# Based on https://github.com/nobiot/org-transclusion/blob/main/Makefile

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.DEFAULT_GOAL := test

EMACS := $(shell command -v emacs 2> /dev/null)

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

.PHONY: clean
clean: ## clean up
	find . -name "*.elc" -delete

.PHONY: test
test: ## Run test compile and clean up
test: test-compile clean

ifeq ($(EMACS),)

define emacs_error_message

'emacs' command not found.
Please install emacs or set the EMACS variable to the path of the emacs binary.
endef

$(error "$(emacs_error_message)")
endif

# Help target
.PHONY: help
help: ## Show this help.
@awk 'BEGIN {FS = ":.*?## "} /^[.a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'  $(MAKEFILE_LIST) | sort
