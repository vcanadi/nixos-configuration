pkgs: with pkgs; [

# Programs
  libreoffice
  nixos1703.firefox chromium w3m nixos-unstable.qutebrowser
  transmission_gtk
  vlc mpv
  git-crypt
  scrot
  emem
  termite
  wine
  p7zip
  (python3.withPackages (ps: with ps; [ attrs pyqt5 yamllint jinja2 ] ))
  qt5.qtwebengine
  python27Packages.carbon
  python27Packages.graphite_api

# Editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myVim
    myNvim
  ]) ++ [

# Terminal
  rxvt_unicode

# Utils
  gcc gnumake
  git tig
  dhcpcd wpa_supplicant
  zip unzip unrar p7zip
  pavucontrol qjackctl
  gparted
  lshw hwinfo	conky htop
  xdotool xsel xclip
  gnome3.nautilus
  tmuxinator
  gv
  direnv
  #    (haskellPackages.callPackage (import /home/bunkar/NixProjs/ping-multi/default.nix) {} )
  openssl

# Haskell
  #haskell.compiler.ghc821
  ghc
  haskellPackages.ghc-mod
  haskellPackages.cabal-install
  haskellPackages.cabal2nix
  haskellPackages.xmobar

# Nix
  nix-repl
  nixops
  hydra
  virtualboxHeadless
  stack2nix
]


