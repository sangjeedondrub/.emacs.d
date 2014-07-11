;;; emacs-swagger-kit --- Elisp goodness!
;;; Commentary:
;;; Code:
;;
;;; * Bootstap

(require 'cl-lib)

(progn
  ;; Debug on error when loading
  (setq debug-on-error t)
  (add-hook 'after-init-hook #'(lambda () (toggle-debug-on-error -1))))

;;; ** Elpa & use-package

(progn
  (setq package-archives
        '(("org" . "http://orgmode.org/elpa/")
          ("melpa" . "http://melpa.milkbox.net/packages/")
          ("melpa-stable" . "http://melpa-stable.milkbox.net/packages/")
          ("gnu" . "http://elpa.gnu.org/packages/")))

  ;; (setq package-pinned-packages
  ;;       '((cider . "melpa-stable")
  ;;         (company . "melpa-stable")))

  (when (require 'package)
    (package-initialize)
    (unless package-archive-contents
      (package-refresh-contents))
    (unless (package-installed-p 'org-plus-contrib)
      (package-install 'org-plus-contrib))))

(progn
  (unless (package-installed-p 'use-package)
    (package-install 'use-package))
  (require 'use-package))

;;; ** Config helpers

(defmacro after (mode &rest body)
  "`eval-after-load' `MODE', wrapping `BODY' in `progn'."
  (declare (indent defun))
  (let ((s (if (symbolp mode)
               (symbol-name mode)
             mode)))
    `(eval-after-load ,(symbol-name mode)
       (quote (progn ,@body)))))

(ignore-errors
  (use-package private))

;;; * Defaults

(progn
  (setq-default default-truncate-lines nil)
  (setq-default truncate-lines nil)
  (setq-default truncate-partial-width-windows nil)
  (setq-default confirm-nonexistent-file-or-buffer nil)
  (setq-default gc-cons-threshold (* 8 1024 1024))
  (setq-default completion-styles '(basic partial-completion substring))
  (setq-default completion-cycle-threshold t)
  (setq-default enable-recursive-minibuffers t))

;;; ** Paths

(defun temp-file (name)
  "Return a temporary file with `NAME'."
  (expand-file-name name temporary-file-directory))

(defun user-file (name)
  "Return a file with `NAME' in `user-emacs-directory'."
  (expand-file-name name user-emacs-directory))

(progn
  (setq user-emacs-directory
        (file-name-directory
         (or load-file-name
             buffer-file-name)))
  (setq custom-file (user-file "custom.el")))

(use-package exec-path-from-shell
  :ensure exec-path-from-shell
  :init (exec-path-from-shell-initialize))

;;; ** Fonts

(defvar global-text-height-offset 0)

(defvar monospaced-fonts
  '(("Consolas" . 120)
    ("DejaVu Sans Mono" . 130)
    ("Ubuntu Mono" . 140)
    ("Source Code Pro" . 120)
    ("Inconsolata" . 140)
    ("Menlo-12" . 120)))

(defvar variable-fonts
  '(("DejaVu Serif" . 190)))

(defun set-preferred-font (height-offset)
  (let* ((mono-font (cl-find-if
                     (lambda (font)
                       (find-font (font-spec :name (car font))))
                     monospaced-fonts))
         (var-font (cl-find-if
                    (lambda (font)
                      (find-font (font-spec :name (car font))))
                    variable-fonts)))
    (set-face-attribute 'default nil :family (car mono-font))
    (set-face-attribute 'default nil :height (+ (cdr mono-font) height-offset))
    (set-face-attribute 'variable-pitch nil :family (car var-font))
    (set-face-attribute 'variable-pitch nil :height (+ (cdr var-font) height-offset))))

(set-preferred-font 0)

(defun global-text-height-increase ()
  (interactive)
  (set-preferred-font
   (incf global-text-height-offset 10)))

(defun global-text-height-decrease ()
  (interactive)
  (set-preferred-font
   (incf global-text-height-offset -10)))

(bind-key "C-x C-+" 'global-text-height-increase)
(bind-key "C-x C--" 'global-text-height-decrease)

;;; ** Prose-mode

(defvar prose-mode-map (make-sparse-keymap))

(defvar prose-mode-line-spacing 6)

(easy-mmode-define-minor-mode
 prose-mode
 "A mode for editing and reading prose."
 t
 "Prose"
 prose-mode-map

 ;; Line spacing
 (set (make-local-variable 'line-spacing)
      (if prose-mode prose-mode-line-spacing line-spacing))

 (after automargin
   (unless (bound-and-true-p automargin-mode)
     (automargin-mode 1)))

 (variable-pitch-mode prose-mode)
 (visual-line-mode prose-mode)

 (set-preferred-font 0))

(use-package adaptive-wrap
  :ensure adaptive-wrap
  :defer t
  :init (add-hook 'prose-mode-hook 'adaptive-wrap-prefix-mode))

;;; ** GUI

(progn
  (setq initial-scratch-message "")
  (setq inhibit-startup-message t)
  (when window-system
    ;; (add-hook 'after-init-hook
    ;;           #'(lambda ()
    ;;               (modify-all-frames-parameters
    ;;                '((fullscreen . maximized)))))
    (tool-bar-mode -1)
    (scroll-bar-mode -1)
    (setq ns-use-native-fullscreen nil
          use-file-dialog nil
          use-dialog-box nil)))

;;; ** UI

(progn
  (setq-default cursor-in-non-selected-windows nil)
  (setq-default cursor-type 'bar)
  (setq echo-keystrokes 0.01)
  (setq mouse-wheel-progressive-speed nil
        mouse-wheel-scroll-amount '(0.01 ((shift) . 1) ((control) . nil)))
  (setq ring-bell-function #'(lambda ()))
  (setq save-interprogram-paste-before-kill t)
  (fset 'yes-or-no-p 'y-or-n-p))

(use-package diminish
  :ensure diminish)

(use-package hl-line
  :defer t
  :pre-load
  (progn
    (defvar hl-line-hooks
      '(dired-mode-hook))
    (defun hl-line-turn-on ()
      (when (not (bound-and-true-p hl-line-mode))
        (hl-line-mode 1))))
  :init
  (progn
    (dolist (hook hl-line-hooks)
      (add-hook hook 'hl-line-turn-on))))

(use-package number-font-lock-mode
  :ensure number-font-lock-mode
  :defer t
  :init (add-hook 'prog-mode-hook 'number-font-lock-mode))

(use-package automargin
  :ensure automargin
  :commands (automargin-mode)
  :init (add-hook 'after-init-hook 'automargin-mode)
  :config
  (progn
    (setq-default automargin-target-width 150)
    (add-hook 'window-configuration-change-hook 'automargin-function)
    (add-hook 'minibuffer-setup-hook 'automargin-function)))

;;; ** Theme

(defvar dark-themes
  '(gruvbox soft-charcoal minimal stekene-dark zonokai tomorrow))

(defvar light-themes
  '(espresso flatui hemisu-light minimal-light ritchie stekene-light tomorrow-bright))

(progn
  (setq-default
   custom-theme-directory
   (expand-file-name "themes/" user-emacs-directory ))
  (load-theme 'fiatui t))

(use-package powerline
  :ensure powerline
  :init (powerline-nano-theme))

(use-package rainbow-mode
  :ensure rainbow-mode
  :defer t
  :diminish (rainbow-mode "")
  :init (add-hook 'emacs-lisp-mode-hook 'rainbow-mode))

;;; ** Dired

(use-package dired
  :config
  (progn
    (setq dired-auto-revert-buffer t)))

;;; ** Minibuffer completion

(use-package smex
  :disabled t
  :ensure smex
  :bind (("M-x" . smex)
         ("C-x C-m" . smex-major-mode-commands))
  :init (smex-initialize))

(use-package ido
  :disabled t
  :config
  (progn
    (setq
     ;; Like recentf for buffers
     ido-use-virtual-buffers t
     ;; Disable auto-entering matching directory
     ido-auto-merge-work-directories-length -1
     ;; You wish...
     ido-everywhere t
     ido-enable-flex-matching t
     ;; Flat look is easier to scan
     ido-max-window-height 1
     ido-enable-tramp-completion t
     ;; Like mtime sort for dirs
     ido-enable-last-directory-history t
     ido-enable-prefix nil
     ido-create-new-buffer 'always
     ido-use-filename-at-point 'guess
     ido-max-prospects 10
     ido-confirm-unique-completion nil
     ido-cannot-complete-command #'(lambda () (interactive)))

    (use-package ido-complete-space-or-hyphen
      :ensure ido-complete-space-or-hyphen)

    (use-package ido-sort-mtime
      :ensure ido-sort-mtime
      :init (ido-sort-mtime-mode 1))

    (use-package ido-ubitquitous
      :ensure ido-ubiquitous
      :init (ido-ubiquitous-mode 1))

    (use-package flx-ido
      :ensure flx-ido
      :init (flx-ido-mode 1))))

(use-package helm-config
  :ensure helm
  :pre-load (defvar helm-command-prefix-key "C-h")
  :bind (("M-x" . helm-M-x)
         ("C-x b" . helm-mini)
         ("C-x C-f" . helm-find-files))
  :config
  (progn
    (bind-key "a" 'helm-apropos helm-command-map)
    (bind-key "o" 'helm-occur helm-command-map)
    (custom-set-faces
     '(helm-source-header ((t :inherit mode-line)))
     '(helm-selection ((t :inherit hl-line)))
     '(helm-visible-mark ((t :inherit region))))

    (setq helm-yank-symbol-first t)

    (use-package helm-adapt
      :init (helm-adaptive-mode 1))

    (use-package helm-command
      :config
      (progn
        (setq helm-M-x-always-save-history t)
        (use-package helm-swoop
          :ensure helm-swoop
          :defer t
          :init
          (progn
            (bind-key "s" 'helm-swoop helm-command-map)
            (bind-key "C-s" 'helm-multi-swoop-all helm-command-map)))

        (use-package helm-descbinds
          :ensure helm-descbinds
          :defer t
          :init (bind-key "b" 'helm-descbinds helm-command-map))))

    (use-package helm-mode
      :diminish ""
      :init (helm-mode 1)
      :config
      (progn
        (bind-key "DEL" 'my-helm-ff-up helm-read-file-map)
        ;; Complete immendiately on TAB when finding files
        (bind-key "TAB" 'helm-execute-persistent-action helm-map)
        (bind-key "C-z" 'helm-select-action helm-map)
        (setq
         helm-idle-delay 0.01
         helm-input-idle-delay 0.01
         helm-split-window-default-side 'other
         helm-split-window-in-side-p t
         helm-buffer-details-flag nil
         helm-ff-file-name-history-use-recentf t
         helm-ff-auto-update-initial-value nil
         helm-ff-skip-boring-files t
         helm-M-x-requires-pattern 0
         helm-buffers-fuzzy-matching t)

        (add-to-list 'helm-boring-file-regexp-list "\\.DS_Store$")
        (add-to-list 'helm-boring-file-regexp-list "\\.git$")
        (add-to-list 'helm-boring-file-regexp-list "\\.$")

        (use-package helm-eshell
          :defer t
          :init
          (add-hook 'eshell-mode-hook
                    #'(lambda ()
                        (define-key eshell-mode-map (kbd "M-l")  'helm-eshell-history))))
        (defun my-helm-ff-up ()
          "Delete backward or go \"down\" [sic] one level when in
          folder root."
          (interactive)
          (if (looking-back "/")
              (call-interactively 'helm-find-files-up-one-level)
            (delete-char -1)))))))

;;; ** Keys

(progn
  (setq ns-command-modifier 'control
        ns-control-modifier 'meta
        ns-option-modifier 'super))

(use-package sequential-command
  :ensure sequential-command
  :defer t
  :defines sequential-lispy-indent
  :commands sequential-lispy-indent
  :init
  (add-hook
   'prog-mode-hook
   #'(lambda ()
       (local-set-key (kbd "TAB") 'sequential-lispy-indent)))
  :config
  (progn
    (defun paredit-indent-command ()
      (interactive)
      (save-excursion
        (paredit-indent-sexps)))
    (define-sequential-command sequential-lispy-indent
      indent-for-tab-command
      paredit-indent-command
      esk/cleanup)))

;;; ** Files

(use-package files
  :init
  (progn
    (setq backup-by-copying t
          backup-directory-alist `((".*" . ,temporary-file-directory))
          auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))))

(use-package autorevert
  :idle (global-auto-revert-mode 1))

;;; * Ineractive commands

(use-package commands
  :demand t
  :bind (("C-w" . esk/backward-kill-word)
         ("C-c \\" . esk/window-split-toggle))
  :commands esk/cleanup
  :load-path "./lib")


(use-package free-keys
  :ensure free-keys
  :defer t)

;;; * Projects

(use-package projectile
  :ensure projectile
  :idle (projectile-global-mode 1)
  :config
  (progn
    (setq projectile-completion-system 'helm-comp-read
          projectile-use-git-grep t
          projectile-remember-window-configs t
          projectile-mode-line-lighter " P"
          projectile-enable-caching nil)

    (add-to-list 'projectile-globally-ignored-files ".DS_Store")
    (add-to-list 'projectile-globally-ignored-directories "elpa")
    (add-to-list 'projectile-project-root-files-bottom-up "project.clj")

    (defadvice projectile-replace
        (before projectile-save-all-and-replace activate)
      (save-some-buffers t))

    (use-package helm-projectile
      :ensure helm-projectile
      :defer t
      :init
      (after helm-misc
        (bind-key "p" 'helm-projectile helm-command-map)))))

;;;; ** Version control

(use-package magit
  :ensure magit
  :bind ("C-c g" . magit-status)
  :config
  (progn
    (setq magit-emacsclient-executable "/usr/local/Cellar/emacs/HEAD/bin/emacsclient")
    (setq magit-save-some-buffers 'dontask)

    ;; Only one window when showing magit, then back!
    (defadvice magit-status (around magit-fullscreen activate)
      (window-configuration-to-register :magit-fullscreen)
      ad-do-it
      (delete-other-windows))

    (defadvice magit-mode-quit-window (around magit-restore-screen activate)
      (let ((magit-status? (string-match-p "\\magit:.+" (buffer-name))))
        ad-do-it
        (when magit-status?
          (jump-to-register :magit-fullscreen))))))

(use-package git-timemachine
  :ensure git-timemachine
  :defer t)

(use-package ediff
  :defer t
  :config
  (setq
   ;; avoid the crazy multi-frames setup
   ediff-window-setup-function 'ediff-setup-windows-plain
   ;; ignore whitespace
   ediff-diff-options "-w"
   ;; counter-intuitve naming here, but windows should be side-by-side...
   ediff-split-window-function 'split-window-horizontally))

(use-package diff-hl
  :ensure diff-hl
  :defer t
  :init (add-hook 'prog-mode-hook 'diff-hl-mode)
  :config
  (progn
    (after git-commit-mode
      (defadvice git-commit-commit (after git-commit-commit-after activate)
        (dolist (buffer (buffer-list))
          (with-current-buffer buffer
            (when diff-hl-mode
              (diff-hl-update))))))))

;; ;;; * Editing

(progn
  (pending-delete-mode 1)
  (setq-default indent-tabs-mode nil))

(use-package goto-chg
  :ensure goto-chg
  :defer t
  :init
  (progn
    (bind-key "C-." 'goto-last-change prog-mode-map)
    (bind-key "C-M-." 'goto-last-change-reverse prog-mode-map)))

(use-package undo-tree
  :ensure undo-tree
  :defer t
  :diminish ""
  :init (add-hook 'prog-mode-hook 'undo-tree-mode)
  :config
  (progn
    (setq
     undo-tree-visualizer-timestamps nil
     undo-tree-visualizer-diff nil
     undo-tree-auto-save-history t
     undo-tree-history-directory-alist `((".+" . ,(file-name-as-directory
                                                   (temp-file
                                                    ".undo-tree-history")))))))

(use-package multiple-cursors
  :ensure multiple-cursors
  :defer t
  :init
  (progn
    (bind-key "C->" 'mc/mark-next-like-this prog-mode-map)
    (bind-key "C-<" 'mc/mark-previous-like-this prog-mode-map)
    (bind-key "C-c C-<" 'mc/mark-all-like-this prog-mode-map)))

(use-package expand-region
  :ensure expand-region
  :bind (("C-+" . er/expand-region)
         ("C-=" . er/contract-region)))


;; ;;; * Markdown

(use-package markdown-mode
  :ensure markdown-mode
  :mode "\\.md\\'")

;; ;;; * Org

(use-package org-capture
  :bind ("C-c c" . org-capture)
  :config
  (progn
    (setq org-reverse-note-order t
          org-capture-templates
          '(("d" "Dev dump"
             entry (file "~/org/dev.org")
             "* %?\n  %i\n %a"
             :kill-buffer  t)
            ("j" "Journal"
             entry (file "~/org/journal.org")
             "* %U\n %?i\n %a"
             :kill-buffer t)))))

;; ;;; * Navigation
;; ;;; ** Buffer

(use-package god-mode
  :ensure god-mode
  :init (add-hook 'prog-mode-hook 'god-local-mode)
  :bind (("<escape>" . god-local-mode))
  :config
  (progn
    (after eshell
      (add-to-list 'god-exempt-major-modes 'eshell-mode))
    (after cider-repl
      (add-to-list 'god-exempt-major-modes 'cider-repl-mode))

    (global-set-key (kbd "C-x C-1") 'delete-other-windows)
    (global-set-key (kbd "C-x C-2") 'split-window-below)
    (global-set-key (kbd "C-x C-3") 'split-window-right)
    (global-set-key (kbd "C-x C-0") 'delete-window)

    (define-key god-local-mode-map (kbd "z") 'repeat)
    (define-key god-local-mode-map (kbd ".") 'repeat)

    (defun god-enabled-p ()
      (or god-local-mode buffer-read-only))

    (defun god-update-cursor ()
      (setq cursor-type (if (god-enabled-p) 'box 'bar)))

    (defun god-update-auto-indent ()
      (after auto-indent-mode
        (auto-indent-mode (not (god-enabled-p)))))

    (defun god-update-hl-line ()
      (hl-line-mode (god-enabled-p)))

    (add-hook 'god-mode-enabled-hook 'god-update-auto-indent)
    (add-hook 'god-mode-disabled-hook 'god-update-auto-indent)
    (add-hook 'god-mode-enabled-hook 'god-update-hl-line)
    (add-hook 'god-mode-disabled-hook 'god-update-hl-line)
    (add-hook 'god-mode-enabled-hook 'god-update-cursor)
    (add-hook 'god-mode-disabled-hook 'god-update-cursor)))

(use-package imenu
  :defer t
  :config
  (progn
    (add-to-list 'imenu-generic-expression '("*" "^;;; \\(.+\\)$" 1) t)
    (setq imenu-auto-rescan t)))

(use-package imenu-anywhere
  :ensure imenu-anywhere
  :defer t
  :commands helm-imenu-anywhere
  :init
  (after helm-mode
    (bind-key "C-i" 'helm-imenu-anywhere helm-command-map)))

(use-package simple
  :demand t
  :config
  (progn
    (setq mark-ring-max 32
          global-mark-ring-max 32)
    (after helm-command
      (bind-key "SPC" 'helm-all-mark-rings helm-command-map))))

(use-package ace-jump-mode
  :ensure ace-jump-mode
  :bind (("C-x j" . ace-jump-mode)
         ("C-c j" . ace-jump-char-mode)
         ("C-c C-j" . ace-jump-mode-pop-mark))
  :config
  (progn
    (ace-jump-mode-enable-mark-sync)))

(use-package iedit
  :ensure iedit
  :bind ("C-;" . iedit-mode))

(use-package highlight-symbol
  :ensure highlight-symbol
  :defer t
  :diminish ""
  :init
  (progn
    (add-hook 'prog-mode-hook 'highlight-symbol-mode)
    (add-hook 'prog-mode-hook 'highlight-symbol-nav-mode))
  :config
  (progn
    (setq highlight-symbol-on-navigation-p t
          highlight-symbol-idle-delay 1)
    (bind-key "C-%" 'highlight-symbol-query-replace highlight-symbol-nav-mode-map)))

(use-package outline
  :defer t
  :diminish (outline-minor-mode "")
  :init (add-hook 'prog-mode-hook 'outline-minor-mode)
  :config
  (progn
    (setq outline-minor-mode-prefix "\C-c \C-o")
    (bind-key "M-P" 'outline-previous-heading outline-minor-mode-map)
    (bind-key "M-N" 'outline-next-heading outline-minor-mode-map)))

(use-package saveplace
  :init
  (progn
    (setq-default save-place t)
    (setq  save-place-file (temp-file "places"))))

(use-package savehist
  :idle (savehist-mode 1))

(use-package recentf
  :idle (recentf-mode 1)
  :config
  (progn
    (setq recentf-max-saved-items 100
          recentf-max-menu-items 100)))

;;; ** Windows & frames

(bind-key "s-h" 'bury-buffer)

;; ;; Scroll buffers in-window
(bind-key "s-b" 'previous-buffer)
(bind-key "s-n" 'next-buffer)

;; ;; navigate windows
 (bind-key "s-;" 'previous-multiframe-window)
 (bind-key "s-'" 'next-multiframe-window)

 (setq split-height-threshold 10)

(use-package zygospore
  :ensure zygospore
  :bind (("C-x 1" . zygospore-toggle-delete-other-windows)))

(use-package dedicated
  :ensure dedicated
  :bind ("C-M-\\" . dedicated-mode))

(use-package popwin
  :ensure popwin
  :defer t
  :commands (popwin-mode)
  :init
  (add-hook 'after-init-hook 'popwin-mode)
  :config
  (progn
    (bind-key "C-z" popwin:keymap)
    (setq popwin:popup-window-height 20)
    (push '("*cider-error*") popwin:special-display-config)
    (push '("*grep*" :stick t) popwin:special-display-config)
    (push '("^\*helm .+\*$" :height 60 :regexp t) popwin:special-display-config)
    (push '("^\*helm-.+\*$" :height 60 :regexp t) popwin:special-display-config)))

(use-package perspective
  :ensure perspective
  :defer t
  :init (add-hook 'after-init-hook 'persp-mode)
  :config
  (progn
    (setq persp-initial-frame-name "emacs")
    (defun persp-next ()
      (interactive)
      (when (< (+ 1 (persp-curr-position)) (length (persp-all-names)))
        (persp-switch (nth (1+ (persp-curr-position)) (persp-all-names)))))))

(use-package windmove
  :bind (("S-C-<left>"  . shrink-window-horizontally)
         ("S-C-<right>" . enlarge-window-horizontally)
         ("S-C-<down>"  . shrink-window)
         ("S-C-<up>"    . enlarge-window))
  :init (windmove-default-keybindings))

(use-package buffer-move
  :ensure buffer-move
  :bind (("<M-S-down>" . buf-move-down)
         ("<M-S-left>" . buf-move-left)
         ("<M-S-up>" . buf-move-up)
         ("<M-S-right>" . buf-move-right)))

(use-package win-switch
  :ensure win-switch
  :bind ("C-x o" . win-switch-mode))

(progn
  (defadvice split-window (after move-point-to-new-window activate)
    "Move to the newly created window after a split."
    (other-window 1)
    (next-buffer)))

;;; * Search and replace
;;; ** Buffer
;;; ** Directory

;;; * Programming

(use-package prog-mode
  :defer t
  :config
  (progn
    (use-package eldoc
      :diminish ""
      :defer t
      :init (add-hook 'prog-mode-hook 'eldoc-mode))

    (use-package hl-todo
      :ensure hl-todo
      :defer t
      :init (add-hook 'prog-mode-hook 'hl-todo-mode))

    (use-package rainbow-delimiters
      :ensure rainbow-delimiters
      :defer t
      :init (add-hook 'prog-mode-hook 'rainbow-delimiters-mode))))

;;; ** Syntax checking

(use-package flycheck
  :ensure flycheck
  :defer t
  :init (add-hook 'prog-mode-hook 'flycheck-mode)
  :config
  (progn
    (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc))
    (setq flycheck-mode-line-lighter " *")
    (use-package flycheck-color-mode-line
      :ensure flycheck-color-mode-line
      :init (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode))))

;;; ** Indentation

(use-package auto-indent-mode
  :ensure auto-indent-mode
  :defer t
  :diminish ""
  :init (add-hook 'prog-mode-hook 'auto-indent-mode t)
  :config
  (progn
    (setq auto-indent-current-pairs t
          kill-whole-line t)

    (add-hook 'auto-indent-mode-hook
              #'(lambda ()
                  (when (bound-and-true-p electric-indent-mode)
                    (electric-indent-mode -1))))))

;;; ** Structured editing

(use-package paren
  :defer t
  :init (add-hook 'prog-mode-hook 'show-paren-mode)
  :config
  (progn
    (add-hook 'activate-mark-hook #'(lambda () (show-paren-mode -1)))
    (add-hook 'deactivate-mark-hook #'(lambda () (show-paren-mode 1)))
    (setq show-paren-delay 0.02)))

(use-package paredit
  :ensure paredit
  :defer t
  :diminish ""
  :init (add-hook 'prog-mode-hook 'paredit-mode)
  :config
  (progn
    (defun paredit-wrap-round-from-behind ()
      (interactive)
      (forward-sexp -1)
      (paredit-wrap-round)
      (insert " ")
      (forward-char -1))

    (defun paredit-wrap-square-from-behind ()
      (interactive)
      (forward-sexp -1)
      (paredit-wrap-square))

    (defun paredit-wrap-curly-from-behind ()
      (interactive)
      (forward-sexp -1)
      (paredit-wrap-curly))

    ;; From emacs-live
    (defun esk-paredit-forward ()
      (interactive)
      (if (and (not (paredit-in-string-p))
               (save-excursion
                 (ignore-errors
                   (forward-sexp)
                   (forward-sexp)
                   t)))
          (progn
            (forward-sexp)
            (forward-sexp)
            (backward-sexp))
        (paredit-forward)))

    (bind-key "C-M-f" 'esk-paredit-forward paredit-mode-map)

    (bind-key "M-(" 'paredit-wrap-round paredit-mode-map)
    (bind-key "M-)" 'paredit-wrap-round-from-behind paredit-mode-map)
    (bind-key "M-[" 'paredit-wrap-square paredit-mode-map)
    (bind-key "M-]" 'paredit-wrap-square-from-behind paredit-mode-map)
    (bind-key "M-{" 'paredit-wrap-curly paredit-mode-map)
    (bind-key "M-}" 'paredit-wrap-curly-from-behind paredit-mode-map)

    (defun minibuffer-paredit-mode-maybe ()
      (if (eq this-command 'eval-expression)
          (paredit-mode 1)))
    (add-hook 'minibuffer-setup-hook 'minibuffer-paredit-mode-maybe)))

;;; ** completion

(use-package company
  :ensure company
  :defer t
  :diminish ""
  :init (add-hook 'prog-mode-hook 'company-mode)
  :config
  (progn
    (setq-default company-backends
                  '((company-dabbrev-code company-capf company-keywords)
                    company-files
                    company-dabbrev))

    (setq company-require-match t
          company-auto-complete t
          company-idle-delay 0
          company-tooltip-limit 10
          company-minimum-prefix-length 2)
    (bind-key "<tab>" 'company-complete-selection company-active-map)))

(use-package yasnippet
  :ensure yasnippet
  :disabled t
  :init
  (progn
    (add-hook
     'prog-mode-hook
     (lambda ()
       (set (make-local-variable 'company-backends)
            '((company-dabbrev-code company-yasnippet)))))
    (add-to-list 'company-backends 'company-yasnippet t))
  :config
  (progn
    (add-to-list 'yas-snippet-dirs (user-file "snippets"))
    (yas-reload-all)))

;;; ** Whitespace

(use-package ws-butler
  :ensure ws-butler
  :defer t
  :init
  (progn
    (add-hook 'prog-mode-hook 'ws-butler-mode)
    (add-hook 'prog-mode-hook
              #'(lambda ()
                  (setq show-trailing-whitespace t)))))

;;; ** Clojure

(use-package clojure-mode
  :ensure clojure-mode
  :defer t
  :config
  (progn
    (progn
      (add-hook 'clojure-mode-hook 'subword-mode)
      (put-clojure-indent 'defmulti 'defun)
      (put-clojure-indent 'defmethod 'defun)
      (put-clojure-indent 'defroutes 'defun))

    (use-package cider
      :ensure cider
      :defer t
      :config
      (progn
        (add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
        (add-hook 'cider-repl-mode-hook 'cider-turn-on-eldoc-mode)
        (add-hook 'cider-repl-mode-hook 'paredit-mode)
        (bind-key "C-c C-t" 'cider-test-jump clojure-mode-map)

        (setq cider-prompt-save-file-on-load nil
              nrepl-hide-special-buffers nil
              cider-repl-print-length 400
              cider-repl-pop-to-buffer-on-connect nil
              cider-repl-history-file "~/.emacs.d/nrepl-history"
              ;;cider-repl-use-clojure-font-lock t
              ;;cider-repl-use-pretty-printing t
              )

        (use-package cider-repl
          :defer t
          :config (add-hook 'cider-repl-mode-hook 'company-mode))

        (use-package pulse
          :init
          (progn
            (defadvice cider-eval-last-sexp (after cider-flash-last activate)
              (pulse-momentary-highlight-region (save-excursion (backward-sexp) (point)) (point)))
            (defadvice cider-eval-defun-at-point (after cider-flash-at activate)
              (apply #'pulse-momentary-highlight-region (cider--region-for-defun-at-point)))))))

    (use-package clj-refactor
      :ensure clj-refactor
      :defer t
      :init (add-hook 'clojure-mode-hook 'clj-refactor-mode)
      :config
      (progn
        (cljr-add-keybindings-with-prefix "C-c C-m")
        (after cider
          (bind-key "C->" 'cljr-thread cider-mode-map)
          (bind-key "C-<" 'cljr-unwind cider-mode-map))
        (after cider-repl
          (bind-key "C->" 'cljr-thread-last-all cider-repl-mode-map)
          (bind-key "C-<" 'cljr-thread-first-all cider-repl-mode-map))))

    (use-package slamhound
      :ensure slamhound
      :defer t
      :init (bind-key "C-c s" 'slamhound clojure-mode-map))

    (use-package typed-clojure-mode
      :ensure typed-clojure-mode
      :disabled t
      :defer t
      :init (add-hook 'clojure-mode-hook 'typed-clojure-mode)
      :config
      (progn
        (defun typed-clojure-font-lock ()
          (font-lock-add-keywords nil
                                  '(("(\\(def\\(record\\|protocol\\)>\\)\\s-+\\(\\w+\\)"
                                     (1 font-lock-keyword-face)
                                     (3 font-lock-function-name-face)))))
        (add-hook 'clojure-mode-hook 'typed-clojure-font-lock)))

    (use-package clojure-cheatsheet
      :ensure clojure-cheatsheet
      :defer t
      :init
      (after helm
        (bind-key "C-c C-c" 'clojure-cheatsheet helm-command-map)))

    ;; Linting
    (use-package kibit-mode
      :ensure kibit-mode
      :defer t
      :commands (clojure-kibit)
      :pre-load
      (progn
        (defun clojure-kibit-enable ()
          (interactive)
          (flycheck-mode 1)
          (add-hook 'clojure-mode-hook 'flycheck-mode))

        (defun clojure-kibit-disable ()
          (interactive)
          (flycheck-mode -1)
          (remove-hook 'clojure-mode-hook 'flycheck-mode))))

    ;; Eastwood, too noisy for now...
    ;; (after cider
    ;;   (defvar eastwood-add-linters
    ;;     (vector
    ;;      ;; :keyword-typos
    ;;      ;;:unused-namespaces
    ;;      :unused-fn-args)
    ;;     "Really doesn't make sense to use a vector here,
    ;;       but saves the formatting for now...")

    ;;   (flycheck-define-checker eastwood
    ;;     "A Clojure lint tool."
    ;;     :command
    ;;     ("lein" "eastwood"
    ;;      (eval
    ;;       (format "{:namespaces [%s] :add-linters []}" (cider-find-ns) eastwood-add-linters)))
    ;;     :error-patterns
    ;;     ((error
    ;;       bol
    ;;       "{:linter" (one-or-more not-newline) ",\n"
    ;;       " :msg" (or (zero-or-one (syntax whitespace)) (zero-or-one "\n")) (message) ",\n"
    ;;       " :line " line ",\n"
    ;;       " :column " column "}" line-end))
    ;;     :modes clojure-mode)
    ;;   (add-to-list 'flycheck-checkers 'eastwood))
    ))

;;; ** Elisp

(defvar elisp-hooks '(emacs-lisp-mode-hook ielm-mode-hook))

(use-package lisp-mode
  :defer t
  :config
  (progn
    (bind-key "C-c C-k" 'eval-buffer emacs-lisp-mode-map)

    (dolist (h elisp-hooks)
      (add-hook h 'subword-mode))

    (use-package elisp-slime-nav
      :ensure elisp-slime-nav
      :defer t
      :diminish ""
      :config
      (dolist (hook elisp-hooks)
        (add-hook hook 'turn-on-elisp-slime-nav-mode)))))

;;; * Eshell

(use-package eshell
  :defer t
  :config
  (progn
    ;; Scrolling
    (setq eshell-scroll-to-bottom-on-output t
          eshell-scroll-show-maximum-output t)

    (use-package esh-mode
      :defer t
      :config
      (progn
        (defun eshell/cds ()
          (eshell/cd (or (locate-dominating-file default-directory "src")
                         (locate-dominating-file default-directory ".git"))))

        (defun eshell/clear ()
          (interactive)
          (let ((inhibit-read-only t))
            (delete-region (point-min) (point-max)))
          (eshell-send-input))

        (add-hook 'eshell-mode-hook
                  #'(lambda ()
                      (bind-key "C-l" 'eshell/clear eshell-mode-map)))))

    (use-package em-term
      :defer t
      :config
      (setq eshell-visual-commands
            (append '("tmux" "screen" "ssh") eshell-visual-commands)))

    (use-package em-hist
      :defer t
      :config
      (setq eshell-hist-ignoredups t))))

(use-package multi-eshell
  :ensure multi-eshell
  :bind (("C-c s e" . multi-eshell)
         ("C-c s n" . multi-eshell-go-back))
  :config
  (setq multi-eshell-shell-function '(eshell)))

;;; * Org Mode

(use-package org
  :defer t
  :config
  (progn
    (use-package org-clock
      :config
      (setq org-clock-idle-time 15
            org-clock-in-resume t
            org-clock-persist t
            org-clock-persist-query-resume nil
            org-clock-clocked-in-display 'both))))

(use-package erc
  :defer t
  :config
  (progn
    ;; Joining
    (setq erc-autojoin-timing 'ident)
    ;; Tracking
    (setq erc-track-exclude-types '("JOIN" "NICK" "PART" "QUIT"))
    ;; Filling chan buffers
    (setq erc-fill-function 'erc-fill-static
          erc-fill-static-center 20)

    (use-package erc-hl-nicks
      :ensure erc-hl-nicks
      :init (add-hook 'erc-mode-hook 'erc-hl-nicks-mode))))

(use-package hardhat
  :ensure hardhat
  :idle (global-hardhat-mode 1))

(provide 'init)
;; ;;; init.el ends here
