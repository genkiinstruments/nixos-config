{ ... }:

{
  ".config/zellij/config.kdl" = {
    text = builtins.readFile ../shared/config/zellij/config.kdl;
  };
  ".config/zellij/layouts/default.kdl" = {
    text = builtins.readFile ../shared/config/zellij/layouts/default.kdl;
  };
}
