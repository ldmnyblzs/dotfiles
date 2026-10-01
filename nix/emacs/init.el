(require 'use-package)

(use-package emacs
  :init
  ;; init.el is symlinked from the Nix store, i.e., read-only
  ;; direct customizations into a different file
  ;; don't read it however, customization should be done through Nix declaratively
  (setq custom-file (locate-user-emacs-file "custom.el")))

(use-package package
  :init
  ;; (setq package-user-dir
  ;; 	(expand-file-name "emacs/elpa"
  ;; 			  (or (getenv "XDG_DATA_HOME")
  ;; 			      "~/.local/share")))
  :custom
  (package-archives '(("melpa" . "https://melpa.org/packages/")
                      ("gnu"   . "https://elpa.gnu.org/packages/"))))

(use-package use-package
  :custom
  (use-package-always-ensure nil)
  (use-package-verbose nil))

(use-package project
  :ensure nil
  :config
  (add-to-list 'project-vc-extra-root-markers "Project.toml"))

(use-package vterm
  :ensure nil
  :commands vterm)

(use-package pdf-tools
  :ensure nil
  :magic ("%PDF" . pdf-view-mode)
  :config
  (pdf-tools-install :no-query)
  :hook
  (pdf-view-mode . (lambda () (display-line-numbers-mode -1))))

(use-package magit
  :ensure t)

(use-package julia-ts-mode
  :ensure t
  :mode "\\.jl$")

(use-package julia-repl
  :ensure t
  :after julia-ts-mode
  :hook (julia-ts-mode . julia-repl-mode)
  :config
  (setq julia-repl-switches "--project=@.")
  (julia-repl-set-terminal-backend 'vterm))

(use-package eglot
  :ensure nil
  :hook (julia-ts-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
	       '(julia-ts-mode . ("julia-lsp"))))

(use-package tex
  :ensure auctex
  :custom
  (TeX-PDF-mode t)
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  ;; SyncTeX
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-start-server t)
  (TeX-source-correlate-method 'synctex)
  :config
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))
