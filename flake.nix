{
  description = "Eriks nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    # homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    # homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    # home-manager.url = "github:nix-community/home-manager/release-24.11";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nix-darwin, ... }:
  let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in
  let
    configuration = { pkgs, lib, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      environment.systemPackages = with pkgs;
        [
          # desktop applications
          google-chrome

          # essenstials
          wget
          bat
          pciutils
          iperf3
          jq
          mc
          mtr
          ncdu
          nmap
          ripgrep
          stow
          p7zip
          tldr
          eza
          yt-dlp

          # system info
          fastfetch
          cpufetch
          nerdfetch

          # activity monitoring
          htop
          btop
          bottom

          # development
          git
          gh            # GitHub CLI
          glab         # GitLab CLI
          opentofu
          hcloud        # Hetzner Cloud CLI
        ];

      fonts.packages = with pkgs; [
          # developers fonts
          dina-font
          fira
          fira-code
          fira-code-symbols
          jetbrains-mono
          julia-mono

          # nerd fonts
          nerd-fonts.fira-code
          nerd-fonts.jetbrains-mono
          nerd-fonts.meslo-lg
          nerd-fonts.inconsolata
          nerd-fonts.hack

      ];

      homebrew = {
        enable = true;

        taps = [
          "can1357/tap"
          "jotta/cli"
          "oven-sh/bun"
        ];

        brews = [
          # shell essentials
          "antidote"
          "starship"
          "stow"
          "zoxide"
          "fzf"

          # development
          "git"
          "gh"
          "git-lfs"
          "go"
          "helix"
          "terraform"
          "uv"
          "pnpm"
          "pipx"

          # language runtimes
          "openjdk@17"
          "python@3.9"
          "python@3.12"
          "oven-sh/bun/bun"

          # AI / ML tooling
          "hf"
          "llmfit"
          "ollama"
          "opencode"
          "rtk"
          "ccusage"
          "codeburn"
          "can1357/tap/omp"

          # cloud & containers
          "cloud-sql-proxy"
          "colima"
          "docker"
          "docker-buildx"

          # cloud storage
          "jotta/cli/jotta-cli"

          # background services
          "syncthing"
          "tailscale"
        ];

        casks = [
          # AI tools
          "claude"
          "claude-code@latest"
          "copilot-cli"
          "ollama-app"

          # terminals
          "warp"
          "ghostty"

          # communication
          "discord"
          "telegram"

          # media
          "spotify"

          # productivity & creative
          "drawio"
          "supacode"
          "handy"

          # cloud storage
          "dropbox"
          "jottacloud"
          "filen"

          # cloud & infra
          "gcloud-cli"
          "corretto@21"

          # background services
          "syncthing-app"
        ];

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "uninstall";
        };
      };

      # Don't manage PAM files (managed by IT)
      system.activationScripts.pam.text = lib.mkForce "";

      # Enable TouchID for sudo
      security.pam.services.sudo_local.touchIdAuth = true;

      # Set the primary user for system defaults
      system.primaryUser = "Erik.kiebe";

      # System defaults
      system.defaults = {
        NSGlobalDomain = {
          # Keyboard responsiveness
          InitialKeyRepeat = 20;
          KeyRepeat = 2;
          ApplePressAndHoldEnabled = false;

          # Disable smart text substitutions
          NSAutomaticCapitalizationEnabled = false;
          NSAutomaticDashSubstitutionEnabled = false;
          NSAutomaticPeriodSubstitutionEnabled = false;
          NSAutomaticQuoteSubstitutionEnabled = false;
          NSAutomaticSpellingCorrectionEnabled = false;

          # Better defaults
          AppleShowAllExtensions = true;
          NSDocumentSaveNewDocumentsToCloud = false;
          NSNavPanelExpandedStateForSaveMode = true;
          PMPrintingExpandedStateForPrint = true;

          # Faster UI
          NSAutomaticWindowAnimationsEnabled = false;
        };

        dock = {
            autohide = true;
            magnification = false;
            mineffect = "scale";
            mru-spaces = false;
            show-recents = false;
            tilesize = 50;

        };
        finder = {
            AppleShowAllExtensions = true;
            CreateDesktop = false;
            FXEnableExtensionChangeWarning = false;
            FXPreferredViewStyle = "clmv"; # Column view
            NewWindowTarget = "Home";
            ShowStatusBar = true;
            _FXSortFoldersFirst = true;
        };
        menuExtraClock = {
            Show24Hour = true;
            ShowDate = 1; # Always
        };
        screencapture = {
            target = "file";
            location = "~/Pictures/screenshots";
            type = "jpg";
        };
        screensaver.askForPasswordDelay = 10;
      };


      # Determinate uses its own daemon to manage the Nix installation that
      # conflicts with nix-darwin’s native Nix management.
      # To turn off nix-darwin’s management of the Nix installation, set:
      # nix.enable = false;
      # This will allow you to use nix-darwin with Determinate
      nix.enable = true;      # Fix GID mismatch for nixbld group
      ids.gids.nixbld = 350;

      # Necessary for using flakes on this system.
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
        # auto-optimise-store = true;

        # Binary caches for faster downloads
        substituters = [
          "https://cache.nixos.org"  # Default cache
          "https://nix-community.cachix.org"
        ];

        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        # Performance optimizations
        http-connections = 128;
        max-jobs = "auto";
        download-buffer-size = 134217728; # 128 MB (default is 64 MB)
      };

      nix.optimise.automatic = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog

      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # allow proprietary software
      nixpkgs.config.allowUnfree = true;

      # allow packages for unsupported architectures
      nixpkgs.config.allowUnsupportedSystem = true;
    };
  in
  {
    # packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.hello;
    # defaultPackage.aarch64-darwin = pkgs.hello;
    darwinConfigurations."DK-QG61VFMVW7" = nix-darwin.lib.darwinSystem {

      modules = [
        configuration
      ];
    };
  };
}
