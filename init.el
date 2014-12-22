(defvar gr/cask-directory
  (expand-file-name "/usr/local/Cellar/cask/0.7.2"
  "Cask home."))

(defun gr/setup-cask-and-pallet ()
  "Package management goodness."
  (require 'cask (expand-file-name "cask.el" gr/cask-directory))
  (cask-initialize)
  (require 'pallet)
  (pallet-mode t)
  )

(defun gr/no-bars-held ()
  "Turn off tool, scroll, and menu bars when appropriate.
Only turn off the menu bar running in a terminal window."
  (setq inhibit-startup-echo-area-message "graphaelli")
  (if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
  (if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
  (if (and (fboundp 'window-system)
           (not (window-system))
           (fboundp 'menu-bar-mode))
      (menu-bar-mode -1))
  (defun yes-or-no-p (prompt) "y/n" (y-or-n-p prompt) ))

(defun gr/find-file-in-project ()
  (require 'find-file-in-project)

  (setq ffip-limit 8192
	ffip-find-options "-not -regex \".*/build.*\""
	ffip-full-paths t
	ffip-patterns (list "*.clj"
			    "*.conf"
			    "*.cron"
			    "*.css"
			    "*.el"
			    "*.html"
			    "*.js"
			    "*.json"
			    "*.mk"
			    "*.md"
			    "*.org"
			    "*.py"
			    "*.rb"
			    "*.rst"
			    "*.sh"
			    "*.soy"
			    "*.txt"
			    "*.yml"
			    "Makefile")
	ffip-prune-patterns (list ".git" "build"))

  (global-set-key (kbd "C-x C-S-f") 'find-file-in-project)
  )


(defun gr/keybinds ()
   "Rebind some keys."

   ;; unset
   (global-unset-key (kbd "C-h"))  ; just use <f1> so this can be del-back-char
   (global-unset-key (kbd "<f3>"))  ; was kmacro-start-macro-or-insert-counter
   (global-unset-key (kbd "<f4>"))  ; was kmacro-end-or-call-macro

   ;; set
   (global-set-key (kbd "C-c DEL") 'join-line)
   (global-set-key (kbd "C-h") 'delete-backward-char)
   (global-set-key (kbd "C-M-h") 'backward-kill-word)
   (global-set-key (kbd "C-S-h") 'kill-whole-line)
   (global-set-key (kbd "s-=") 'text-scale-increase)
   (global-set-key (kbd "s--") 'text-scale-decrease)
   (global-set-key (kbd "s-0") '(lambda () (interactive) (text-scale-set 0)))
   (global-set-key (kbd "<f4>") 'delete-trailing-whitespace)
  )

(defun gr/keymaps ()
  "Remap some keys on macs."
  (if (equal system-type 'darwin)
    (progn
      ;; Command as meta.
      (setq ns-command-modifier 'meta)

      ;; Option as hyper.
      (setq ns-option-modifier 'hyper)

      ;; fn as super.
      (setq ns-function-modifier 'super)

      ;; See https://github.com/Homebrew/homebrew/commit/49c85b89753d42cc4ec2fee9607a608b3b14ab33?w=1
      (setq ns-use-srgb-colorspace t)

      ;; Trackpad taming.
      (setq
       mouse-wheel-scroll-amount '(0.0001)
       mouse-wheel-progressive-speed nil
       scroll-step 1
       scroll-conservatively 10000
       auto-window-vscroll nil))))

(defun gr/line-numbering ()
  "Line numbering policies."
  (global-linum-mode 1)
  (global-hl-line-mode 1)

  (require 'hlinum)
  (hlinum-activate)

  (defun gr/hlinum-active-toggle()
    "Toggle line number highlight."
    (interactive)
    (hlinum-deactivate)
    )

  (global-set-key (kbd "<f3>") 'gr/hlinum-active-toggle)
  )

(defun gr/set-dirs ()
  "Set save and trash dirs."
  (setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))
  (setq trash-directory (expand-file-name "~/.emacs.d/trashes")
      delete-by-moving-to-trash t))

(gr/no-bars-held)
(gr/keybinds)
;; (gr/keymaps)
(gr/set-dirs)
(gr/setup-cask-and-pallet)
(gr/find-file-in-project)
(gr/line-numbering)

(electric-pair-mode 1)

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;;; end of init.el
