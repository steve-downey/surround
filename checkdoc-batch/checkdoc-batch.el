;;; checkdoc-batch.el --- Run checkdoc on command line arguments -*- lexical-binding: t -*-

;; Copyright (C) 2023 Przemyslaw Kryger

;; Author: Przemyslaw Kryger <pkryger@gmail.com>
;; Keywords: tools elisp checkdoc
;; Homepage: https://github.com/pkryger/checkdoc-batch.el
;; Package-Requires: ((emacs "28.1"))
;; Version: 0.0.0

;;; Commentary:

;; This is a transformation of
;;   (flycheck-checker-shell-command 'emacs-lisp-checkdoc)
;;
;; See README.org file for a tips how to get a template to fiddle with to
;; produce function `checkdoc-batch'.

;;; Code:

(require 'cl-lib)

(defvar jka-compr-inhibit)
(defvar checkdoc-diagnostic-buffer)

(defgroup checkdoc-batch nil
  "Run `checkdoc' on command line arguments."
  :group 'lisp)

(defcustom checkdoc-batch-ignored
  '("-autoloads\\.el\\'" "-pkg\\.el\\'")
  "Specify patterns of file names that should be ignored."
  :type '(repeat (regexp :tag "Pattern"))
  :group 'checkdoc-batch)

(defun checkdoc-batch ()
  "Run `checkdoc' on the files remaining on the command line."
  (let ((number-of-errors 0))
    (unwind-protect
        (let
            ((jka-compr-inhibit t))
          (when
              (equal
               (car command-line-args-left)
               "--")
            (setq command-line-args-left
                  (cdr command-line-args-left)))
          (unless
              (require 'elisp-mode nil 'no-error)
            (require 'lisp-mode))
          (require 'checkdoc)
          (require 'cl-lib)
          (while command-line-args-left
            (when-let*
                ((source
                  (car command-line-args-left))
                 ((cl-notany (lambda (regexp)
                               (string-match regexp source))
                             checkdoc-batch-ignored))
                 (process-default-directory default-directory))
              (with-temp-buffer
                (insert-file-contents source 'visit)
                (setq buffer-file-name source)
                (setq default-directory process-default-directory)
                (with-demoted-errors "Error in checkdoc: %S"
                  (delay-mode-hooks
                    (emacs-lisp-mode))
                  (setq delayed-mode-hooks nil)
                  (checkdoc-current-buffer t)
                  (with-current-buffer checkdoc-diagnostic-buffer
                    ;; When there are no errors, there are only a few lines in the
                    ;; beginning of the buffer, followed by a single line
                    ;; containing a `checkdoc' stamp.  Remove them and see if
                    ;; buffer has more lines than 1.
                    (let ((inhibit-read-only t))
                      (goto-char (point-min))
                      (when-let* (((looking-at
                                    (rx string-start (group (zero-or-more (or whitespace "\n"))
                                                            (or "\n" line-end))))))
                        (delete-region (match-beginning 1) (match-end 1))))
                    (cl-incf number-of-errors (- (car (buffer-line-statistics))
                                                 1))
                    (princ
                     (buffer-substring-no-properties
                      (point-min)
                      (point-max)))
                    (princ "\n")
                    (kill-buffer)))))
            (setq command-line-args-left (cdr command-line-args-left))))
      (setq command-line-args-left nil)
      (when (< 0 number-of-errors)
        (error "There %s %s checkdoc error%s!"
               (if (= 1 number-of-errors) "is" "are")
               number-of-errors
               (if (= 1 number-of-errors) "" "s"))))))

(provide 'checkdoc-batch)
;;; checkdoc-batch.el ends here
