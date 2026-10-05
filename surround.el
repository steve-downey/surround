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
(require 'org-src)
(require 'seq)
(require 'subr-x)

;;; Code:

(defvar uuid-surround-transclude-format
  "#+transclude: [[file:%s::%s]] :lines 2- :src %s :end \"%s end\"")

(defun uuid-surround--src-language (&optional mode)
  "Return the Org source language corresponding to MODE.
MODE defaults to `major-mode'.  Prefer a language known to Org, and otherwise
derive the language from the conventional MODE name."
  (let* ((mode (or mode major-mode))
         (mapping
          (seq-find
           (lambda (entry)
             (eq mode (org-src-get-lang-mode (car entry))))
           org-src-lang-modes))
         (mode-name (symbol-name mode)))
    (or (car mapping)
        (cond
         ((string-suffix-p "-ts-mode" mode-name)
          (string-remove-suffix "-ts-mode" mode-name))
         ((string-suffix-p "-mode" mode-name)
          (string-remove-suffix "-mode" mode-name)))
        (user-error "Cannot infer an Org source language from `%s'" mode))))

(defun uuid-surround--blank-line-p ()
  "Return t if line is empty or composed only of syntactic whitespace."
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
         (src-lang (uuid-surround--src-language))
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
