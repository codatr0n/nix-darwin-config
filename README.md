# Nix package manager for macOS

My personal Nix configuration for macOS

****

#### usefull inspiration
- https://github.com/dustinlyons/nixos-config
- https://davi.sh/blog/2024/02/nix-home-manager/
- https://davi.sh/blog/2024/11/nix-vscode/
- https://github.com/davish/nix-on-mac/blob/part-3/flake.nix


#### NixOS links
- [NixOS packages](https://nixos.org/nixos/packages.html)
- [NixOS options](https://nixos.org/nixos/options.html)
- [NixOS wiki](https://nixos.wiki/wiki/NixOS)


#### Install using Determinate Nix' installer
This is easier than using the Nix installer directly, as it will make it more convenient for you.
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
  sh -s -- install
```
**Note**: We DONT want to install the Determinate Nix version but the regular Nix, so select `no` when asked.


#### create nix darwin template
```bash
nix flake init -t nix-darwin
```

#### install Homebrew (required before first run)
This flake manages Homebrew *packages* (via nix-darwin's `homebrew` module), but not
the Homebrew *installation* itself. On a new machine, install Homebrew by hand first:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Once `brew` is on your `$PATH`, `darwin-rebuild switch` will tap/install/upgrade and
prune all the brews and casks declared in `flake.nix` for you automatically.

#### first run of nix flake
```bash
nix run nix-darwin -- switch --flake .
```
It might take a while to complete, as it will populate the cache for all the packages.

Reload your terminal to use the new shell.

#### subsequent rebuilds with nix-darwin
```bash
sudo darwin-rebuild switch --flake .
```
or use the convenience script:
```bash
sudo ./rebuild.sh
```

**Note**: Must use `sudo` - nix-darwin master requires root for system activation.


#### uninstall nix-darwin
```bash
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller
```

#### uninstall Nix
```bash
/nix/nix-installer uninstall
```
