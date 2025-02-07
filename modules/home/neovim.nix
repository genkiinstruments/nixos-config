{
  pkgs,
  config,
  perSystem,
  ...
}:
{
  packages = {
    nvim = pkgs.callPackage perSystem.self.nvim-standalone {
      nvim-appname = "mvim";
      buildEnv = pkgs.buildEnv;
      inherit (config.packages) treesitter-grammars;
      inherit (config.legacyPackages) nvim-lsp-packages;
    };
  };
}
