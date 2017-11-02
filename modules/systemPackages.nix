let pkgs_old = import (fetchTarball https://d3g5gsiof5omrk.cloudfront.net/nixos/17.03-small/nixos-17.03.1944.6233be812f/nixexprs.tar.xz ) {};
in 

pkgs: with pkgs; [

  xorg.xmodmap
  libreoffice
  gnome3.nautilus 
  tmux
  filezilla
  ncftp
  sqlite
  staruml
  tree
  acpi
  tcpdump
  zip
  haskellPackages.pretty-show
  wpa_supplicant_gui
  rocksdb_lite
  zlib
  hydra 
  nixops
  psmisc 
  xdotool
  virtualboxHeadless

#osnovno 
  pavucontrol	
  pkgs_old.firefox 
  chromium
  w3m
  transmission_gtk
  vlc
  wine
  p7zip

#text editori
  (import ./vim.nix)

#terminal
  rxvt_unicode

#shell
  fish 

#prog
#    haskell.compiler.ghc7103
  ghc
  haskellPackages.ghc-mod
  haskellPackages.cabal-install
  haskellPackages.inline-c

  gcc
  gnumake

  git
  tig

  postgresql
  
  dhcpcd
  
  wpa_supplicant
  unzip
  qjackctl

  gparted

  lshw
  hwinfo		
  conky
  htop
  jdk
  unrar
  nix-repl

#xmonad sranja
  haskellPackages.xmobar
  haskellPackages.xmonad
  cabal2nix

  #    (haskellPackages.callPackage (import /home/bunkar/NixProjs/ping-multi/default.nix) {} )
  #     (haskellPackages.callPackage (import /home/bunkar/NixProjs/tutorial2/default.nix) {} )

]


