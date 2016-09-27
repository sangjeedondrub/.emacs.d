;;; config-clojurescript.el --- ClojureScript configuration  -*- lexical-binding: t; -*-

;; Copyright (C) 2016  Julien Fantin

;; Author: Julien Fantin <julienfantin@gmail.com>
;; Keywords: languages

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

(after 'clojure-mode
  (define-clojure-indent
    (defui '(1 nil (1)))
    (ui '(0 nil (1)))
    (dom/a 1)
    (dom/abbr 1)
    (dom/address 1)
    (dom/area 1)
    (dom/article 1)
    (dom/aside 1)
    (dom/audio 1)
    (dom/b 1)
    (dom/base 1)
    (dom/bdi 1)
    (dom/bdo 1)
    (dom/big 1)
    (dom/blockquote 1)
    (dom/body 1)
    (dom/br 1)
    (dom/button 1)
    (dom/canvas 1)
    (dom/caption 1)
    (dom/cite 1)
    (dom/code 1)
    (dom/col 1)
    (dom/colgroup 1)
    (dom/data 1)
    (dom/datalist 1)
    (dom/dd 1)
    (dom/del 1)
    (dom/details 1)
    (dom/dfn 1)
    (dom/dialog 1)
    (dom/div 1)
    (dom/dl 1)
    (dom/dt 1)
    (dom/em 1)
    (dom/embed 1)
    (dom/fieldset 1)
    (dom/figcaption 1)
    (dom/figure 1)
    (dom/footer 1)
    (dom/form 1)
    (dom/h1 1)
    (dom/h2 1)
    (dom/h3 1)
    (dom/h4 1)
    (dom/h5 1)
    (dom/h6 1)
    (dom/head 1)
    (dom/header 1)
    (dom/hr 1)
    (dom/html 1)
    (dom/i 1)
    (dom/iframe 1)
    (dom/img 1)
    (dom/ins 1)
    (dom/kbd 1)
    (dom/keygen 1)
    (dom/label 1)
    (dom/legend 1)
    (dom/li 1)
    (dom/link 1)
    (dom/main 1)
    (dom/map 1)
    (dom/mark 1)
    (dom/menu 1)
    (dom/menuitem 1)
    (dom/meta 1)
    (dom/meter 1)
    (dom/nav 1)
    (dom/noscript 1)
    (dom/object 1)
    (dom/ol 1)
    (dom/optgroup 1)
    (dom/output 1)
    (dom/p 1)
    (dom/param 1)
    (dom/picture 1)
    (dom/pre 1)
    (dom/progress 1)
    (dom/q 1)
    (dom/rp 1)
    (dom/rt 1)
    (dom/ruby 1)
    (dom/s 1)
    (dom/samp 1)
    (dom/script 1)
    (dom/section 1)
    (dom/small 1)
    (dom/source 1)
    (dom/span 1)
    (dom/strong 1)
    (dom/style 1)
    (dom/sub 1)
    (dom/summary 1)
    (dom/sup 1)
    (dom/table 1)
    (dom/tbody 1)
    (dom/td 1)
    (dom/tfoot 1)
    (dom/th 1)
    (dom/thead 1)
    (dom/time 1)
    (dom/title 1)
    (dom/tr 1)
    (dom/track 1)
    (dom/u 1)
    (dom/ul 1)
    (dom/var 1)
    (dom/video 1)
    (dom/wbr 1)
    (dom/circle 1)
    (dom/clipPath 1)
    (dom/ellipse 1)
    (dom/g 1)
    (dom/line 1)
    (dom/mask 1)
    (dom/path 1)
    (dom/pattern 1)
    (dom/polyline 1)
    (dom/rect 1)
    (dom/svg 1)
    (dom/text 1)
    (dom/defs 1)
    (dom/linearGradient 1)
    (dom/polygon 1)
    (dom/radialGradient 1)
    (dom/stop 1)
    (dom/tspan 1)
    (dom/use 1)))

(provide 'config-clojurescript)
;;; config-clojurescript.el ends here
