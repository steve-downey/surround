#!/usr/bin/env bash

set -x
set -e

EMACS=${EMACS:=emacs}
PACKAGE_DIR=.
MINIMAL_DIR=.minimal-emacs.d
CHECKDOC_DIR=./checkdoc-batch
# Use find to find file names such that globs are expanded while prevent
# splitting paths on spaces
mapfile -t files <<< \
        "$(ls *.el)"

${EMACS} -Q --batch \
         --init-dir=./ \
         --eval '
(progn
  (setq debug-on-error t
        eval-expression-print-length 100
        edebug-print-length 500
        treesit-auto-install nil)
  (load-file "'"${MINIMAL_DIR}"'/early-init.el")
  (load-file "'"${MINIMAL_DIR}"'/init.el")
  (load-file "'"${CHECKDOC_DIR}"'/checkdoc-batch.el"))' \
         --funcall checkdoc-batch \
         "${files[@]}"
