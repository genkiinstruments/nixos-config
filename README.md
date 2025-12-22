# Genki 🌍🌎🌏

Here you can find our infrastructure. One day we might find time to actually
document it.

## Add new darwin device

1. Install macOS and update to latest version
2. Generate host ssh key using `sudo ssh-keygen -A` adding
   `age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];` to
   `darwin-configuration.nix` and host key to `secrets` repo.
3. Run nix installer:
   `curl -fsSL https://install.determinate.systems/nix | sh -s — install --prefer-upstream-nix`
4. Optional: Manually create nix-ssh user on macOS, does not need to be system
5. Install configuration using nix-darwin:
   `sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake <path to flake>`
6. Run `tailscale up --ssh`, login, disable key expiry and optionally add
   machine to builders/github-actions tags
