# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is Genki Instruments' NixOS infrastructure repository containing configuration for multiple hosts (servers and developer machines) using Nix flakes. The repository manages both NixOS (Linux) and nix-darwin (macOS) configurations.

## Development Commands

### Core Commands
- `nix develop` - Enter development shell with all required tools
- `nix flake update` - Update flake.lock with latest dependencies
- `nixfmt-rfc-style **/*.nix` - Format all Nix files
- `nix flake check` - Validate flake configuration

### System Management
- `nixos-rebuild switch --flake .#hostname` - Apply NixOS configuration
- `darwin-rebuild switch --flake .#hostname` - Apply macOS configuration (nix-darwin)
- `nixos-anywhere --flake .#hostname root@target-ip` - Deploy to remote NixOS host
- `home-manager switch --flake .#user@hostname` - Apply home-manager configuration

### Host-specific Examples
- `nixos-rebuild switch --flake .#g` - Deploy to host 'g'
- `darwin-rebuild switch --flake .#saumavel` - Deploy to saumavel's macOS machine

## Architecture

### Directory Structure
- `hosts/` - Host-specific configurations (one directory per machine)
  - `hosts/*/configuration.nix` - Main NixOS configuration
  - `hosts/*/darwin-configuration.nix` - Main nix-darwin configuration
  - `hosts/*/users/` - User-specific configurations
- `modules/` - Reusable NixOS/darwin modules
  - `modules/nixos/` - NixOS-specific modules
  - `modules/darwin/` - macOS-specific modules
  - `modules/shared/` - Cross-platform modules
  - `modules/home/` - Home-manager modules
- `lib/` - Custom Nix functions and utilities
- `packages/` - Custom package definitions
- `home/` - Shared home-manager configurations (especially nvim)

### Key Configuration Patterns
- Uses `inputs.srvos` modules for secure server defaults
- Leverages `inputs.blueprint` for consistent flake structure
- Home-manager integration for user-specific configurations
- Custom `mvim` package for Neovim configuration
- Shared SSH keys via `authorized_keys` file
- Tailscale deployment across all hosts
- Custom binary cache at `https://x.tail01dbd.ts.net:8443/genki`

### Host Types
- **NixOS servers**: Use `configuration.nix` with srvos modules
- **macOS machines**: Use `darwin-configuration.nix` with nix-darwin
- **Mixed environments**: Both Linux and macOS configurations

## Custom Packages

### mvim
Custom Neovim distribution with:
- Language servers for Go, Rust, Python, Nix, etc.
- Treesitter grammars
- Custom configuration in `home/nvim/`
- Automatic plugin management via lazy.nvim

### deploy
Custom deployment wrapper for nixos-anywhere

## Important Files
- `flake.nix` - Main flake configuration with all inputs
- `devshell.nix` - Development environment specification
- `authorized_keys` - SSH public keys for all users
- `flake.lock` - Pinned dependency versions

## Security Notes
- IFDs (Import From Derivation) disabled by default
- Uses agenix for secrets management
- Tailscale for secure networking
- SSH keys centrally managed
- Custom binary cache with trusted keys