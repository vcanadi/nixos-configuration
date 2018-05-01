pkgs: with pkgs; [

# Programs
  firefox chromium w3m qutebrowser tor-browser-bundle-bin
  transmission_gtk
  vlc mpv
  xorg.xkill tldr wine
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
  tmuxp

# Utils
  git tig
  dhcpcd wpa_supplicant
  zip unzip unrar p7zip
  gparted
  lshw hwinfo conky htop pciutils
  pavucontrol pulseaudio alsaUtils
  xdotool xsel xclip
  direnv
  postgresql

# Haskell
  ghc
  stack
  cabal-install
  cabal2nix
  haskellPackages.xmobar

# Nix
  nixops
  nixos-stable.nix-repl
  virtualboxHeadless
]




