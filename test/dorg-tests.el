;;; dorg-tests.el --- Test suite for dorg.           -*- lexical-binding: t; -*-

;; Copyright (C) 2020  Oleg Pykhalov

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
** TODO [1970-01-01 Thu 00:00] [[gnus:INBOX#xxxxxxxxxx.xxx@xxxxxxx.xxx][Email from Alice Brother: {bug#12345} {PATCH 1/1} gnu: Add xxxxxxx.]] by [[mailto:xxxxxx@xxxxxxx.xxx][Alice Brother:]]")
     (org-mode)
     (goto-char (point-min))
     (forward-line 1)
     ,@body))

(ert-deftest dorg-bug-number-test ()
  "test for `dorg-bug-number'."
  (should (equal "12345"
                 (dorg-with-test-buffer (dorg-bug-number)))))

(ert-deftest dorg-bug-status-test ()
  "test for `dorg-bug-status'."
  (with-mock
    (stub debbugs-get-status => '(((pending . "pending"))))
    (should (equal "pending"
                   (dorg-bug-status "12345")))))

(ert-deftest dorg-bug-update-test ()
  "test for `dorg-bug-update'."
  (with-mock
    (stub debbugs-get-status => '(((pending . "done"))))
    (let ((test-string "* Email\n** DONE"))
      (should (equal test-string
                     (dorg-with-test-buffer
                      (dorg-bug-update)
                      (substring-no-properties
                       (substring (buffer-string)
                                  0 (length test-string)))))))))

(provide 'dorg-tests)
;;; dorg-tests.el ends here
