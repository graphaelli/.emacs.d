(defun gr/ask-before-closing ()
  "Ask whether or not to close, and then close if y was pressed"
  (interactive)
  (if (y-or-n-p (format "Are you sure you want to exit Emacs? "))
      (if (< emacs-major-version 22)
          (save-buffers-kill-terminal)
        (save-buffers-kill-emacs))
    (message "Canceled exit")))

(defvar gr/cask-directory
  (expand-file-name "/usr/local/Cellar/cask/0.7.4"
  "Cask home."))

(defun gr/setup-cask-and-pallet ()
  "Package management goodness."
  (require 'cask (expand-file-name "cask.el" gr/cask-directory))
  (cask-initialize)
  (require 'pallet)
  (pallet-mode t)

  (when (memq window-system '(mac ns))
      (exec-path-from-shell-initialize))
  )

(defun gr/server ()
  "Emacs Server."

  (require 'server)

  (unless (server-running-p)
    (server-start))
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
  (defun yes-or-no-p (prompt) "y/n" (y-or-n-p prompt) )
  (fringe-mode (cdr (assoc "default" fringe-styles)))
  )

(defun gr/ag ()
  (require 'ag)

  (setq ag-arguments
	'("--smart-case" "--nogroup" "--column" "--smart-case" "--stats" "--")
	ag-highlight-search t)

  (global-set-key (kbd "C-x C-a") 'ag-project)
  (global-set-key (kbd "C-x C-S-a") 'ag-dired)
  )

(defun gr/display-buffer-file-name ()
  "Message the full path to the currently visited file."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "%s" (buffer-file-name)))))

(defun gr/expand-region ()
    (require 'expand-region)
    (global-set-key (kbd "C-M-SPC") 'er/expand-region)
    )

(defun gr/find-file-in-project ()
  (require 'find-file-in-project)

  (setq ffip-limit 1048576
	ffip-find-options "-not -regex \".*/build.*\""
	ffip-full-paths t
	ffip-patterns '("*")
	ffip-prune-patterns (list "*/.cask/*" "*/.git/*" "*/.idea/*" "*/.ipynb_checkpoints/*" "*/.metadata/*" "third-party" "build" "closure" "*.pyc"))

  (global-set-key (kbd "C-x C-S-f") 'find-file-in-project)
  )

(defun gr/ido ()
  "Setup Ido, like k20e does."

  (require 'ido)
  (require 'ido-vertical-mode)

  (add-to-list 'ido-ignore-files "\\.DS_Store")

  ;; Boring arrows be gone!
  (setq ido-vertical-decorations '("\n"  ; left bracket around prospect list
				   ""    ; right bracket around prospect list
				   "\n"  ; separator between prospects, depends on `ido-separator`
				   "\n▼" ; inserted at the end of a truncated list of prospects
				   "["   ; left bracket around common match string
				   "]"   ; right bracket around common match string
				   " ✘"  ; no match
				   " ✔"  ; matched
				   " [Not readable]"
				   " [Too big]"
				   " ?"  ; confirm
				   "\n"  ; left bracket around the sole remaining completion
				   " ✔"  ; right bracket around the sole remaining completion
				   ))

  ;; (add-hook 'ido-minibuffer-setup-hook
  ;;	    #'(lambda ()
  ;;		"Bump up minibuffer text size and height."
  ;;		(text-scale-set 3)
  ;;		(setq max-mini-window-height 20)))

  ;; Avoid `ido-vertical-mode' from eating M-p.
  (setq ido-vertical-define-keys nil)

  (defun gr/ido-setup()
    "Setup key map and theme faces."

    (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
    (define-key ido-completion-map (kbd "C-p") 'ido-prev-match)
    (define-key ido-completion-map (kbd "<up>") 'ido-prev-match)
    (define-key ido-completion-map (kbd "<down>") 'ido-next-match)
    (define-key ido-completion-map (kbd "<left>") 'ido-vertical-prev-match)
    (define-key ido-completion-map (kbd "<right>") 'ido-vertical-next-match)

    (define-key ido-completion-map (kbd "C-h") 'delete-backward-char)

    ;; Theme!
    (let ((match (face-attribute 'font-lock-string-face :foreground))
	  (highlight (face-attribute 'font-lock-keyword-face :foreground)))
      (custom-set-faces `(ido-first-match ((t (:foreground ,match))))
			`(ido-only-match ((t (:foreground ,match)))))))

  (add-hook 'ido-setup-hook 'gr/ido-setup)

  (ido-mode t)
  (ido-vertical-mode t)
  ;; (ido-ubiquitous-mode t)

  (setq ido-enable-flex-matching t
	ido-auto-merge-work-directories-length -1
	ido-create-new-buffer 'always
	ido-everywhere t
	ido-ignore-extensions t
	ido-show-dot-for-dired t
	ido-max-file-prompt-width 0.2
	ido-use-faces t
	ido-use-filename-at-point 'guess
	)

  (defun ido-recentf-open ()
    "Use `ido-completing-read' to \\[find-file] a recent file"
    (interactive)
    (if (find-file (ido-completing-read "Find recent file: " recentf-list))
	(message "Opening file...")
      (message "Aborting")))

  (global-set-key (kbd "C-x C-r") 'ido-recentf-open)
  )

(defun gr/keybinds ()
   "Rebind some keys."

   ;; unset
   (global-unset-key (kbd "C-h"))  ; just use <f1> so this can be del-back-char
   (global-unset-key (kbd "<f3>"))  ; was kmacro-start-macro-or-insert-counter
   (global-unset-key (kbd "<f4>"))  ; was kmacro-end-or-call-macro
   (global-unset-key (kbd "C-M-v")) ; was scroll-other-window, free up for jumpcut

   ;; set
   (global-set-key (kbd "C-c DEL") 'join-line)
   (global-set-key (kbd "C-h") 'delete-backward-char)
   (global-set-key (kbd "C-S-k") 'kill-whole-line)
   (global-set-key (kbd "C-<") 'beginning-of-buffer)
   (global-set-key (kbd "C->") 'end-of-buffer)
   (global-set-key (kbd "s-=") 'text-scale-increase)
   (global-set-key (kbd "s--") 'text-scale-decrease)
   (global-set-key (kbd "s-0") '(lambda () (interactive) (text-scale-set 0)))
   (global-set-key (kbd "C-x s-b") 'gr/display-buffer-file-name)
   (global-set-key (kbd "<f4>") 'delete-trailing-whitespace)
   (global-set-key (kbd "<f5>") (lambda () (interactive)
				  (if (not (buffer-modified-p))
				      (revert-buffer :ignore-auto :noconfirm)
				    (revert-buffer))))

   ;; try to break old habits
   (when window-system
     (global-set-key (kbd "C-x C-c") 'gr/ask-before-closing))

  )

(defun gr/keymaps ()
  "Remap some keys on macs."
  (if (equal system-type 'darwin)
    (progn
      ;; Command as meta.
      ;;(setq ns-command-modifier 'meta)

      ;; Option as hyper.
      ;;(setq ns-option-modifier 'hyper)

      ;; fn as super.
      (setq ns-function-modifier 'super)

      ;; See https://github.com/Homebrew/homebrew/commit/49c85b89753d42cc4ec2fee9607a608b3b14ab33?w=1
      (setq ns-use-srgb-colorspace t)

      ;; Trackpad taming.
      (setq
       mouse-wheel-scroll-amount '(0.001)
       mouse-wheel-progressive-speed nil
       scroll-step 1
       scroll-conservatively 10000
       auto-window-vscroll nil))))

(defun gr/line-numbering ()
  "Line numbering and highlighting policies."
  (global-linum-mode 1)
  (global-hl-line-mode 1)
  (column-number-mode t)
  (show-paren-mode)
  (electric-pair-mode 1)

  (require 'hlinum)
  (hlinum-activate)

  (require 'fill-column-indicator)
  (define-globalized-minor-mode my-global-fci-mode fci-mode turn-on-fci-mode)
  (my-global-fci-mode 1)
  (setq-default fill-column 120)

  (global-set-key (kbd "<f3>") 'linum-mode)
  (global-diff-hl-mode)
  )

(defun gr/multiple-cursors ()
  "Multiple Cursor Setup."
  (require 'multiple-cursors)

  (defun gr/mark-next (extended)
  "Wrap multiple-cursors mark-more/next.
Call `mc/mark-next-like-this' without a prefix argument.
Argument EXTENDED Prefix argument to call function `mc/mark-more-like-this-extended'."
  (interactive "P")
  (if extended
      (call-interactively 'mc/mark-more-like-this-extended)
    (call-interactively 'mc/mark-next-like-this)))

(defun gr/mark-previous (extended)
  "Wrap multiple-cursors mark-more/previous.
Call `mc/mark-previous-like-this' without a prefix argument.
Argument EXTENDED Prefix argument to call function `mc/mark-more-like-this-extended'."
  (interactive "P")
  (if extended
      (call-interactively 'mc/mark-more-like-this-extended)
    (call-interactively 'mc/mark-previous-like-this)))

  (global-set-key (kbd "s-g") 'gr/mark-next)
  (global-set-key (kbd "s-h") 'gr/mark-previous)
  (global-set-key (kbd "M-g RET") 'mc/mark-all-like-this)
  (global-set-key (kbd "C-s-<mouse-1>") 'mc/add-cursor-on-click)

  )

(defun gr/set-dirs ()
  "Set save and trash dirs."
  (setq backup-directory-alist
	`((".*" . ,temporary-file-directory)))
  (setq auto-save-file-name-transforms
	`((".*" ,temporary-file-directory t)))
  (setq trash-directory (expand-file-name "~/.emacs.d/trashes")
	delete-by-moving-to-trash t)

  (defvar gr/backup-dir (expand-file-name "backup" user-emacs-directory)
  "A single directory for storing backup files within.")

  (unless (file-exists-p gr/backup-dir) (make-directory gr/backup-dir))

  (setq backup-by-copying t
	backup-directory-alist `(("." . ,gr/backup-dir))
	delete-old-versions t
	version-control t))

(defun gr/autocomplete ()
  "Setup autocomplete."

  (require 'auto-complete)
  (require 'auto-complete-config)
  (ac-config-default)

  (global-set-key [C-tab] 'auto-complete)
  )

(defun gr/flycheck ()
  (add-hook 'after-init-hook #'global-flycheck-mode)
  (add-hook 'flycheck-mode-hook 'flycheck-color-mode-line-mode)

  ;; Easier navigation for errors/warnings/etc.
  ;; ◀◀
  (global-set-key (kbd "<f7>") 'flycheck-previous-error)
  ;; ▶▶
  (global-set-key (kbd "<f9>") 'flycheck-next-error)
  )

(defun gr/python ()
  "Setup python IDE."
  (setq jedi:environment-root (expand-file-name "~/venv/emacs"))
  (add-hook 'python-mode-hook 'jedi:setup)
  (setq jedi:complete-on-dot t)


  (require 'flycheck-pyflakes)
  (add-hook 'python-mode-hook 'flycheck-mode)
  (add-to-list 'flycheck-disabled-checkers 'python-flake8)
  (add-to-list 'flycheck-disabled-checkers 'python-pylint)

  (add-hook 'python-mode-hook
	    (lambda () (interactive)
	      (set-fill-column 120)))

  (global-set-key (kbd "<f8>") 'python-check)
  )

(defun gr/go ()
  "Setup Go IDE."

  ;; go get golang.org/x/tools/cmd/goimports
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save)

  (when (memq window-system '(mac ns))
     (exec-path-from-shell-copy-env "GOPATH"))

  ;; go get golang.org/x/tools/cmd/oracle
  (load-file "$GOPATH/src/golang.org/x/tools/cmd/oracle/oracle.el")

  ;; go get github.com/nsf/gocode
  (require 'go-autocomplete (expand-file-name "~/local/go/src/github.com/nsf/gocode/emacs/go-autocomplete.el"))

  (require 'auto-complete-config)
  )

(defun gr/webmode ()
  (require 'autopair)
  (require 'web-mode)

  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

  (defun gr/web-mode-hook ()
    (autopair-mode -1)
    (setq web-mode-engines-alist '(("django" . "\\.html?\\'"))
	  web-mode-markup-indent-offset 2))

  (add-hook 'web-mode-hook 'gr/web-mode-hook)
)

(gr/no-bars-held)
(gr/keybinds)
(gr/keymaps)
(gr/server)
(gr/set-dirs)
(gr/setup-cask-and-pallet)
(gr/ag)
(gr/expand-region)
(gr/ido)
(gr/find-file-in-project)
(gr/line-numbering)
(gr/multiple-cursors)
(gr/autocomplete)
(gr/flycheck)
(gr/python)
(gr/go)
(gr/webmode)

;; Add sort-words
(defun sort-words (reverse beg end)
      "Sort words in region alphabetically, in REVERSE if negative.
    Prefixed with negative \\[universal-argument], sorts in reverse.

    The variable `sort-fold-case' determines whether alphabetic case
    affects the sort order.

    See `sort-regexp-fields'."
      (interactive "*P\nr")
      (sort-regexp-fields reverse "[^[:space:]]+" "\\&" beg end))
;;      (sort-regexp-fields reverse "\\w+" "\\&" beg end))

;; Automatically reload buffers when files change on disk.
(global-auto-revert-mode 1)

;; shut it
(setq ring-bell-function 'ignore)

;; disable lockfiles
(setq create-lockfiles nil)

;; copy clipboard onto kill ring
(setq save-interprogram-paste-before-kill t)

;; keep a list of recently opened files
(recentf-mode 1)
(setq recentf-max-saved-items 500)

;; save/restore opened files
(desktop-save-mode 1)

;; linkify
(goto-address-mode 1)

;; always follow symlinks to vc files
(setq vc-follow-symlinks t)

;; symlink'd into /usr/local/share/emacs/site-lisp/
(require 'protobuf-mode)

;; automatically wrap searches
(defadvice isearch-search (after isearch-no-fail activate)
  (unless isearch-success
    (ad-disable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)
    (isearch-repeat (if isearch-forward 'forward))
    (ad-enable-advice 'isearch-search 'after 'isearch-no-fail)
    (ad-activate 'isearch-search)))

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(set-face-attribute 'default nil :font "Source Code Pro-14")
(set-face-attribute 'region nil :background "#70B8FF")

;;; end of init.el
