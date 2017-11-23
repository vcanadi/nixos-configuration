let pkgs_old = import (fetchTarball https://d3g5gsiof5omrk.cloudfront.net/nixos/17.03-small/nixos-17.03.1944.6233be812f/nixexprs.tar.xz ) {};
in 

pkgs: with pkgs; [

# programs 
  libreoffice
  pkgs_old.firefox chromium w3m
  transmission_gtk
  vlc
  
# text editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [ 
    myVim 
    myNvim 
  ]) ++ [ 

# terminal
  rxvt_unicode

# shell
  fish 

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
  #    (haskellPackages.callPackage (import /home/bunkar/NixProjs/ping-multi/default.nix) {} )
  openssl

# nix
  nix-repl
  nixops
  pkgs_old.hydra 
  virtualboxHeadless
]


