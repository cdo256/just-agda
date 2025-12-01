;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 180)
(defvar efs/default-variable-font-size 180)

;; Make frame transparency overridable
(defvar efs/frame-transparency '(90 . 90))

;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)


(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

;; Set up the visible bell
(setq visible-bell t)

(column-number-mode)
(global-display-line-numbers-mode t)

;; Set frame transparency
(set-frame-parameter (selected-frame) 'alpha efs/frame-transparency)
(add-to-list 'default-frame-alist `(alpha . ,efs/frame-transparency))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-o") 'counsel-find-file)
(global-set-key (kbd "<C-tab>") 'next-buffer)
(global-set-key (kbd "<C-S-iso-lefttab>") 'previous-buffer)
(global-set-key (kbd "M-u") 'universal-argument)

(general-auto-unbind-keys)
(use-package general
  :after evil
  :config
  (general-create-definer efs/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (efs/leader-keys
    "b"    '(:ignore t :which-key "buffer")
    "f"    '(:ignore t :which-key "file")
    "p"    '(:ignore t :which-key "project")
    "t"    '(:ignore t :which-key "toggles")
    ; "bb"   'ivy-switch-buffer ; Apparently order matters and this makes it unhappy, but it's happy further down.
    " "    'counsel-M-x
    "/s"   'counsel-rg
    "/R"   'projectile-replace-regexp
    "<f1>" 'counsel-apropos
    "bb"   'ivy-switch-buffer
    "bm"   'view-echo-area-messages
    "bn"   'next-buffer
    "bs"   'scratch-buffer
    "bp"   'previous-buffer
    "f"    '(:ignore t :which-key "file")
    "fc"   'counsel-rg
    "ff"   'projectile-find-file
    "fF"   'counsel-find-file
    "fL"   'counsel-locate
    "fr"   'counsel-recentf
    "gg"   'magit
    "gs"   'magit
    "pd"   'projectile-dired
    "pf"   'projectile-find-file
    "hda"  'counsel-apropos
    "hi"   'counsel-info-lookup-symbol
    "hr"   'counsel-register
    "iu"   'counsel-unicode-char
    "tt"   '(counsel-load-theme :which-key "choose theme")
    "u"    'universal-argument
    "ym"   'counsel-mark-ring
    "yy"   'counsel-yank-pop
    ))

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal)
  (setq evil-shift-width 2))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1)
  (evil-define-key 'visual evil-surround-mode-map "s" 'evil-surround-region)
  (evil-define-key 'visual evil-surround-mode-map "S" 'evil-Surround-region))

(use-package embrace :ensure t)

(use-package evil-embrace
  :after evil-surround
  :ensure t
  :config
  (defun my/agda-embrace-pair ()
    (dolist (pair '((?h . ("{!" . "!}"))
                    (?B . ("⟦ " . " ⟧"))
                    (?V . ("∥ " . " ∥"))
                    (?R . ("⦃ " . " ⦄"))))
      (embrace-add-pair (car pair) (cadr pair) (cddr pair))
      (push pair evil-surround-operator-alist))
    (evil-embrace-enable-evil-surround-integration)
    (message "Embrace: %S" (assoc ?B embrace--pairs-list))
    (message "Evil: %S" (assoc ?B evil-surround-operator-alist)))
  (add-hook 'emacs-lisp-mode-hook #'my/agda-embrace-pair)
  (add-hook 'agda2-mode-hook #'my/agda-embrace-pair))

(use-package command-log-mode
  :commands command-log-mode)

(use-package doom-themes
  :init (load-theme 'manoj-dark t))

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package which-key
  :defer 0
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package ivy
  :diminish
  :bind (:map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :after ivy
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package ivy-prescient
  :after counsel
  :custom
  (ivy-prescient-enable-filtering nil)
  :config
  (ivy-prescient-mode 1))

(use-package helpful
  :commands (helpful-callable helpful-variable helpful-command helpful-key)
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;(use-package hydra
;  :defer t)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(efs/leader-keys
  "ts" '(hydra-text-scale/body :which-key "scale text"))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))


(with-eval-after-load 'org
  (org-babel-do-load-languages
      'org-babel-load-languages
      '((emacs-lisp . t)
      (python . t)))

  (push '("conf-unix" . conf-unix) org-src-lang-modes))


;; Automatically tangle our Emacs.org config file when we save it
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name user-emacs-directory))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)


(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (when (file-directory-p "~/src")
    (setq projectile-project-search-path '("~/src")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :after projectile
  :config (counsel-projectile-mode))

(use-package magit
  :commands magit-status
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


(with-eval-after-load 'emacs-lisp-mode
  (evil-define-key 'normal emacs-lisp-mode-map
    ","  nil ; '(:ignore t :which-key "Agda")
    ",e"  nil ; '(:ignore t :which-key "Agda")
    ",eb"  'eval-buffer
    ",er"  'eval-region
    ",es"  'eval-last-sexp
    ",e:"  'eval-expression))

(setq auto-mode-alist
  (append '(("\\.agda\\'" . agda2-mode)
            ("\\.lagda.md\\'" . agda2-mode))
          auto-mode-alist))

(with-eval-after-load 'agda2-mode
  (evil-define-key 'normal agda2-mode-map

    ","  nil ; '(:ignore t :which-key "Agda")
    ",l" 'agda2-load
    ",f" 'agda2-next-goal
    ",b" 'agda2-previous-goal
    ",r" 'agda2-refine
    ",t" 'agda2-goal-type
    ",e" 'agda2-show-context
    ",a" 'agda2-mimer-maybe-all
    ",h" 'agda2-helper-function-type
    ",d" 'agda2-infer-type-maybe-toplevel
    ",w" 'agda2-why-in-scope-maybe-toplevel
    ",n" 'agda2-compute-normalised-maybe-toplevel
    ",o" 'agda2-module-contents-maybe-toplevel
    ",c" 'agda2-make-case

    ",C" 'agda2-compile
    ",Q" 'agda2-quit
    ",R" 'agda2-restart
    ",A" 'agda2-abort
    ",D" 'agda2-remove-annotations
    ",H" 'agda2-display-implicit-arguments

    ",s" 'agda2-solve-maybe-all
    ", " 'agda2-give
    ",," 'agda2-goal-and-context
    ",." 'agda2-goal-and-context-and-inferred
    ",;" 'agda2-goal-and-context-and-checked
    ",=" 'agda2-show-constraints
    ",?" 'agda2-show-goals
    ",m" 'agda2-elaborate-give
    ",z" 'agda2-search-about-toplevel
    ",;" 'agda2-comment-dwim-rest-of-buffer

    "M-." 'agda2-goto-definition-keyboard
    "M-," 'agda2-go-back))

(setq agda-input-user-translations
      '(("^-1" . ("⁻¹"))
        ("sym" . ("˘"))
        ("\\\\" . ("∖")))) ;; Triple backslash -> \setminus

;(with-eval-after-load 'agda2-mode
;  ;; Use motion (or normal) state in *Agda information* buffers
;  (evil-set-initial-state 'agda2-info-mode 'motion)
;
;  ;; Make sure the usual window keys work there
;  (evil-define-key 'motion agda2-info-mode-map
;    (kbd "C-h") 'evil-window-left
;    (kbd "C-j") 'evil-window-down
;    (kbd "C-k") 'evil-window-up
;    (kbd "C-l") 'evil-window-right
;    (kbd "C-<left>")  'evil-window-left
;    (kbd "C-<down>")  'evil-window-down
;    (kbd "C-<right>") 'evil-window-right))
;    (kbd "C-<up>")    'evil-window-up

;; Preserve TAB indentation
(with-eval-after-load 'agda2-mode
  (define-key agda2-mode-map (kbd "TAB") 'eri-indent))

;; Unconditionally set Agda input mode in the minibuffer.
(defun set-agda-minibuffer-input ()
  (set-input-method "Agda"))

(add-hook 'minibuffer-setup-hook #'set-agda-minibuffer-input)


(use-package all-the-icons-dired
  :hook (dired-mode . all-the-icons-dired-mode))

(use-package dired-open
  :commands (dired dired-jump)
  :config
  ;; Doesn't work as expected!
  ;;(add-to-list 'dired-open-functions #'dired-open-xdg t)
  (setq dired-open-extensions '(("png" . "feh")
                                ("mkv" . "mpv"))))

(use-package dired-hide-dotfiles
  :hook (dired-mode . dired-hide-dotfiles-mode)
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "H" 'dired-hide-dotfiles-mode))

(use-package agda2-mode)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))

(with-eval-after-load 'agda2-mode
  (evil-define-key 'normal agda2-mode-map (kbd "gd")
                   'agda2-goto-definition-keyboard))

;; Simple, mode-agnostic window movement with Ctrl+arrows
(require 'windmove)
(windmove-default-keybindings 'control)

; (define-key evil-normal-state-map (kbd "C-<left>")  'evil-window-left)
; (define-key evil-normal-state-map (kbd "C-<down>")  'evil-window-down)
; (define-key evil-normal-state-map (kbd "C-<up>")    'evil-window-up)
; (define-key evil-normal-state-map (kbd "C-<right>") 'evil-window-right)
; (define-key evil-normal-state-map (kbd "C-h") 'evil-window-left)
; (define-key evil-normal-state-map (kbd "C-j") 'evil-window-down)
; (define-key evil-normal-state-map (kbd "C-k") 'evil-window-up)
; (define-key evil-normal-state-map (kbd "C-l") 'evil-window-right)
; 
; (define-key evil-motion-state-map (kbd "C-<left>")  'evil-window-left)
; (define-key evil-motion-state-map (kbd "C-<down>")  'evil-window-down)
; (define-key evil-motion-state-map (kbd "C-<up>")    'evil-window-up)
; (define-key evil-motion-state-map (kbd "C-<right>") 'evil-window-right)
; (define-key evil-motion-state-map (kbd "C-h") 'evil-window-left)
; (define-key evil-motion-state-map (kbd "C-j") 'evil-window-down)
; (define-key evil-motion-state-map (kbd "C-k") 'evil-window-up)
; (define-key evil-motion-state-map (kbd "C-l") 'evil-window-right)

(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-h") 'windmove-left)

(with-eval-after-load 'compile
  ;; Option A: unbind so your global motion bindings apply
  (dolist (map '(compilation-mode-map compilation-minor-mode-map))
    (evil-define-key 'normal (symbol-value map)
      (kbd "C-j") nil
      (kbd "C-k") nil)
    (evil-define-key 'motion (symbol-value map)
      (kbd "C-j") nil
      (kbd "C-k") nil)))
