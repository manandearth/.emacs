
(require 'package)
(add-to-list 'package-archives
       '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(require 'transpose-frame)
(require 'ob-ipython)
(require 'conda)
(add-hook 'after-init-hook 'global-company-mode)
(add-hook 'prog-mode-hook 'company-mode)
(with-eval-after-load 'company
  (add-to-list 'company-backends 'company-anaconda))

(add-hook 'python-mode-hook 'anaconda-mode)

;; Make cursor more visible when you move a long distance
(use-package beacon
  :config
  (beacon-mode 1))

(autoload 'ivy-bibtex "ivy-bibtex" "" t)

(defvar myPackages
  '(better-defaults
    ein ;; add the ein (Emacs ipython notebook)
    elpy ;; add the elpy package
    flycheck ;; add the flycheck package
    conda
    py-autopep8))

;; (add-to-list 'load-path "~/.emacs.d")
;; (require 'scimax-org-babel-ipython)

;;(add-to-list 'load-path "~/git/swiper/") (require 'ivy) 
;;(ivy-mode 1) 
;; for new users:
;;(setq ivy-use-virtual-buffers t) (setq ivy-count-format "(%d/%d) ") 
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq enable-recursive-minibuffers t)
(global-set-key "\C-s" 'swiper)
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "<f1> f") 'counsel-describe-function)
(global-set-key (kbd "<f1> v") 'counsel-describe-variable)
(global-set-key (kbd "<f1> l") 'counsel-find-library)
(global-set-key (kbd "<f2> i") 'counsel-info-lookup-symbol)
(global-set-key (kbd "<f2> u") 'counsel-unicode-char)
(global-set-key (kbd "C-c g") 'counsel-git)
(global-set-key (kbd "C-c j") 'counsel-git-grep)
(global-set-key (kbd "C-c k") 'counsel-ag)
(global-set-key (kbd "C-x l") 'counsel-locate)
(global-set-key (kbd "C-S-o") 'counsel-rhythmbox)
(define-key minibuffer-local-map (kbd "C-r") 'counsel-minibuffer-history)

(require 'ido) ;;interactively do things...
(ido-mode t)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'zenburn t)

(mapc #'(lambda (package)
    (unless (package-installed-p package)
      (package-install package)))
      myPackages)

(pdf-tools-install)
(setq pdf-view-use-unicode-ligther nil)

;; (elpy-enable)
;; (elpy-use-ipython)

;; (when (require 'flycheck nil t)
  ;; (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  ;; (add-hook 'elpy-mode-hook 'flycheck-mode))

;; (add-hook 'anaconda-mode-hook 'flycheck-mode)

;; (require 'py-autopep8)
;; (add-hook 'anaconda-mode-hook 'py-autopep8-enable-on-save)

(setenv "PYTHONPATH" "/home/adam/anaconda3/bin/python3.5")
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

(setq python-shell-interpreter "/home/adam/anaconda3/bin/ipython3")
(setq ob-ipython-command "/home/adam/anaconda3/bin/jupyter")

(defun python-mode-outline-hook ()
  (setq outline-level 'python-outline-level)

  (setq outline-regexp
    (rx (or
         ;; Commented outline heading
         (group
          (* space)  ; 0 or more spaces
          (one-or-more (syntax comment-start))
          (one-or-more space)
          ;; Heading level
          (group (repeat 1 8 "\*"))  ; Outline stars
          (one-or-more space))

         ;; Python keyword heading
         (group
          ;; Heading level
          (group (* space)) ; 0 or more spaces
          bow
          ;; Keywords
          (or "class" "def" "else" "elif" "except" "for" "if" "try" "while")
          eow)))))

(defun python-outline-level ()
  (or
   ;; Commented outline heading
   (and (string-match (rx
               (* space)
               (one-or-more (syntax comment-start))
               (one-or-more space)
               (group (one-or-more "\*"))
               (one-or-more space))
              (match-string 0))
    (- (match-end 0) (match-beginning 0)))

   ;; Python keyword heading, set by number of indentions
   ;; Add 8 (the highest standard outline level) to every Python keyword heading
   (+ 8 (- (match-end 0) (match-beginning 0)))))

(add-hook 'python-mode-hook 'python-mode-outline-hook)

(setq scimax-dir "/home/adam/scimax/")
(add-to-list 'load-path "/home/adam/scimax/") ;; TODO find how to require from scimax

(load-library "paren")
(show-paren-mode 1)
(transient-mark-mode t)
(require 'paren)

(global-set-key (kbd "C-c i")
(lambda() (interactive)(org-babel-load-file "~/.emacs.d/init.org")))

; status globally
(global-set-key (kbd "C-x g") 'magit-status)
; pop up of pop ups globally
(global-set-key (kbd "C-x M-g") 'magit-dispatch-popup)

(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/mu4e/") ;;mu4e mail
(require 'mu4e)
(require 'smtpmail)
(use-package mu4e-alert
  :ensure t
  :after mu4e
  :init
  (setq mu4e-alert-interesting-mail-query
    (concat
     "flag:unread maildir:/INBOX "
     ))
  (mu4e-alert-enable-mode-line-display)
  (defun gjstein-refresh-mu4e-alert-mode-line ()
    (interactive)
    (mu4e~proc-kill)
    (mu4e-alert-enable-mode-line-display)
    )
  (run-with-timer 0 60 'gjstein-refresh-mu4e-alert-mode-line)
  )

(setq mu4e-get-mail-command "offlineimap")

;; tell message-mode how to send mail
;; (setq message-send-mail-function 'smtpmail-send-it)

;; (setq smtpmail-smtp-server "smtp.posteo.de")

;; close message buffer
(setq message-kill-buffer-on-exit t)

;; attachments go here:
(setq mu4e-attachment-dir  "~/Downloads")

;; show full addresses in view message (instead of just names)
;; toggle per name with M-RET
(setq mu4e-view-show-addresses 't)

;; my name and user
;; (setq user-mail-address "adam@manandearth.net"
      ;; user-full-name  "Adam Gefen")


;; for nullmailer:
;; (setq message-send-mail-function 'message-send-mail-with-sendmail)

; I have my "default" parameters
(setq mu4e-sent-folder "/sent"
      mu4e-drafts-folder "/drafts"
      message-send-mail-function 'smtpmail-send-it
      user-mail-address "adam@manandearth.net"
      user-full-name  "Adam Gefen"
      smtpmail-default-smtp-server "smtp.posteo.de"
      smtpmail-smtp-server "posteo.de"
      smtpmail-stream-type 'starttls
      smtpmail-smtp-service 587)

;; convenience function for starting the whole mu4e in its own frame
;; posted by the author of mu4e on the mailing list
(defun mu4e-in-new-frame ()
  "Start mu4e in new frame."
  (interactive)
  (select-frame (make-frame))
  (mu4e))

;; enable inline images
(setq mu4e-view-show-images t)
;; use imagemagick, if available
(when (fboundp 'imagemagick-register-types)
  (imagemagick-register-types))

;; see http://thread.gmane.org/gmane.emacs.orgmode/42715
(eval-after-load 'org-list
  '(add-hook 'org-checkbox-statistics-hook (function ndk/checkbox-list-complete)))

(defun ndk/checkbox-list-complete ()
  (save-excursion
    (org-back-to-heading t)
    (let ((beg (point)) end)
      (end-of-line)
      (setq end (point))
      (goto-char beg)
      (if (re-search-forward "\\[\\([0-9]*%\\)\\]\\|\\[\\([0-9]*\\)/\\([0-9]*\\)\\]" end t)
            (if (match-end 1)
                (if (equal (match-string 1) "100%")
                    ;; all done - do the state change
                    (org-todo 'done)
                  (org-todo 'todo))
              (if (and (> (match-end 2) (match-beginning 2))
                       (equal (match-string 2) (match-string 3)))
                  (org-todo 'done)
                (org-todo 'todo)))))))

(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cc" 'org-capture)
(global-set-key "\C-cb" 'org-iswitchb)(setq org-directory "~/notes")
(setq org-default-notes-file "~/notes/refile.org")

(custom-set-faces
  '(org-level-1 ((t (:inherit outline-1 :height 2.0))))
  '(org-level-2 ((t (:inherit outline-2 :height 1.5))))
  '(org-level-3 ((t (:inherit outline-3 :height 1.2))))
  '(org-level-4 ((t (:inherit outline-4 :height 1.0))))
  '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
)

(add-hook 'org-mode-hook
               (lambda ()
                 (define-key org-mode-map "\C-csv"
                             'org-table-export)))
                                             

;; I use C-c c to start capture mode
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-agenda-files (quote ("~/notes"
                               "~/notes/study/")))

(setq org-ref-notes-directory "~/notes/ref/"
      org-ref-bibliography-notes "~/notes/ref/index.org"
      org-ref-default-bibliography '("~/notes/ref/index.bib")
      org-ref-pdf-directory "~/notes/ref/lib/")

;; Enable org export to odt (OpenDocument Text)
;; It is disabled by default in org 8.x
(eval-after-load "org"
'(require 'ox-odt nil t))

;; email links to mu4e
(require 'org-mu4e)

;; For allowing refile to work between files stored in org-agenda-files variable.
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

(loop for i from 1 to 6
      do
      (let ((template (make-string i ?t))
	    (expansion (concat "|"
			       (mapconcat
				'identity
				(loop for j to i collect "   ")
				"|"))))
	(setf (substring expansion 2 3) "?")
	(add-to-list 'org-structure-template-alist
		     `(,template ,expansion ""))))

(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key (kbd "<f5>") 'bh/org-todo)
(global-set-key (kbd "<S-f5>") 'bh/widen)
(global-set-key (kbd "<f7>") 'bh/set-truncate-lines)
(global-set-key (kbd "<f8>") 'org-cycle-agenda-files)
(global-set-key (kbd "<f9> <f9>") 'bh/show-org-agenda)
(global-set-key (kbd "<f9> b") 'bbdb)
(global-set-key (kbd "<f9> c") 'calendar)
(global-set-key (kbd "<f9> f") 'boxquote-insert-file)
(global-set-key (kbd "<f9> g") 'gnus)
(global-set-key (kbd "<f9> h") 'bh/hide-other)
(global-set-key (kbd "<f9> n") 'bh/toggle-next-task-display)

(global-set-key (kbd "<f9> I") 'bh/punch-in)
(global-set-key (kbd "<f9> O") 'bh/punch-out)

(global-set-key (kbd "<f9> o") 'bh/make-org-scratch)

(global-set-key (kbd "<f9> r") 'boxquote-region)
(global-set-key (kbd "<f9> s") 'bh/switch-to-scratch)

(global-set-key (kbd "<f9> t") 'bh/insert-inactive-timestamp)
(global-set-key (kbd "<f9> T") 'bh/toggle-insert-inactive-timestamp)

(global-set-key (kbd "<f9> v") 'visible-mode)
(global-set-key (kbd "<f9> l") 'org-toggle-link-display)
(global-set-key (kbd "<f9> SPC") 'bh/clock-in-last-task)
(global-set-key (kbd "C-<f9>") 'previous-buffer)
(global-set-key (kbd "M-<f9>") 'org-toggle-inline-images)
(global-set-key (kbd "C-x n r") 'narrow-to-region)
(global-set-key (kbd "C-<f10>") 'next-buffer)
(global-set-key (kbd "<f11>") 'org-clock-goto)
(global-set-key (kbd "C-<f11>") 'org-clock-in)
(global-set-key (kbd "C-s-<f12>") 'bh/save-then-publish)
(global-set-key (kbd "C-c c") 'org-capture)

(defun bh/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading 'invisible-ok)
    (hide-other)
    (org-cycle)
    (org-cycle)
    (org-cycle)))

(defun bh/set-truncate-lines ()
  "Toggle value of truncate-lines and refresh window display."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  ;; now refresh window display (an idiom from simple.el):
  (save-excursion
    (set-window-start (selected-window)
                      (window-start (selected-window)))))

(defun bh/make-org-scratch ()
  (interactive)
  (find-file "/tmp/publish/scratch.org")
  (gnus-make-directory "/tmp/publish"))

(defun bh/switch-to-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "NEXT(n)" "SOMEDAY(s)" "|" "DONE(d)")
              (sequence "WAITING(w@/!)" "HOLD(h@/!)" "|" "CANCELLED(c@/!)" "POSTPONED(p@/!)" "DELEGATED(e@/!)" "|" "PHONE" "MEETING"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "pink" :weight bold)
              ("NEXT" :foreground "light blue" :weight bold)
              ("SOMEDAY" :foreground "dark grey" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("MEETING" :foreground "light green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold)
              ("DELEGATED" :foreground "brown" :weight bold)
	          ("POSTPONED" :foreground "light grey" :weight bold))))

;; fast todo selection, Use C-c C-t KEY (t, n, d)
(setq org-use-fast-todo-selection t)

;; this one is for quick cycling todo modes with S-left and S-right
(setq org-treat-S-cursor-todo-selection-as-state-change nil)

(setq org-default-notes-file (concat org-directory "/notes.org"))
(define-key global-map "\C-cc" 'org-capture)

;; refile in org:

; Targets include this file and any file contributing to the agenda - up to 9 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 9)
                                 (org-agenda-files :maxlevel . 9))))

; Use full outline paths for refile targets - we file directly with IDO
(setq org-refile-use-outline-path t)

; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

; Use IDO for both buffer and file completion and ido-everywhere to t
(setq org-completion-use-ido t)
(setq ido-everywhere t)
(setq ido-max-directory-size 100000)
(ido-mode (quote both))
; Use the current window when visiting files and buffers with ido
(setq ido-default-file-method 'selected-window)
(setq ido-default-buffer-method 'selected-window)
; Use the current window for indirect buffer display
(setq org-indirect-buffer-display 'current-window)

;;;; Refile settings
; Exclude DONE state tasks from refile targets
(defun bh/verify-refile-target ()
;  "Exclude todo keywords with a done state from refile targets"
(not (member (nth 2 (org-heading-components)) org-done-keywords)))

(setq org-refile-target-verify-function 'bh/verify-refile-target)

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

;; Custom agenda command definitions
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header "Stuck Projects")
                            (org-agenda-skip-function 'bh/skip-non-stuck-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header "Projects")
                            (org-agenda-skip-function 'bh/skip-non-projects)
                            (org-tags-match-list-sublevels 'indented)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header (concat "Project Next Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-projects-and-habits-and-single-tasks)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(todo-state-down effort-up category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Project Subtasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-REFILE-CANCELLED-WAITING-HOLD/!"
                           ((org-agenda-overriding-header (concat "Standalone Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-project-tasks)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-with-date bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED+WAITING|HOLD/!"
                           ((org-agenda-overriding-header (concat "Waiting and Postponed Tasks"
                                                                  (if bh/hide-scheduled-and-waiting-next-tasks
                                                                      ""
                                                                    " (including WAITING and SCHEDULED tasks)")))
                            (org-agenda-skip-function 'bh/skip-non-tasks)
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled bh/hide-scheduled-and-waiting-next-tasks)
                            (org-agenda-todo-ignore-deadlines bh/hide-scheduled-and-waiting-next-tasks)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header "Tasks to Archive")
                       (org-agenda-skip-function 'bh/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil)))
		nil)))))

(defun do-org-show-all-inline-images ()
  (interactive)
  (org-display-inline-images t t))
(global-set-key (kbd "C-c C-x C v")
                'do-org-show-all-inline-images)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (ipython . t)
    ))

(setq org-src-fontify-natively t
    org-src-preserve-indentation t
    org-src-tab-acts-natively t)

;; all python code be safe
(defun my-org-confirm-babel-evaluate (lang body)
(not (string= lang "python")))
(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

(setq org-babel-python-command "/home/adam/anaconda3/bin/ipython3 --no-banner --classic --no-confirm-exit")

;; use %cpaste to paste code into ipython in org mode
(defadvice org-babel-python-evaluate-session
(around org-python-use-cpaste
        (session body &optional result-type result-params) activate)
        "Add a %cpaste and '--' to the body, so that ipython does the right thing."
(setq body (concat "%cpaste\n" body "\n--"))
ad-do-it
(if (stringp ad-return-value)
  (setq ad-return-value (replace-regexp-in-string "\\(^Pasting code; enter '--' alone on the line to stop or use Ctrl-D\.[\r\n]:*\\)" "" ad-return-value))))

;; no extra indentation in the source blocks
(setq org-src-preserve-indentation t)

;; use syntax highlighting in org-file code blocks
(setq org-src-fontify-natively t)

(setq org-babel-default-header-args:python
      '((:results . "output replace")
	(:session . "none")
	(:exports . "both")
	(:cache .   "no")
	(:noweb . "no")
	(:hlines . "no")
	(:tangle . "no")
	(:eval . "never-export")))

(setq org-confirm-babel-evaluate nil)

(add-hook 'org-babel-after-execute-hook 'org-display-inline-images 'append)

;; add <p for python expansion
(add-to-list 'org-structure-template-alist
	     '("p" "#+BEGIN_SRC python :results output org drawer\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <por for python expansion with raw output
(add-to-list 'org-structure-template-alist
	     '("por" "#+BEGIN_SRC python :results output raw\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <pv for python expansion with value
(add-to-list 'org-structure-template-alist
	     '("pv" "#+BEGIN_SRC python :results value\n?\n#+END_SRC"
	       "<src lang=\"python\">\n?\n</src>"))

;; add <el for emacs-lisp expansion
(add-to-list 'org-structure-template-alist
	     '("el" "#+BEGIN_SRC emacs-lisp\n?\n#+END_SRC"
	       "<src lang=\"emacs-lisp\">\n?\n</src>"))

(add-to-list 'org-structure-template-alist
	     '("ell" "#+BEGIN_SRC emacs-lisp :lexical t\n?\n#+END_SRC"
	       "<src lang=\"emacs-lisp\">\n?\n</src>"))

;; add <sh for shell
(add-to-list 'org-structure-template-alist
	     '("sh" "#+BEGIN_SRC sh\n?\n#+END_SRC"
	       "<src lang=\"shell\">\n?\n</src>"))

(add-to-list 'org-structure-template-alist
	     '("lh" "#+latex_header: " ""))

(add-to-list 'org-structure-template-alist
	     '("lc" "#+latex_class: " ""))

(add-to-list 'org-structure-template-alist
	     '("lco" "#+latex_class_options: " ""))

(add-to-list 'org-structure-template-alist
	     '("ao" "#+attr_org: " ""))

(add-to-list 'org-structure-template-alist
	     '("al" "#+attr_latex: " ""))

(add-to-list 'org-structure-template-alist
	     '("ca" "#+caption: " ""))

(add-to-list 'org-structure-template-alist
	     '("tn" "#+tblname: " ""))

(add-to-list 'org-structure-template-alist
	     '("n" "#+name: " ""))

(add-to-list 'org-structure-template-alist
	     '("o" "#+options: " ""))

(add-to-list 'org-structure-template-alist
	     '("ti" "#+title: " ""))

(setq inhibit-startup-message t) ;; hide the startup message

;; (global-linum-mode t) ;; enable line numbers globally

(add-hook 'text-mode-hook 'linum-mode)
(add-hook 'prog-mode-hook 'linum-mode)

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
;; C-x C-0 restores the default font size

(if window-system
    (tool-bar-mode -1)
)
