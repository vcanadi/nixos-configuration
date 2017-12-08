pkgs: with pkgs; [

# programs
  libreoffice
  nixos1703.firefox chromium w3m
  transmission_gtk
  vlc
  git-crypt
  scrot
  stack2nix
  emem

# text editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myVim
    myNvim
  ]) ++ [

# terminal
  rxvt_unicode

# shell


# utils
  ghc
  haskellPackages.ghc-mod
  haskellPackages.cabal-install
  gcc gnumake
  git tig
  dhcpcd wpa_supplicant
  zip unzip unrar p7zip
  pavucontrol qjackctl
  gparted
  lshw hwinfo	conky htop
  xdotool xsel xclip
  gnome3.nautilus
  haskellPackages.cabal2nix
  haskellPackages.xmobar
  tmuxinator
  #    (haskellPackages.callPackage (import /home/bunkar/NixProjs/ping-multi/default.nix) {} )
  openssl

# nix
  nix-repl
  nixops
  hydra
  virtualboxHeadless
]


