```
nix build .#darwinConfigurations.macos.system && ./result/sw/bin/darwin-rebuild switch --flake .#macos
```
