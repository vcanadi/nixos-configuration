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

 #osnovno 
    pavucontrol	
    firefox
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
  

