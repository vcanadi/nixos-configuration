pkgs: with pkgs;
let overlay = final: prev: rec {
        # qutebrowserovr = prev.qutebrowser.overrideAttrs (prev: {
        #   version = "git";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "qutebrowser";
        #     repo = "qutebrowser";
        #     rev = "479d8f4fd82b042627d2e6b7e9ffacdcf32b7a6f";
        #     sha256 = "";

        #   };
        # });

  };
  pkgsClone = import /home/vcanadi/git/nixpkgs {};
  in
{
  systemPackages = [
  # Torrent
    transmission_3-gtk

    firefox

  # Media player
    vlc
    spotify

  # Misc
    tldr
    zip unzip unrar
    lxqt.pavucontrol-qt
    hwinfo ftop pciutils hwdata hardinfo sysstat gotop lm_sensors vnstat lsof psutils entr dconf
    xorg.xkill autorandr xorg.xmodmap xdotool xsel xclip rofi xorg.xinput xrandr-invert-colors
    jq
    tig
    gitFull
    wget

  # Docs
    llpp

  # Vim deps
    ack silver-searcher ctags
    nodejs

  # Haskell
    haskellPackages.xmobar
    haskellPackages.hasktags

  # Games
    steam
    godot_4

  # 3d
    freecad

  # Nix
    cabal2nix

  # Arduino
    # arduino-cli

  # Android
    # android-studio
    # jre
    android-tools
    # apksigner

  # Virtualization
    # virt-manager
    # OVMFFull
    # edk2
    # edk2-uefi-shell
    # docker
  ];
  overlays = [overlay];
}
