pkgs: with pkgs; [

# Browser
  firefox w3m qutebrowser tor-browser-bundle-bin

# Torrent
  transmission_gtk

# Media player
  vlc mpv mplayer

# Misc
  scrot feh
  # llpp
  mupdf
  tldr
  zip unzip unrar p7zip

# Text editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myNvim
  ]) ++ [

# Terminal
  rxvt_unicode
  # tmuxp

# Utils
  # Git
    git python27Packages.grip tig
  # Hardware/Proc tools
    lshw hwinfo htop ftop pciutils hwdata hardinfo sysstat gotop lm_sensors vnstat conky
  # Disk
    gparted ntfs3g
  # X tools
    xorg.xkill autorandr xorg.xmodmap xdotool xsel xclip rofi
  # Vim deps
    ack fzf
  # Other
    gnupg
    dhcpcd wpa_supplicant
    trash-cli


# Haskell
  stack
  cabal-install
  haskellPackages.xmobar
  # haskellPackages.stylish-haskell

# Music
  guitarix
  qjackctl
  jack2

# Ps emulators
  pcsx2
  pcsxr
]




