pkgs: with pkgs; [

# Programs
  firefox chromium w3m qutebrowser tor-browser-bundle-bin
  transmission_gtk
  vlc mpv
  scrot feh
  mupdf llpp
  gnupg
  ngrok
  git-crypt

# Editor
  ] ++ (with (import ./vim.nix { inherit pkgs; }); [
    myNvim
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
  haskellPackages.stylish-haskell

  linuxPackages_latest.nvidia_x11
]




