export EMACS ?= $(shell command -v emacs 2>/dev/null)
CASK_DIR := $(shell cask package-directory)

.PHONY: cask-install
cask-install:
	cask install

$(CASK_DIR): Cask
	$(MAKE) cask-install
	@touch $(CASK_DIR)

.PHONY: cask
cask: $(CASK_DIR)

.PHONY: bytecompile
bytecompile: cask
	cask emacs -batch -L . -L test                  \
      --eval "(setq byte-compile-error-on-warn t)"  \
      -f batch-byte-compile $$(cask files)
	  (ret=$$? ; cask clean-elc ; exit $$ret)

.PHONY: lint
lint: cask
	cask emacs -batch -L .                                  \
      --load package-lint                                   \
      --funcall package-lint-batch-and-exit $$(cask files)

.PHONY: relint
relint: cask
	cask emacs -batch -L .                      \
      --load relint                             \
      --funcall relint-batch $$(cask files)

.PHONY: checkdoc
checkdoc: cask
	cask emacs -batch -L .                      \
      --load checkdoc-batch                     \
      --funcall checkdoc-batch $$(cask files)
