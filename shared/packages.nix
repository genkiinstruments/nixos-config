{ pkgs }:

with pkgs; [
  # General packages for development and system management
  act
  atuin
  zoxide
  aspell
  aspellDicts.en
  bash-completion
  zellij
  bat
  coreutils
  difftastic
  du-dust
  git-filter-repo
  killall
  neofetch
  openssh
  pandoc
  sqlite
  wget
  zip

  # Encryption and security tools
  _1password
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry
  yubikey-manager

  # Cloud-related tools and SDKs
  docker
  docker-compose
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
  emacs-all-the-icons-fonts
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  glow
  hack-font
  noto-fonts
  noto-fonts-emoji
  nerdfonts
  meslo-lgs-nf

  # Node.js development tools
  fzf
  nodePackages.live-server
  nodePackages.nodemon
  nodePackages.prettier
  nodePackages.npm
  nodejs

  # Source code management, Git, GitHub tools
  gh

  # Text and terminal utilities
  neovim
  btop
  hunspell
  iftop
  jetbrains-mono
  jq
  ripgrep
  lazygit
  tree
  tmux
  unrar
  unzip

  # Python packages
  python39
  python39Packages.virtualenv
]
