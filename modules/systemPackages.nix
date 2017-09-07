pkgs: with pkgs; [

    xorg.xmodmap
    pal
    libreoffice
    gnome3.nautilus 
    tmux
    filezilla
    ncftp
    unity3d 
    sqlite
    monodevelop
    gpicview
    gthumb
    elixir
    erlang
    rebar3
    rlwrap
    staruml
    tree


 #osnovno 
    pavucontrol	
    chromium
    firefox
    w3m
    transmission_gtk
    vlc
    wine
    pcsx2
    p7zip

#text editori
    (import ./vim.nix)
    neovim

#terminal
    rxvt_unicode

#shell
    fish 

#prog
#    haskell.compiler.ghc7103
    stack
    ghc

    gcc
    gnumake

    git
    tig

    python3		
    pythonPackages.numpy

    postgresql
    archiveopteryx
		
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
]
  

