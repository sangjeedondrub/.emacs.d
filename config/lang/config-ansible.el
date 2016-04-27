;;; config-devops.el --- Ansible -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Julien Fantin

;; Author: Julien Fantin <julienfantin@gmail.com>
;; Keywords:

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

(use-package yaml-mode
  :ensure t
  :mode (("\\.yml?\\'"            . yaml-mode)
         ("\\.yaml?\\'"           . yaml-mode)
         ("ansible/group_vars/.*" . yaml-mode)
         ("ansible/host_vars/.*"  . yaml-mode)))

(use-package ansible
  :ensure t
  :defer t
  :init
  (after 'yaml-mode
    (add-hook 'yaml-mode-hook #'ansible))
  (after (yaml-mode yasnippet)
    (ansible::snippets-initialize)))

(use-package jinja2-mode
  :ensure t
  :mode "\\.j2?\\'")

(use-package ansible-doc
  :ensure t
  :after ansible
  :init (add-hook 'ansible::hook #'ansible-doc-mode))

(use-package company-ansible
  :ensure t
  :after ansible
  :init
  (after config-completion
    (config-completion-add-backends
     'yaml-mode
     (config-completion-backend-with-yasnippet #'company-ansible))))

(provide 'config-ansible)
;;; config-ansible.el ends here
