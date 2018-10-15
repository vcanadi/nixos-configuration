pkgs: with pkgs; [

# Programs
  firefox chromium w3m qutebrowser tor-browser-bundle-bin
  transmission_gtk
  vlc mpv
  scrot feh
  mupdf llpp
  gnupg
  ngrok

  geogebra

# Editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myNvim
    myNvimQt
  ]) ++ [
  emacs

# Terminal
  rxvt_unicode
  cool-retro-term
  terminator
  tmuxp


# Utils
  gcc
  binutils gnumake autoconf automake linuxHeaders python3
  git
  git-crypt
  dhcpcd wpa_supplicant
  zip unzip unrar p7zip
  gparted
  lshw hwinfo conky htop pciutils
  xorg.xkill tldr
  pavucontrol  alsaUtils
  # pulseaudio
  xdotool xsel xclip
  direnv

# Haskell
  ghc
  stack
  cabal-install
  cabal2nix
  haskellPackages.xmobar
  haskellPackages.xmonad-contrib
  haskellPackages.xmonad-extras
  haskellPackages.xmonad
  haskellPackages.xmobar
  haskellPackages.conduit
  haskellPackages.http-conduit
  haskellPackages.stylish-haskell

  linuxPackages_latest.nvidia_x11
  xkeyboard_config
]




