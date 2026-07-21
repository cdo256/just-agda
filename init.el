; You will most likely need to adjust this font size for your system!
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

;; Store customizations in etc/custom.el instead of init.el
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))

(use-package no-littering)

;; no-littering doesn't set this by default so we must place
;; auto save files in the same path as it uses for sessions
(setq auto-save-file-name-transforms
      `((".*" ,(no-littering-expand-var-file-name "auto-save/") t)))

;; Disable lockfiles (.#xyz) entirely
(setq create-lockfiles nil)

(let ((backup-dir (expand-file-name "backups/" user-emacs-directory)))
  (make-directory backup-dir t)
  (setq backup-directory-alist `(("." . ,backup-dir))))

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
    "bv"   'revert-buffer-quick
    "f"    '(:ignore t :which-key "file")
    "fc"   'counsel-rg
    "ff"   'projectile-find-file
    "fF"   'counsel-find-file
    "fL"   'counsel-locate
    "fr"   'counsel-recentf
    "gg"   'magit
    "gs"   'magit
    "p"    'projectile-command-map
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
  (defun my/agda-set-evil-surround-pair (key left right)
    (setq evil-surround-operator-alist
          (assq-delete-all key evil-surround-operator-alist))
    (push `(,key ,left . ,right) evil-surround-operator-alist))

  (defun my/agda-embrace-pair ()
    (dolist (pair '((?h . ("{!" . "!}"))
                    (?B . ("⟦ " . " ⟧"))
                    (?V . ("∥ " . " ∥"))
                    (?R . ("⦃ " . " ⦄"))
		    (?A . ("⟨ " . " ⟩"))))
      (embrace-add-pair (car pair) (cadr pair) (cddr pair))
      (my/agda-set-evil-surround-pair (car pair) (cadr pair) (cddr pair)))
    (unless (bound-and-true-p evil-embrace-evil-surround-integration)
      (evil-embrace-enable-evil-surround-integration)))
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
  (prescient-persist-mode 1)
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

(use-package proof-site
  :ensure nil
  :demand t
  :mode (("\\.ny\\'" . narya-mode)
         ("\\.nyo\\'" . narya-mode))
  :init
  (setq proof-output-tooltips nil
        proof-three-window-mode-policy 'hybrid
        proof-three-window-enable t)
  :config
  (add-to-list 'load-path "/home/cdo/src/narya/proofgeneral")
  (add-to-list 'proof-assistant-table '(narya "Narya" "ny" nil (".nyo")))
  (unless (fboundp 'narya-mode)
    (defun narya-mode ()
      "Load Narya Proof General support and enter `narya-mode'."
      (interactive)
      (proof-ready-for-assistant 'narya "Narya")
      (load-library "narya")
      (narya-mode))))

