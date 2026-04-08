;;; surround.el --- Surround a region with UUID markers in comments -*- lexical-binding: t; -*-

;; SPDX-License-Identifier: GPL-3.0-or-later
;; SPDX-FileCopyrightText: Copyright © 2026 Stephen M. Downey
;; SPDX-FileType: DOCUMENTATION

;; Author: Steve Downey <sdowney@sdowney.dev>
;; Version: 0.1
;; Package-Requires ((org "9.7"))
;; Keywords: org, transclusion
;; URL: https://github.com/steve-downey/surround

;;; Commentary:
;;

(require 'org-id)

;;; Code:
(defvar uuid-surround-mode-to-src-map
      '(
        (awk-mode           . "awk")
        (awk-ts-mode        . "awk")
        (c++-mode           . "cpp")
        (c++-ts-mode        . "cpp")
        (c-mode             . "c")
        (c-ts-mode          . "c")
        (cmake-mode         . "cmake")
        (cmake-ts-mode      . "cmake")
        (emacs-lisp-mode    . "elisp")
        (emacs-lisp-ts-mode . "elisp")
        (haskell-mode       . "haskell")
        (haskell-ts-mode    . "haskell")
        (makefile-mode      . "makefile")
        (makefile-ts-mode   . "makefile")
        (python-mode        . "python")
        (python-ts-mode     . "python")
        (scala-mode         . "scala")
        (scala-ts-mode      . "scala")
      ))


(defvar uuid-surround-transclude-format
  "#+transclude: [[file:%s::%s]] :lines 2- :src %s :end \"%s end\"")

(defun uuid-surround--blank-line-p ()
  "Returns t if line is empty or composed only of syntactic whitespace."
  (save-excursion
    (goto-char (point))
    (beginning-of-line)
    (= (pos-eol)
       (progn (skip-syntax-forward " ") (point)))))

(defun uuid-surround-region ()
    "Surround the current region with UUID in comments for transclusion."
  (interactive "*")
  (comment-normalize-vars)
  (let* ((uuid (org-id-uuid))
         (name buffer-file-truename)
         (src-lang (alist-get major-mode uuid-surround-mode-to-src-map))
         (prefix-wrap (concat comment-start uuid "\n"))
         (postfix-wrap (concat comment-start uuid " end"))
         (transclude (format uuid-surround-transclude-format name uuid src-lang uuid))
         (b (save-excursion (goto-char (region-beginning)) (line-beginning-position)))
         (e (save-excursion (goto-char (region-end)) (line-end-position))))
    (save-restriction
      (narrow-to-region b e)
      (goto-char (point-min))
      (insert prefix-wrap)
      (goto-char (point-max))
      (if (uuid-surround--blank-line-p)
          (beginning-of-line)
        (insert "\n"))
      (insert postfix-wrap))
    transclude))

(defun uuid-surround-region-transclude ()
    "Surround active region with UUIDs for org-transclusion.
Surround the active region with UUID in comments for transclusion and put the
transclusion command in the kill ring."
  (interactive "*")
  (kill-new (uuid-surround-region)))

(provide 'surround)

;;; surround.el ends here
