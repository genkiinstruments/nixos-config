{ pkgs, config, ... }:

{
  ".config/zellij/config.kdl" = {
    text = builtins.readFile ./config/zellij/config.kdl;
  };
  ".config/zellij/layouts/default.kdl" = {
    text = builtins.readFile ./config/zellij/layouts/default.kdl;
  };
}
