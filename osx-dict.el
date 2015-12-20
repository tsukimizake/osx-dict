;;; osx-dict.el --- Use the OSX dictionary API from Emacs.

;;; Commentary:

;;; Code:
(require 'thingatpt)
(require 'find-func)

(defgroup osx-dict nil "OSX dictionary service for Emacs.")
(defconst osx-dict-buffer-name "*dictionary*")
(defcustom osx-dict-xcodeproject
  (expand-file-name "osx-dict.xcodeproj" (file-name-directory (find-library-name "osx-dict")))
  "Path to osx-dict server xcodeproject")
(defcustom osx-dict-server
  (expand-file-name "./build/Release/osx-dict" (file-name-directory (find-library-name "osx-dict")))
  "Path to osx-dict server")

(defun osx-dict--reformat ()
  "Format some tokens."
  (unless (string-match (rx "Traceback (most recent call last):Traceback" (* anything)) (buffer-string))
    (goto-char (point-min))
    (while (re-search-forward (rx "▸") nil t)
      (replace-match "\n ▸"))
    (goto-char (point-min))
    (while (re-search-forward (rx ".") nil t)
      (replace-match ".\n"))
    (goto-char (point-min))
    ))

(defun osx-dict-exec-server (str)
  "Run server with single arg `STR'."
  (let ((buf (get-buffer-create osx-dict-buffer-name)))
	(with-current-buffer buf
	  (erase-buffer)
	  (call-process osx-dict-server nil buf t str)
	  )))

(defun osx-dict-call (str)
  "Call dictionary.  `STR' is the word to search."
  (osx-dict-exec-server str)
  (with-current-buffer osx-dict-buffer-name (osx-dict--reformat)))


;; interactive functions

(defun osx-dict-install-server ()
  (interactive)
  (call-process "xcodebuild" nil nil nil "-project" osx-dict-xcodeproject)
  (message "osx-dict server installed."))

(defun osx-dict-region (beg end)
  (interactive "r")
  (osx-dict-call (buffer-substring beg end))
  (display-buffer (get-buffer-create osx-dict-buffer-name)))

(defun osx-dict-at-point ()
  (interactive)
  (osx-dict-call (word-at-point))
  (display-buffer (get-buffer-create osx-dict-buffer-name)))

(defun osx-dict-dwim ()
  (interactive)
  (if (region-active-p)
      (osx-dict-region (region-beginning) (region-end))
    (osx-dict-at-point)))

(provide 'osx-dict)
;;; osx-dict.el ends here
