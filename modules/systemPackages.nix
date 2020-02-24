pkgs: with pkgs;
[
# Browser
  firefox w3m qutebrowser tor
  skypeforlinux

# Torrent
  transmission_gtk

# Media player
  vlc mpv mplayer

# Image
  scrot feh

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
    lshw hwinfo htop ftop pciutils hwdata hardinfo sysstat gotop lm_sensors vnstat conky lsof psutils entr

  # Disk
    gparted ntfs3g

  # X tools
    xorg.xkill autorandr xorg.xmodmap xdotool xsel xclip rofi xorg.xinput
    xorg.xbacklight

  # Vim deps
    ack fzf bsdbuild

  # Other
    gnupg
    dhcpcd wpa_supplicant

# Haskell
  cabal-install
  haskellPackages.xmobar
  haskellPackages.hasktags
  ghcid
  idris

# Cpp
  gcc

# DB
  staruml
  postgresql

# Music
  qjackctl
  lingot

# Nix
  cabal2nix
  nixops
]
