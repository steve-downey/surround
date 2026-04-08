#!/usr/bin/env bash

set -x
set -e

EMACS=${EMACS:=emacs}
# MINIMAL_DIR=.minimal-emacs.d

# Use find to find file names such that globs are expanded while prevent
# splitting paths on spaces
mapfile -t files <<< \
        "$(ls ./*.el)"

PROGN=$(
cat <<'END_HEREDOC'
(progn
  (setq debug-on-error t
        eval-expression-print-length 100
        edebug-print-length 500
        treesit-auto-install nil)
  (load-file ".minimal-emacs.d/early-init.el")
  (load-file ".minimal-emacs.d/init.el")
  (use-package relint :ensure t :init (setq relint-xr-checks 'all)))
END_HEREDOC
)

${EMACS} -Q --batch \
         --init-dir=./ \
         --eval "$PROGN" \
         --funcall relint-batch \
         "${files[@]}"
