{
  description = "Eriks nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs;
        [
          # essenstials
          wget
          bat
          usbutils
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

          nerd-fonts.jetbrains-mono
          nerd-fonts.fira-code
          nerd-fonts.iosevka
          nerd-fonts.hack
          nerd-fonts.meslo-lg
          nerd-fonts.terminess-ttf
          nerd-fonts.inconsolata
      ];

      # Unlocking sudo via fingerprint
      security.pam.services.sudo_local.touchIdAuth = true;

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
      nix.enable = false;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."DK-QG61VFMVW7" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
