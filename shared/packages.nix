{ pkgs }:

with pkgs; [
  # General packages for development and system management
  act
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
  bit
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry
  yubikey-manager

  # Cloud-related tools and SDKs
  # docker
  # docker-compose
  awscli2
  cloudflared
  flyctl
  google-cloud-sdk
  go
  gopls
  ngrok
  ssm-session-manager-plugin
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
]
