;;; whicher.el --- Audit and install the programs that your Emacs config depends on. -*- lexical-binding: t -*-

;; Copyright (C) 2019 Oleh Krehel

;; Author: Oleh Krehel <ohwoeowho@gmail.com>
;; URL: https://github.com/abo-abo/whicher
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.3"))
;; Keywords: programs, utility

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; If a command depends on a certain program to be installed on your
;; system, but it's not, that command is broken. Whicher makes it easy
;; to keep track of the programs that your config depends on.
;;
;; Example:
;;
;; (setq mu4e-get-mail-command (whicher "mbsync -a"))
;; (setq mu4e-html2text-command (whicher "w3m -T text/html"))
;;
;; Now, Whicher knows that your config depends on "mbsync" and "w3m".
;; This comes at almost no performance penalty, since
;; `executable-find' isn't called by `whicher'.
;;
;; Use `whicher-report' to see the state of your dependencies.
;; The output is similar to the output of which(1), hence the name.

;;; Code:

(defvar whicher-cmd-list nil)

;;;###autoload
(defun whicher (cmd-string)
  "Extract the required program from CMD-STRING.
Store it into `whicher-cmd-list'.
Use `whicher-check' to check this list."
  (let ((program (car (split-string cmd-string))))
    (cl-pushnew program whicher-cmd-list
                :test #'string=))
  cmd-string)

(defun whicher--progname (p)
  (propertize p 'face 'font-lock-builtin-face))

(defun whicher--progpath (p)
  (let ((path (executable-find p)))
    (or path
        (propertize "not found" 'face 'error))))

(defun whicher-report ()
  "Report which programs are required by your config and their install status."
  (interactive)
  (let* ((max-length
          (cl-reduce
           (lambda (a b) (max a (length b)))
           whicher-cmd-list
           :initial-value 0))
         (fmt-expr (format "%% %ds: %%s" max-length)))
    (message
     "Required programs:\n%s"
     (mapconcat
      (lambda (p)
        (format fmt-expr
                (whicher--progname p)
                (whicher--progpath p)))
      whicher-cmd-list
      "\n"))))

(provide 'whicher)

;;; whicher.el ends here