(with-eval-after-load 'narya
  (add-hook 'narya-mode-hook (lambda () (set-input-method "Agda")))
  (evil-define-key 'normal narya-mode-map
    "," nil
    ",f" 'narya-next-hole
    ",b" 'narya-previous-hole
    ", " 'narya-solve-hole
    ",L" 'narya-show-all-holes
    ",l" 'proof-process-buffer
    ",," 'narya-show-hole
    ",A" 'proof-interrupt-process
    ",R" 'proof-shell-restart
    ",u" 'proof-undo-last-successful-command
    ",c" 'narya-split-hole
    ",g" nil
    ",gg" 'proof-goto-command-start
    ",G" 'proof-goto-command-end)
  (evil-define-key 'normal narya-mode-map
    (kbd ", <return>") 'proof-script-complete))

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge
  :after magit)

(use-package evil-nerd-commenter
  :bind ("M-/" . evilnc-comment-or-uncomment-lines))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


(with-eval-after-load 'elisp-mode
  (evil-define-key 'normal emacs-lisp-mode-map
    ","  nil 
    ",e"  nil
    ",eb"  'eval-buffer
    ",er"  'eval-region
    ",es"  'eval-last-sexp
    ",e:"  'eval-expression))

(setq auto-mode-alist
  (append '(("\\.agda\\'" . agda2-mode)
            ("\\.lagda.md\\'" . agda2-mode))
          auto-mode-alist))

(defun agda-comment--scan-block-comment-end ()
  (when (looking-at "{-")
    (goto-char (+ (point) 2))
    (let ((depth 1))
      (while (and (> depth 0)
                  (re-search-forward "{-\\|-}" nil t))
        (setq depth (+ depth (if (string= (match-string 0) "{-") 1 -1))))
      (and (= depth 0) (point)))))

(defun agda-comment--region-block-bounds (beg end)
  (save-excursion
    (let ((start (progn
                   (goto-char beg)
                   (skip-chars-forward " \t\n" end)
                   (point)))
          (finish (progn
                    (goto-char end)
                    (skip-chars-backward " \t\n" beg)
                    (point))))
      (when (< start finish)
        (goto-char start)
        (when (looking-at "{-")
          (let ((close-end (agda-comment--scan-block-comment-end)))
            (when (and close-end (= close-end finish))
              (list start (+ start 2) (- close-end 2) close-end))))))))

(defun agda-comment--containing-block-bounds (beg end)
  (save-excursion
    (goto-char (point-min))
    (let (result stack)
      (while (and (not result)
                  (re-search-forward "{-\\|-}" nil t))
        (if (string= (match-string 0) "{-")
            (push (match-beginning 0) stack)
          (when stack
            (let ((start (pop stack))
                  (close-end (point)))
              (when (and (<= start beg)
                         (>= close-end end))
                (setq result (cons start close-end)))))))
      result)))

(defun agda-comment--trailing-block-bounds ()
  (save-excursion
    (goto-char (point-max))
    (skip-chars-backward " \t\n")
    (let ((close-end (point)))
      (when (and (>= close-end (+ (point-min) 2))
                 (progn
                   (goto-char (- close-end 2))
                   (looking-at "-}")))
        (let ((depth 1)
              start)
          (while (and (> depth 0)
                      (re-search-backward "{-\\|-}" nil t))
            (setq depth (+ depth (if (string= (match-string 0) "-}") 1 -1)))
            (when (= depth 0)
              (setq start (match-beginning 0))))
          (when start
            (cons start close-end)))))))

(defun agda-comment--delimiters (beg end)
  (if (save-excursion
        (goto-char beg)
        (search-forward "\n" end t))
      (cons (if (save-excursion
                  (goto-char beg)
                  (bolp))
                "{-\n"
              "{- ")
            (if (save-excursion
                  (goto-char end)
                  (bolp))
                "-}"
              " -}"))
    '("{- " . " -}")))

(defun agda-comment--ends-in-newline-p (end)
  (and (> end (point-min))
       (eq (char-before end) ?\n)))

(defun agda-comment--line-comment-region (beg end)
  (save-excursion
    (goto-char beg)
    (while (< (point) end)
      (beginning-of-line)
      (unless (looking-at "[ \t]*$")
        (insert "-- ")
        (setq end (+ end 3)))
      (forward-line 1))))

(defun agda-comment--line-uncomment-region (beg end)
  (save-excursion
    (goto-char beg)
    (while (< (point) end)
      (beginning-of-line)
      (when (looking-at "-- ?")
        (let ((len (length (match-string 0))))
          (replace-match "")
          (setq end (- end len))))
      (forward-line 1))))

(defun agda-comment--uncomment-block-bounds (start close-end)
  (let* ((open-start start)
         (open-end (+ start 2))
         (close-start (- close-end 2))
         (strip-newlines (and (eq (char-after open-end) ?\n)
                              (eq (char-before close-start) ?\n)))
         (strip-spaces (and (not strip-newlines)
                            (eq (char-after open-end) ?\s)
                            (eq (char-before close-start) ?\s)))
         (open-limit (+ open-end (if (or strip-newlines strip-spaces) 1 0)))
         (close-begin (- close-start (if (or strip-newlines strip-spaces) 1 0))))
    (delete-region close-begin close-end)
    (delete-region open-start open-limit)))

(defun agda-comment--block-comment-region (beg end)
  (let* ((delimiters (agda-comment--delimiters beg end))
         (open (car delimiters))
         (close (cdr delimiters))
         (close-pos (+ end (length open))))
    (goto-char beg)
    (insert open)
    (goto-char close-pos)
    (insert close)))

(defun agda-comment--block-comment-until-eof (beg end)
  (goto-char beg)
  (insert "{-\n")
  (goto-char (+ end 3))
  (unless (bolp)
    (insert "\n"))
  (insert "-}"))

(defun agda-comment-region-function (beg end &optional arg)
  (if (or (consp arg)
          (and (numberp arg) (< arg 0)))
      (agda-uncomment-region-function beg end)
    (cond
     ((agda-comment--containing-block-bounds beg end)
      (agda-uncomment-region-function beg end))
     ((comment-only-p beg end)
      (agda-comment--line-uncomment-region beg end))
     ((agda-comment--ends-in-newline-p end)
      (agda-comment--line-comment-region beg end))
     (t
      (agda-comment--block-comment-region beg end)))))

(defun agda-uncomment-region-function (beg end &optional _arg)
  (let ((bounds (or (let ((exact (agda-comment--region-block-bounds beg end)))
                      (when exact
                        (cons (nth 0 exact) (nth 3 exact))))
                    (agda-comment--containing-block-bounds beg end))))
    (if bounds
        (agda-comment--uncomment-block-bounds (car bounds) (cdr bounds))
      (agda-comment--line-uncomment-region beg end))))

(defun agda-comment--extend-trailing-block (beg)
  (let ((bounds (agda-comment--trailing-block-bounds)))
    (when (and bounds (> (car bounds) beg))
      (let* ((start (car bounds))
             (open-end (+ start 2))
             (after-open (char-after open-end))
             (delete-end (+ open-end (if (or (eq after-open ?\n)
                                             (eq after-open ?\s))
                                         1
                                       0)))
             (open (car (agda-comment--delimiters beg (point-max)))))
        (delete-region start delete-end)
        (goto-char beg)
        (insert open)
        t))))

(defun agda-comment-until-eof ()
  "Comment or uncomment from the current line to the end of the buffer."
  (interactive)
  (save-excursion
    (let ((beg (line-beginning-position))
          (end (point-max)))
      (cond
       ((agda-comment--region-block-bounds beg end)
        (agda-uncomment-region-function beg end))
       ((agda-comment--containing-block-bounds beg beg)
        (agda-uncomment-region-function beg beg))
       ((comment-only-p beg end)
        (agda-uncomment-region-function beg end))
       ((agda-comment--extend-trailing-block beg))
       (t
        (agda-comment--block-comment-until-eof beg end))))))

(defun agda-block-comment-or-uncomment-region (beg end)
  (interactive "r")
  (if (or (agda-comment--region-block-bounds beg end)
          (agda-comment--containing-block-bounds beg end))
      (agda-uncomment-region-function beg end)
    (agda-comment--block-comment-region beg end)))

(defun agda-block-comment-dwim ()
  (interactive)
  (if (use-region-p)
      (agda-block-comment-or-uncomment-region (region-beginning) (region-end))
    (let ((bounds (agda-comment--line-region-bounds)))
      (agda-block-comment-or-uncomment-region (car bounds) (cdr bounds)))))

(defun agda-comment-or-uncomment-region (beg end)
  (interactive "r")
  (if (or (agda-comment--region-block-bounds beg end)
          (comment-only-p beg end))
      (agda-uncomment-region-function beg end)
    (agda-comment-region-function beg end)))

(defun agda-comment--line-region-bounds ()
  (if (use-region-p)
      (let* ((beg (region-beginning))
             (end (region-end))
             (line-beg (save-excursion
                         (goto-char beg)
                         (line-beginning-position)))
             (line-end (save-excursion
                         (goto-char end)
                         (if (and (> end beg) (bolp))
                             end
                           (line-end-position)))))
        (cons line-beg line-end))
    (cons (line-beginning-position) (line-end-position))))

(defun agda-comment--whole-line-region-p ()
  (and (use-region-p)
       (let ((beg (region-beginning))
             (end (region-end)))
         (and (save-excursion
                (goto-char beg)
                (bolp))
              (save-excursion
                (goto-char end)
                (or (bolp) (eolp)))))))

(defun agda-comment--inline-comment-bounds ()
  (let* ((beg (if (use-region-p)
                  (region-beginning)
                (line-beginning-position)))
         (end (save-excursion
                (goto-char beg)
                (line-end-position))))
    (cons beg end)))

(defun agda-comment--inline-toggle (beg end)
  (save-excursion
    (goto-char beg)
    (if (looking-at "-- ?")
        (replace-match "")
      (insert "-- "))))

(defun agda-line-comment-dwim ()
  (interactive)
  (cond
   ((and (use-region-p) (not (agda-comment--whole-line-region-p)))
    (let ((bounds (agda-comment--inline-comment-bounds)))
      (agda-comment--inline-toggle (car bounds) (cdr bounds))))
   (t
    (let ((bounds (agda-comment--line-region-bounds)))
      (if (comment-only-p (car bounds) (cdr bounds))
          (agda-comment--line-uncomment-region (car bounds) (cdr bounds))
        (agda-comment--line-comment-region (car bounds) (cdr bounds)))))))

(defun agda-comment-line (&optional n)
  "Comment or uncomment whole lines using Agda block comments."
  (interactive "p")
  (let* ((n (or n 1))
         (bounds (if (use-region-p)
                     (cons (save-excursion
                             (goto-char (region-beginning))
                             (line-beginning-position))
                           (save-excursion
                             (goto-char (max (region-beginning)
                                             (1- (region-end))))
                             (line-end-position)))
                   (if (>= n 0)
                       (cons (line-beginning-position)
                             (save-excursion
                               (forward-line (max 0 (1- n)))
                               (line-end-position)))
                     (cons (save-excursion
                             (forward-line n)
                             (line-beginning-position))
                           (save-excursion
                             (line-end-position))))))
         (beg (car bounds))
         (end (cdr bounds)))
    (agda-comment-or-uncomment-region beg end)
    (goto-char end)))

(defun agda-comment-setup ()
  (setq-local comment-region-function #'agda-comment-region-function)
  (setq-local uncomment-region-function #'agda-uncomment-region-function))

(add-hook 'agda2-mode-hook #'agda-comment-setup)

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
    ",=" 'agda2-show-constraints
    ",?" 'agda2-show-goals
    ",m" 'agda2-elaborate-give
    ",z" 'agda2-search-about-toplevel
    ",-" 'agda-line-comment-dwim
    ",;" 'agda-comment-until-eof
    ",:" 'agda-block-comment-dwim

    "M-." 'agda2-goto-definition-keyboard
    "M-," 'agda2-go-back)

  (evil-define-key 'visual agda2-mode-map
    ",-" 'agda-line-comment-dwim
    ",:" 'agda-block-comment-dwim)

  (define-key agda2-mode-map [remap comment-line] #'agda-comment-line))

(setq agda-input-user-translations
      '(("^-1" . ("⁻¹"))
        ("sym" . ("˘"))
        ("\\\\" . ("∖")))) ;; Triple backslash -> \setminus

(defun agda-input-setup-percent-delimiter (&rest _)
  (with-temp-buffer
    (set-input-method "Agda")
    (define-key (quail-translation-keymap) "%" #'quail-select-current)))

(with-eval-after-load 'agda-input
  (advice-add 'agda-input-setup :after #'agda-input-setup-percent-delimiter)
  (agda-input-setup-percent-delimiter))

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

(require 'atomic-chrome)
