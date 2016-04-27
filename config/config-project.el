;;; config-project.el --- Project management         -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Julien Fantin

;; Author: Julien Fantin(require 'use-config) <julienfantin@gmail.com>
;; Keywords: convenience, tools

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


;; * Projectile

(use-package projectile
  :ensure t
  :defer t
  :init (after-init #'projectile-global-mode)
  :commands projectile-golbal-mode
  :functions (projectile-load-known-projects)
  :config
  (progn
    (setq projectile-enable-caching t
          projectile-cache-file (user-var-file "projectile.cache")
          projectile-known-projects-file (user-var-file "projectile-bookmarks.el")
          projectile-completion-system 'ivy
          projectile-use-git-grep t
          projectile-create-missing-test-files t
          projectile-globally-ignored-directories
          (append projectile-globally-ignored-directories '("elpa")))
    (add-to-list 'projectile-globally-ignored-files ".DS_Store")
    (advice-add #'projectile-replace :before #'projectile-save-project-buffers)
    (projectile-load-known-projects)))

(provide 'config-project)
;;; config-project.el ends here