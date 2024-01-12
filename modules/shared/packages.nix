{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
  atuin
  bash-completion
  bat
  cmake
  coreutils
  neofetch
  ninja
  openssh
  sqlite
  transmission
  unar
  p7zip
  wget
  zip
  zoxide
  conan

  # some other lsp related packages / dev tools
  shellcheck
  lldb
  gopls
  rust-analyzer
  mdl
  markdownlint-cli
  # clang-tools
  nodejs
  guile
  nim
  zig
  texlab
  zls
  jre8
  # gcc
  uncrustify
  black
  alejandra
  marksman
  taplo
  yaml-language-server
  python311Packages.python-lsp-server # TODO: pylsp plugins
  gawk
  haskellPackages.haskell-language-server
  java-language-server
  kotlin-language-server
  nodePackages.vls
  nodePackages.jsonlint
  nodePackages.yarn
  nodePackages.vscode-langservers-extracted
  cargo


  # Encryption and security tools
  age
  age-plugin-yubikey
  bitwarden-cli
  gnupg
  libfido2
  pinentry
  yubikey-manager

  # Cloud-related tools and SDKs
  # cloudflared
  # ngrok
  # terraform
  # terraform-ls
  # tflint

  # Media-related packages
  # ffmpeg
  # fd
  # reaper

  # Node.js development tools
  # nodePackages.live-server
  # nodePackages.nodemon
  # nodePackages.prettier
  # nodePackages.npm
  # nodejs

  # Source code management, Git, GitHub tools
  direnv
  gh

  # Text and terminal utilities
  btop
  jetbrains-mono
  jq
  lazygit
  logseq
  ripgrep
  tree
  unrar
  unzip

  # Python packages
  # python312
  # python312Packages.virtualenv

  # Packages installed using brew... doesn't look like I need them at all
  luajit
]
