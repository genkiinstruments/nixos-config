{ ... }:

{
  ".config/zellij/config.kdl" = {
    source = builtins.readFile ../shared/config/zellij/config.kdl;
  };
  ".config/zellij/layouts/default.kdl" = {
    source = builtins.readFile ../shared/config/zellij/layouts/default.kdl;
  };
}
