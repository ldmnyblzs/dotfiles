{ pkgs, config, ... }:
let
  mkAddon = slug: {
    installation_mode = "force_installed";
    install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
  };
  languagetool-ngrams-en = pkgs.fetchzip {
    url = "https://languagetool.org/download/ngram-data/ngrams-en-20150817.zip";
    hash = "sha256-v3Ym6CBJftQCY5FuY6s5ziFvHKAyYD3fTHr99i6N8sE=";
  };
  julia-custom = pkgs.julia.withPackages [
    "LanguageServer"
  ];
  julia-lsp = pkgs.writeShellScriptBin "julia-lsp" ''
      exec ${julia-custom}/bin/julia \
      -e 'using LanguageServer; runserver()'
      '';
in {
  home = {
    username = "ldmnyblzs";
    homeDirectory = "/home/ldmnyblzs";
    stateVersion = "26.05";
    packages = with pkgs; [
      krusader
      krename
      kdePackages.kget
      gimp
      onlyoffice-desktopeditors
      nixd
      nixfmt
      texliveFull # may not use most of it, but I have a 2TB drive
      ghostscript # required by AUCTeX
      enchant # for troubleshooting dictionaries
      teams-for-linux
      languagetool
      julia-custom
      julia-lsp
    ];
    file = {
      ".config/emacs" = {
        source = ../../emacs;
        recursive = true;
      };
    };
    sessionVariables = {
      MOZ_USE_XINPUT2 = "1";
    };
  };
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      package = null; # use the system package
      settings.user = {
        name = "Balazs Ludmany";
        email = "ludmany.balazs@cloud.bme.hu";
      };
    };
    emacs = {
      enable = true;
      package = pkgs.emacs30-pgtk;
      extraPackages = epkgs: with epkgs; [
        nix-mode
	      nixfmt
        vterm
        pdf-tools
        treesit-grammars.with-all-grammars
        sqlite3 # used by, for example, Org-roam
        jinx
      ];
    };
    password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
      settings = {
        PASSWORD_STORE_DIR = "${config.home.homeDirectory}/.password-store";
      };
    };
    gpg.enable = true;
    firefox = {
      enable = true;
      package = pkgs.firefox-esr;
      languagePacks = [ "en-US" ];
      nativeMessagingHosts = [ pkgs.kdePackages.plasma-browser-integration ];
      policies = {
        "3rdparty".Extensions = {
          "languagetool-webextension@languagetool.org" = {
            serverUrl = "http://localhost:8081/v2";
          };
        };
        AIControls.Default.Value = "blocked";
        AllowFileSelectionDialogs = true;
        AppAutoUpdate = false;
        BackgroundAppUpdate = false;
        BlockAboutAddons = true;
        BlockAboutConfig = true;
        BlockAboutProfiles = true;
        DisableFirefoxStudies = true;
        DisableFirefoxAccounts = true;
        DisablePocket = true;
        DisableProfileImport = true;
        DisableRemoteImprovements = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        EnableTrackingProtection = {
          Value = true;
          Category = "strict";
          Locked = true;
          #BaselineExceptions = true;
          #ConvenienceExceptions = true;
        };
        ExtensionSettings = {
          "*" = {
            installation_mode = "blocked";
            installation_sources = [];
          };
          "languagetool-webextension@languagetool.org" = mkAddon "languagetool";
          "uBlock0@raymondhill.net" = mkAddon "ublock-origin";
          "plasma-browser-integration@kde.org" = mkAddon "plasma-integration";
          "en-US@dictionaries.addons.mozilla.org" = mkAddon "english-us-dictionary";
          "hu@dictionaries.addons.mozilla.org" = mkAddon "hungarian-dictionary";
        };
        ExtensionUpdate = false;
        HardwareAcceleration = true;
        HttpsOnlyMode = "force_enabled";
        GenerativeAI = {
          Enabled = false;
          Locked = true;
        };
        InstallAddonsPermission = {
          Default = false;
        };
        IPProtectionAvailable = false;
        NoDefaultBookmarks = true;
        PictureInPicture = false;
        Preferences = {
          "browser.startup.page" = {
            Value = 3;
            Status = "default";
          };
          "browser.search.region" = {
            Value = "HU";
            Status = "locked";
          };
          "intl.accept_languages" = {
            Value = "hu, en-us, en";
            Status = "locked";
          };
          "widget.use-xdg-desktop-portal.file-picker" = {
            Value = 1;
            Status = "locked";
          };
        };
        PromptForDownloadLocation = true;
        RequestedLocales = [ "en-US" ];
        UseSystemPrintDialog = true;
      };
    };
  };
  systemd.user = {
    services.languagetool = {
      Unit = {
        Description = "LanguageTool Server";
      };
      Service = {
        ExecStart = "${pkgs.languagetool}/bin/languagetool-server --port 8081 --allow-origin '*' --languageModel ${languagetool-ngrams-en}";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
    # services.languagetool = {
    #   Unit = {
    #     Description = "LanguageTool Server";
    #     Requires = "languagetool.socket";
    #     After = "languagetool.socket";
    #   };
    #   Service = {
    #     ExecStart = "${pkgs.languagetool}/bin/languagetool-server --port 8081 --allow-origin '*'";
    #     TimeoutStopSec = "10";
    #   };
    # };
    # sockets.languagetool = {
    #   Unit = {
    #     Description = "LanguageTool Socket";
    #   };
    #   Socket = {
    #     ListenStream = "8081";
    #   };
    #   Install = {
    #     WantedBy = [ "sockets.target" ];
    #   };
    # };
  };
  services = {
    emacs = {
      enable = true;
      client.enable = true;
      defaultEditor = true;
    };
  };
}
