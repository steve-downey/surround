;;; surround-test.el --- Tests for surround.el -*- lexical-binding: t; -*-

;; SPDX-License-Identifier: GPL-3.0-or-later

;;; Commentary:
;; Tests for deriving Org source languages from major modes.

;;; Code:

(require 'ert)
(require 'surround)

(ert-deftest uuid-surround-src-language-uses-org-mapping ()
  "Use Org's mapping, including when multiple languages name one mode."
  (let ((major-mode-remap-alist nil)
        (language (uuid-surround--src-language 'c++-mode)))
    (should (member language '("C++" "cpp")))
    (should (eq 'c++-mode (org-src-get-lang-mode language)))))

(ert-deftest uuid-surround-src-language-uses-conventional-mode-name ()
  "Derive a language when Org has no explicit mapping."
  (let ((org-src-lang-modes nil))
    (should (equal "python"
                   (uuid-surround--src-language 'python-mode)))))

(ert-deftest uuid-surround-src-language-handles-tree-sitter-mode ()
  "Remove the tree-sitter suffix when deriving a language."
  (let ((org-src-lang-modes nil))
    (should (equal "python"
                   (uuid-surround--src-language 'python-ts-mode)))))

(ert-deftest uuid-surround-src-language-honors-major-mode-remapping ()
  "Use Org's language when it resolves through a major-mode remapping."
  (let ((major-mode-remap-alist '((c++-mode . c++-ts-mode))))
    ;; Org versions before 9.7 did not apply `major-mode-remap-alist' here.
    (skip-unless (eq 'c++-ts-mode (org-src-get-lang-mode "C++")))
    (let ((language (uuid-surround--src-language 'c++-ts-mode)))
      (should (member language '("C++" "cpp")))
      (should (eq 'c++-ts-mode (org-src-get-lang-mode language))))))

(ert-deftest uuid-surround-src-language-rejects-unconventional-mode-name ()
  "Report a mode name from which no Org language can be derived."
  (let ((org-src-lang-modes nil))
    (should-error
     (uuid-surround--src-language 'uuid-surround-test-major)
     :type 'user-error)))

(provide 'surround-test)

;;; surround-test.el ends here
