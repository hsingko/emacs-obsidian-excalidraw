;;; emacs-obsidian-excalidraw.el --- simple tool working with obsidian-excalidraw plugin  -*- lexical-binding: t; -*-

;; Copyright (C) 2022  hsingko

;; Author: hsingko <hsingko@protonmail.com>
;; Keywords: multimedia, convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:


(defgroup emacs-obsidian-excalidraw nil
  "customs for obsidian excalidraw"
  :group 'convenience
  :prefix "emacs-obsidian-excalidraw-")

(defcustom emacs-obsidian-excalidraw-vault "excalidraw"
  "obsidian valut name contains excalidraw files"
  :type 'string
  :group 'emacs-obsidian-excalidraw)

(defcustom emacs-obsidian-excalidraw-image-format "svg"
  "obsidian-exlicalidraw export image format, png or svg, default svg"
  :type 'string
  :group 'emacs-obsidian-excalidraw)

(defcustom emacs-obsidian-excalidraw-template-file (when load-file-name
						     (concat (file-name-directory load-file-name)
							     "template"))
  "template for excalidraw"
  :type 'string
  :group 'emacs-obsidian-excalidraw)

(defcustom emacs-obsidian-excalidraw-vault-dir "~/Documents/excalidraw/"
  "obsidian vault directory"
  :type 'string
  :group 'emacs-obsidian-excalidraw
  )

(defun emacs-obsidian-excalidraw-get-link-at-point-raw ()
  (if (derived-mode-p 'markdown-mode)
		   (markdown-link-url)
    (thing-at-point 'url t)))

(defun emacs-obsidian-excalidraw--get-link-at-point ()
  (let ((raw-link (emacs-obsidian-excalidraw-get-link-at-point-raw)))
    (if raw-link
	raw-link
      (cond ((derived-mode-p 'markdown-mode)
	     (plist-get (cdr
			 (car (get-char-property-and-overlay (point) 'display)))
			:file))
	    ((derived-mode-p 'org-mode)
	     (plist-get (car (get-char-property-and-overlay (point) 'htmlize-link))  :uri)) 
	    (t
	     "")))))
    


;;; ###
;;; autoload
(defun emacs-obsidian-excalidraw-create (name)
  "create excalidraw file through obsidian url scheme"
  (interactive "MInput Draw Name:")
  (let ((exfile (expand-file-name
		 (format "%s.excalidraw.md" name)
		 emacs-obsidian-excalidraw-vault-dir))
	(imgfile (expand-file-name
		  (format "%s.excalidraw.%s" name emacs-obsidian-excalidraw-image-format)
		  emacs-obsidian-excalidraw-vault-dir))
	(oblink (format "obsidian://open?vault=%s&file=%s.excalidraw.md" emacs-obsidian-excalidraw-vault name))
	)
    (copy-file emacs-obsidian-excalidraw-template-file exfile)
    (cond ((derived-mode-p 'org-mode)
	   (insert (format "[[file:%s]]" imgfile)))
	  ((derived-mode-p 'markdown-mode)
	   (insert (format "![](%s)" imgfile)))
	  (t
	   (insert imgfile)))
	  (browse-url oblink)))

;;; autoload
(defun emacs-obsidian-excalidraw-open-at-point ()
  "open exsiting excalidraw file"
  (interactive)
  (let* ((link (emacs-obsidian-excalidraw--get-link-at-point))
	 (name (file-name-sans-extension (file-name-base link))))
    (browse-url
     (format "obsidian://open?vault=%s&file=%s.excalidraw.md" emacs-obsidian-excalidraw-vault name))))

(provide 'emacs-obsidian-excalidraw)
;;; emacs-obsidian-excalidraw.el ends here
