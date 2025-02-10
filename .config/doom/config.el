;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Marcus Wilhelm"
      user-mail-address "mail@marcuswilhelm.de")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
(setq doom-font (font-spec :family "Source Code Pro" :size 16)
      doom-variable-pitch-font (font-spec :family "Noto Serif" :size 16)
      doom-big-font (font-spec :family "Source Code Pro" :size 20))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.


;; https://orgmode.org/guide/Progress-Logging.html
(setq org-log-done 'time)

(after! evil-snipe
  (setq evil-snipe-scope 'whole-visible
        evil-snipe-repeat-scope 'whole-visible))

(setq display-line-numbers-type 'relative)

(use-package-hook! evil
  :pre-init
  (setq evil-respect-visual-line-mode t) ;; sane j and k behavior
  t)

(setq evil-respect-visual-line-mode t) ;; sane j and k behavior

(add-hook 'text-mode-hook #'auto-fill-mode)

(after! latex
  (defun my/configure-latex ()
    "Customize LaTeX."
    ;; Automatically set fill column.
    (set-fill-column 70)
    (auto-fill-mode)
    ;; Ensure the double-space sentence end is set for LaTeX modes.
    (setq sentence-end-double-space t))

  ;; Add your custom function to LaTeX-mode-hook.
  (add-hook 'LaTeX-mode-hook #'my/configure-latex)

  ;; Set Zathura as the default PDF viewer
  (setq TeX-view-program-selection '((output-pdf "Zathura"))
;;          TeX-view-program-list '(("Zathura"
;;           ("zathura --synctex-forward %n:1:%b %o" (mode-io-correlate t))))
  ))

;; Associate .tex files with LaTeX-mode
(add-to-list 'auto-mode-alist '("\\.tex\\'" . LaTeX-mode))

;; Set yasnippet directory
(setq yas-snippet-dirs '("~/.config/doom/snippets"))


(use-package! org-fragtog
  :load-path "~/.config/emacs/.local/straight/repos/org-fragtog"
  :hook (org-mode . org-fragtog-mode))

; (use-package! org-fragtog
; ;; https://www.reddit.com/r/emacs/comments/nkqaow/how_can_i_enable_inline_latex_previews_with_doom/
;   :ensure t
;   :after org
;   :hook (org-mode . org-fragtog) ; this auto-enables it when you enter an org-buffer, remove if you do not want this
;   :config
;   ;; whatever you want
;
;   )

(after! org
  ;; Ensure pretty entities and LaTeX rendering
  (setq org-pretty-entities t
        org-hide-emphasis-markers t
        org-format-latex-options (plist-put org-format-latex-options :scale 1.2)
        org-preview-latex-default-process 'dvisvgm
        org-preview-latex-image-directory (concat doom-cache-dir "ltximg/"))

  ;; Prevent gray background in Org mode
  (custom-set-faces
   '(org-block ((t (:background unspecified))))
   '(org-block-begin-line ((t (:background unspecified))))
   '(org-block-end-line ((t (:background unspecified))))
   '(org-latex-and-related ((t (:background unspecified)))))

  ;; Automatically render LaTeX fragments upon saving the file
  (add-hook 'org-mode-hook 'org-fragtog-mode)
  (add-hook 'org-mode-hook 'org-preview-latex-fragment))

;;
;; ChatGPT Session
;;

;; Org mode settings
(after! org
  (setq org-agenda-files '(list "~/org" "~/org/roam/inbox.org")
        org-capture-templates '(("t" "Todo" entry (file "~/org/roam/inbox.org")
                                 "* TODO %?\n%U\n%a\n" :clock-resume t)
                                ("n" "Note" entry (file+headline "~/org/roam/notes.org" "Notes")
                                 "* %u %?\n%a\n" :clock-resume t))
        org-log-done 'time
        org-log-into-drawer t))

;; Org-babel settings
(after! org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (latex . t))))

;; Better display of org files
(after! org
  (setq org-hide-emphasis-markers t)
  (setq org-agenda-files '("~/org" "~/org/roam")))

(setq calendar-week-start-day 1)


;; Org-roam settings
        ;;   (after! org-roam
        ;;     (setq org-roam-directory (file-truename "~/org/roam")
        ;;           org-roam-completion-everywhere t
        ;;           org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag))
        ;;           )
        ;;     (org-roam-db-autosync-mode)
        ;;     )
;; Org-roam primary and secondary directories configuration using use-package!
(use-package! org-roam
  :custom
  (org-roam-directory (file-truename "~/org/roam"))
  ;(org-roam-secondary-directory (file-truename "~/work/research/open/cptw_fpt/"))  ;; Secondary directory
  (org-roam-completion-everywhere t)
  (org-roam-node-display-template (concat "${title:*} " (propertize "${tags:10}" 'face 'org-tag)))
  :config
  ;; Enable autosync for primary directory
  (org-roam-db-autosync-mode)

;;;;  ;; Function to scan and link secondary directory
;;;;  (defun my/org-roam-secondary-scan ()
;;;;    (let ((org-roam-directory org-roam-secondary-directory))
;;;;      (org-roam-db-build-cache)))
;;;;
;;;;  ;; Add hook to automatically scan secondary directory after init
;;;;  (add-hook 'after-init-hook #'my/org-roam-secondary-scan)
;;;;
;;;;  ;; Synchronize the Org-roam buffer with the current node
;;;;  (add-hook 'find-file-hook 'org-roam-buffer-toggle-display)
;;;;  (add-hook 'org-mode-hook (lambda () (org-roam-buffer-toggle-display t)))
;;;;  (add-hook 'after-save-hook 'org-roam-buffer-refresh)
)

;; Keybinding to toggle the Org-roam buffer manually
;(map! :leader
;      :desc "Toggle Org-roam buffer" "n r b" #'org-roam-buffer-toggle)


;; Org-roam UI tweaks
(use-package! org-roam-ui
  :after org-roam
;  :hook (after-init . org-roam-ui-mode)
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start t))
