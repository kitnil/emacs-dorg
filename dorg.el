;;; dorg.el --- Manage Org-mode entries with Debbugs  -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Oleg Pykhalov

;; Author: Oleg Pykhalov <go.wigust@gmail.com>
;; Keywords: extensions
;; URL: https://github.com/kitnil/dorg
;; Version: 1.0.1
;; Package-Requires: ((emacs "25.1") (debbugs "0.25"))

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

;; This package provides functions for Org-mode to manage entries
;; according to information received via Debbugs.

;;; Code:

(require 'debbugs)
(require 'org)

(defgroup dorg nil
  "Settings for `dorg'."
  :prefix "dorg-"
  :group 'dorg)

(defcustom dorg-regexp-bug
  (rx line-start (one-or-more anything)
      "bug" "#" (group (one-or-more numeric))
      (one-or-more anything) line-end)
  "Regexp matching bug in Org-mode's entry."
  :type 'regexp
  :group 'dorg)

(defcustom dorg-regexp-guix-issue
  (rx line-start (one-or-more anything)
      "http" (zero-or-one "s") "://issues.guix.gnu.org/"
      (zero-or-one "issue/") (group (one-or-more numeric))
      (one-or-more anything) line-end)
  "Regexp matching bug on Guix issue."
  :type 'regexp
  :group 'dorg)

(defun dorg-bug-number ()
  "Get bug number from Org-mode entry at point."
  (let ((org-entry (buffer-substring (org-entry-beginning-position)
                                     (org-entry-end-position))))
    (if (or (string-match dorg-regexp-bug org-entry)
            (string-match dorg-regexp-guix-issue org-entry))
        (substring-no-properties (match-string 1 org-entry))
      nil)))

(defun dorg-bug-status (bug-number)
  "Get BUG-NUMBER status."
  (alist-get 'pending
             (car (debbugs-get-status (string-to-number bug-number)))))

;;;###autoload
(defun dorg-bug-update ()
  "Update Org-entry at point."
  (interactive)
  (let ((bug-number (dorg-bug-number)))
    (if (or (not bug-number)
            (equal (dorg-bug-status bug-number) "pending"))
        (message (format "%s is still open." bug-number))
      (org-todo 'done))))

;;;###autoload
(defun dorg-bugs-update ()
  "Update all Org-entries in current buffer."
  (interactive)
  (dorg-bug-update)
  (while (org-get-next-sibling)
    (dorg-bug-update)))

(provide 'dorg)
;;; dorg.el ends here
