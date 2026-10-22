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

(use-package nix-ts-mode
  :ensure t)
(use-package julia-ts-mode
  :ensure t)
(use-package treesit-auto
  :ensure t
  :custom
  (treesit-auto-install nil)  ; Nix provides grammars
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

(use-package julia-snail
  :ensure t
  :after julia-ts-mode
  :hook (julia-ts-mode . julia-snail-mode)
  :custom
  (julia-snail-extra-args '("--project=@.")))

(use-package eglot
  :ensure nil
  :hook (((julia-mode julia-ts-mode) . eglot-ensure)
	 (LaTeX-mode . eglot-ensure)
	 ((yaml-mode yaml-ts-mode) . eglot-ensure)
	 ((markdown-mode gfm-mode) . eglot-ensure))
  :custom
  (eglot-workspace-configuration
   '(:texlab (:chktex (:onOpenAndSave t :onEdit t))))
  :config
  (add-to-list 'eglot-server-programs
	       '(julia-ts-mode . ("julia-lsp"))
	       '((LaTeX-mode plain-TeX-mode) . ("texlab"))
	       '((yaml-mode yaml-ts-mode) . ("yaml-language-server" "--stdio"))
	       '((markdown-mode gfm-mode)  . ("marksman" "server"))))

(use-package treemacs
  :ensure t
  :defer t
  :bind (("<f8>" . treemacs)
         ("M-0"  . treemacs-select-window))
  :custom
  (treemacs-width 32)
  :config
  (treemacs-follow-mode t)
  (treemacs-filewatch-mode t)
  (treemacs-project-follow-mode t)
  (treemacs-git-mode 'deferred))

(use-package treemacs-magit
  :ensure t
  :after (treemacs magit))

(use-package company
  :ensure t
  :hook (after-init . global-company-mode))

(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . turn-on-reftex)
	 (LaTeX-mode . LaTeX-math-mode)
	 (LaTeX-mode . TeX-fold-mode)
	 (LaTeX-mode . (lambda () (setq TeX-command-default "LaTeXMk"))))
  :custom
  (TeX-PDF-mode t)
  (TeX-auto-save t)
  (TeX-parse-self t)
  (TeX-view-program-selection '((output-pdf "PDF Tools")))
  ;; SyncTeX
  (TeX-source-correlate-mode t)
  (TeX-source-correlate-start-server t)
  (TeX-source-correlate-method 'synctex)
  (reftex-plug-into-AUCTeX t)
  :config
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer))

(use-package cdlatex
  :ensure t
  :after latex
  :hook (LaTeX-mode . turn-on-cdlatex))

(use-package citar
  :ensure t
  :after latex
  :custom (citar-bibliography '("~/bib/references.bib"))
  :hook (LaTeX-mode . citar-capf-setup))

(use-package auctex-cont-latexmk
  :ensure t
  :after latex
  :hook (LaTeX-mode . auctex-cont-latexmk-mode))

(use-package jinx
  :ensure nil
  :hook (LaTeX-mode . jinx-mode))

(use-package apheleia
  :ensure t
  :config
  (dolist (formatter '((nixfmt      . ("nixfmt"))
                       (runic       . ("runic"))
                       (shfmt       . ("shfmt"))
                       (latexindent . ("latexindent" "-"))
                       (bibtex-tidy . ("bibtex-tidy" "--quiet"))))
    (push formatter apheleia-formatters))
  
  (dolist (mapping '(((nix-mode nix-ts-mode)             . nixfmt)
                     ((c-mode c++-mode c-ts-mode c++-ts-mode) . clang-format)
                     ((julia-mode julia-ts-mode)         . runic)
                     ((yaml-mode yaml-ts-mode)           . prettier-yaml)
                     ((markdown-mode gfm-mode)           . prettier-markdown)))
    (dolist (mode (car mapping))
      (push (cons mode (cdr mapping)) apheleia-mode-alist)))
  (apheleia-global-mode +1))

(use-package flymake-yamllint
  :ensure t
  :hook
  ((yaml-mode yaml-ts-mode) . flymake-yamllint-setup))
