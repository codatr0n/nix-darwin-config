{
  description = "Eriks nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    # homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    # homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    # homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };

    # home-manager.url = "github:nix-community/home-manager/release-24.11";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nix-darwin, ... }:
  let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
  in
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget



      environment.systemPackages = with pkgs;
        [
          # desktop applications
          google-chrome


          # essenstials
          wget
          bat
        #   usbutils # doesnt work on arm?
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

          # activity monitoring
          htop
          btop
          bottom

          # development
          gh
          git
          opentofu
        ];

      fonts.packages = with pkgs; [
          # developers fonts
          dina-font
          fira
          fira-code
          fira-code-symbols
          jetbrains-mono
          julia-mono

          (nerdfonts.override { fonts = [
            "JetBrainsMono"
            "FiraCode"
            "Iosevka"
            "Hack"
            "Meslo"
            # "TerminessTTF"
            "Inconsolata"
            ]; }
          )
        #   nerd-fonts.jetbrains-mono
        #   nerd-fonts.fira-code
        #   nerd-fonts.iosevka
        #   nerd-fonts.hack
        #   nerd-fonts.meslo-lg
        #   nerd-fonts.terminess-ttf
        #   nerd-fonts.inconsolata
      ];

      # Unlocking sudo via fingerprint
    #   security.pam.services.sudo_local.touchIdAuth = true;
      security.pam.enableSudoTouchIdAuth = true;

      # System defaults
      system.defaults = {
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
      nix.enable = true;

      # Necessary for using flakes on this system.
      nix.settings = {
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
        # auto-optimise-store = true;
      };

      nix.optimise.automatic = true;

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 1;

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
