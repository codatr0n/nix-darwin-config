# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a nix-darwin configuration for macOS systems, managing system packages, fonts, and macOS settings declaratively using Nix flakes. The configuration targets Apple Silicon (aarch64-darwin) architecture and uses bleeding-edge versions for latest packages.

## Key Commands

### Initial Setup (first time only)
```bash
nix run nix-darwin -- switch --flake .
```

### Applying Configuration Changes
```bash
sudo darwin-rebuild switch --flake .
```
or use the convenience script:
```bash
sudo ./rebuild.sh
```

**Note:** Must run with `sudo` - nix-darwin master requires root for system activation.

### Checking Configuration Syntax
```bash
nix flake check
```

### Updating Flake Inputs
```bash
nix flake update
```

**Tip:** Set `GITHUB_TOKEN` env var for faster updates and higher GitHub API rate limits:
```bash
export GITHUB_TOKEN="$(gh auth token)"
```

### Viewing Changelog
```bash
darwin-rebuild changelog
```

## Architecture

**Main Configuration**: `flake.nix` contains the entire system configuration in a single file:
- **Inputs**:
  - `nixpkgs` - Points to nixpkgs-unstable (bleeding edge)
  - `nix-darwin` - Points to master branch (latest features)
- **Outputs**: Contains the darwinConfiguration for hostname "DK-QG61VFMVW7"
- **Configuration Module**: Inline module with `pkgs` and `lib` parameters defining:
  - System packages (`environment.systemPackages`)
  - Fonts (`fonts.packages`) - Using individual nerd-fonts packages
  - NSGlobalDomain settings (keyboard, text behavior, UI)
  - macOS system defaults (Dock, Finder, menu bar, screencapture)
  - Nix settings with binary caches for faster builds
  - Primary user configuration

**Flake Structure**:
- Uses nixpkgs-unstable (latest packages)
- nix-darwin master (latest features, requires stateVersion 5)
- Follows pattern: nix-darwin's nixpkgs follows main nixpkgs input
- Commented out: nix-homebrew and home-manager (available for future use)

**System Defaults**: The configuration manages macOS settings including:
- **NSGlobalDomain**: Keyboard repeat rates, disabled text substitutions, expanded dialogs, faster UI
- **Dock**: autohide, tile size, no recents
- **Finder**: show extensions, column view, sort folders first
- **Screenshot**: save to ~/Pictures/screenshots as JPG
- **Screensaver**: 10s password delay

**Binary Caches**: Configured for faster package downloads:
- `cache.nixos.org` (default)
- `nix-community.cachix.org` (community packages)
- Parallel downloads (128 connections)

## Important Notes

- **Platform**: `aarch64-darwin` (Apple Silicon only)
- **State Version**: 5 (for nix-darwin master compatibility)
- **Primary User**: `Erik.kiebe` (required for user-specific settings in nix-darwin master)
- **Bleeding Edge**: Uses unstable nixpkgs and master nix-darwin for latest versions
- **Managed by IT**: Firewall and PAM/sudo_local files are centrally managed (warnings expected)
- **PAM Disabled**: `system.activationScripts.pam.text` is forced to empty to avoid conflicts with IT-managed sudo configuration
- Allows unfree and unsupported packages
- Nix store optimization enabled (`nix.optimise.automatic`)
- Must run rebuild with `sudo` (system activation requires root)
