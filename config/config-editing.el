;;; config-editing.el --- Editing                    -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Julien Fantin

;; Author: Julien Fantin(require 'use-config) <julienfantin@gmail.com>
;; Keywords: editing

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'use-config)
(require 'config-path)

;; * Defaults

(setq-default fill-column 80)

(use-package delsel :init (delete-selection-mode 1))

(use-package newcomment
  :defer t
  :config
  (setq-default comment-auto-fill-only-comments t))


;; * Packages

(use-package multiple-cursors
  :ensure t
  :defer t
  :init
  (defvar mc/list-file (user-var-file ".mc-lists.el")))

(use-package auto-highlight-symbol
  :ensure t
  :config
  (validate-setq ahs-case-fold-search nil)
  ;; Fix -> symbols in clojure
  (setq ahs-include "^[0-9A-Za-z/_>.,:;*+=&%|$#@!^?-]+$")
  (validate-setq ahs-default-range 'ahs-range-whole-buffer)
  (validate-setq ahs-idle-interval -1.0)
  (validate-setq ahs-inhibit-face-list '())
  (add-to-list 'ahs-plugin-bod-modes 'clojure-mode)
  (add-to-list 'ahs-plugin-bod-modes 'clojurescript-mode)
  (add-to-list 'ahs-plugin-bod-modes 'clojurec-mode))

(use-package iedit :ensure t :defer t)

(use-package undo-tree
  :ensure t
  :defer t
  :commands (undo-tree)
  :init (after-init #'global-undo-tree-mode)
  :config
  (validate-setq
   undo-tree-auto-save-history t
   undo-tree-history-directory-alist
   `(("" . ,(user-var-directory ".undo-tree/")))))


;; * Builtins

(use-package simple
  :config
  (setq kill-ring-max most-positive-fixnum))


;; * Commands

;;;###autoload
(defun -backward-kill-word-or-region ()
  "Kill backward word or region if active."
  (interactive)
  (if (region-active-p)
      (if (bound-and-true-p paredit-mode)
          (call-interactively 'paredit-kill-region)
        (call-interactively 'kill-region))
    (if (bound-and-true-p paredit-mode)
        (call-interactively 'paredit-backward-kill-word)
      (call-interactively 'backward-kill-word))))

;;;###autoload
(defun -cleanup ()
  "Indent, untabify and cleanup whitespace in region or buffer."
  (interactive)
  (save-excursion
    (unless (use-region-p)
      (goto-char (point-min))
      (push-mark)
      (goto-char (point-max)))
    (untabify (region-beginning) (region-end))
    (indent-region (region-beginning) (region-end))
    (save-restriction
      (narrow-to-region (region-beginning) (region-end))
      (whitespace-cleanup)))
  (message (format "%s cleaned!" (buffer-name))))

;;;###autoload
(defun -unfill-paragraph (&optional region)
  "Turn a multi-line paragraph into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

(provide 'config-editing)
;;; config-editing.el ends here
