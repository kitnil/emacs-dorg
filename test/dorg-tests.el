;;; dorg-tests.el --- Test suite for dorg.           -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Oleg Pykhalov

;; Package-Requires: ((el-mock "1.25.1"))

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

;;; Code:
(require 'ert)
(require 'dorg)
(require 'el-mock)

(defmacro dorg-with-test-buffer (&rest body)
  "Evaluate body in test buffer."
  `(with-temp-buffer
     (insert "\
* Email
** TODO [1970-01-01 Thu 00:00] [[gnus:INBOX#xxxxxxxxxx.xxx@xxxxxxx.xxx][Email from Alice Brother: {bug#12345} {PATCH 1/1} gnu: Add xxxxxxx.]] by [[mailto:xxxxxx@xxxxxxx.xxx][Alice Brother:]]
** [[https://issues.guix.gnu.org/23456][\"nix import\" fails]]
")
     (org-mode)
     (goto-char (point-min))
     (forward-line 1)
     ,@body))

(ert-deftest dorg-bug-number-test ()
  "test for `dorg-bug-number'."
  (should (dorg-with-test-buffer
           (and (equal "12345" (dorg-bug-number))
                (progn (org-get-next-sibling)
                       (equal "23456" (dorg-bug-number)))))))

(ert-deftest dorg-bug-status-test ()
  "test for `dorg-bug-status'."
  (with-mock
    (stub debbugs-get-status => '(((pending . "pending"))))
    (should (and (equal "pending"
                        (dorg-bug-status "12345"))
                 (equal "pending"
                        (dorg-bug-status "23456"))))))

(ert-deftest dorg-bug-update-test ()
  "test for `dorg-bug-update'."
  (with-mock
    (stub debbugs-get-status => '(((pending . "done"))))
    (let ((test-string "\
* Email
** DONE [1970-01-01 Thu 00:00] [[gnus:INBOX#xxxxxxxxxx.xxx@xxxxxxx.xxx][Email from Alice Brother: {bug#12345} {PATCH 1/1} gnu: Add xxxxxxx.]] by [[mailto:xxxxxx@xxxxxxx.xxx][Alice Brother:]]
** DONE [[https://issues.guix.gnu.org/23456][\"nix import\" fails]]
"))
      (should (equal test-string
                     (dorg-with-test-buffer
                      (dorg-bugs-update)
                      (substring-no-properties (buffer-string))))))))

(provide 'dorg-tests)
;;; dorg-tests.el ends here
