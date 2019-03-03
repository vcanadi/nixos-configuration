pkgs: with pkgs;
[
# Browser
  firefox w3m qutebrowser tor-browser-bundle-bin

# Torrent
  transmission_gtk

# Media player
  vlc mpv mplayer

# Image
  scrot feh gthumb

# Misc
  llpp
  tldr
  zip unzip unrar p7zip

# Text editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myNvim
  ]) ++ [

# Terminal
  rxvt_unicode

# Utils

  # Git
    git tig

  # Hardware/Proc tools
    lshw hwinfo htop ftop pciutils hwdata hardinfo sysstat gotop lm_sensors vnstat conky lsof nvtop psutils

  # Disk
    gparted ntfs3g

  # X tools
    xorg.xkill autorandr xorg.xmodmap xdotool xsel xclip rofi xwinwrap xorg.xinput gnuplot hddtemp graphviz
    cudatoolkit

  # Vim deps
    ack fzf bsdbuild

  # Other
    gnupg
    dhcpcd wpa_supplicant
    trash-cli

# Haskell
  stack
  cabal-install
  haskellPackages.xmobar
  haskellPackages.stylish-haskell

# Cpp
  gcc

# Music
  guitarix
  qjackctl
  jack2

# Python
  # (python36.withPackages(ps: with ps; [
  #   python-language-server
  #   # the following plugins are optional, they provide type checking, import sorting and code formatting
  #   pyls-mypy pyls-isort pyls-black
  #   tensorflow psutil jupyterlab
  # ]))
  xgboost

 # Misc
  geogebra
]
