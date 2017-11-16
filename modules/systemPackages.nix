let pkgs_old = import (fetchTarball https://d3g5gsiof5omrk.cloudfront.net/nixos/17.03-small/nixos-17.03.1944.6233be812f/nixexprs.tar.xz ) {};
in 

pkgs: with pkgs; [

  libreoffice
  gnome3.nautilus 
  tmux
  zip
  pkgs_old.hydra 
  nixops
  xdotool
  virtualboxHeadless
  haskellPackages.cabal2nix
  haskellPackages.xmobar
  inotify-tools

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
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [ 
    myVim 
    myNvim 
  ]) ++ [ 

#terminal
  rxvt_unicode

#shell
  fish 

#prog
#    haskell.compiler.ghc7103
  ghc
  haskellPackages.ghc-mod
  haskellPackages.cabal-install

  gcc
  gnumake

  git
  tig

  dhcpcd
  
  wpa_supplicant
  unzip
  qjackctl

  gparted

  lshw
  hwinfo		
  conky
  htop
  unrar
  nix-repl

  #    (haskellPackages.callPackage (import /home/bunkar/NixProjs/ping-multi/default.nix) {} )
  #     (haskellPackages.callPackage (import /home/bunkar/NixProjs/tutorial2/default.nix) {} )

]


