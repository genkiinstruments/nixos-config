{ pkgs }:

with pkgs; [
  # General packages for development and system management
  vscode
  atuin
  zoxide
  bash-completion
  bat
  coreutils
  neofetch
  openssh
  sqlite
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry
  yubikey-manager
  bitwarden-cli

  # Cloud-related tools and SDKs
  cloudflared
  ngrok
  terraform
  terraform-ls
  tflint

  # Media-related packages
  ffmpeg
  fd

  # Node.js development tools
  nodePackages.live-server
  nodePackages.nodemon
  nodePackages.prettier
  nodePackages.npm
  nodejs

  # Source code management, Git, GitHub tools
  gh
  direnv

  # Text and terminal utilities
  btop
  jetbrains-mono
  jq
  ripgrep
  lazygit
  tree
  unrar
  unzip

  # Python packages
  python312
  python312Packages.virtualenv

  # Packages installed using brew... doesn't look like I need them at all
  luajit

  #
  logseq
  unar
  transmission
]
