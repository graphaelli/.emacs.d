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

(defun gr/set-dirs ()
  "Set save and trash dirs."
  (setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))
  (setq trash-directory (expand-file-name "~/.emacs.d/trashes")
      delete-by-moving-to-trash t))  

(gr/no-bars-held)
(gr/keymaps)
(gr/set-dirs)

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;;; end of init.el
