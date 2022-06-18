{ config, pkgs, ... }:
let
  myNeovim = import ./modules/vim.nix;
  myZsh = import ./modules/zsh.nix;
  pkgsStable = import <nixos-stable> {};
in
{
  programs = {
    home-manager.enable = true;
    zsh = myZsh { inherit pkgs; };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    git = {
      enable = true;
      userEmail = "vito.canadi@gmail.com";
      userName = "Vito Canadi";
    };
    urxvt = {
      enable = true;
      fonts = ["xft:Bitstream Vera Sans Mono:pixelsize=10"];
      extraConfig = {
        "perl-ext-common" = "resize-font";
      };
    };
    terminator.enable = true;
    neovim = myNeovim { inherit pkgs; };
    htop.enable = true;
    qutebrowser = {
      enable = true;
      extraConfig = builtins.readFile ./modules/qutebrowser/config.py;
    };
    chromium.enable = true;
    firefox.enable = true;
    rofi.enable = true;
    feh.enable = true;
  };
  services = {
  };

  manual.manpages.enable = true;

  home = {
    keyboard = {
      layout = "us,hr";
      options = [ "caps:escape" "grp:rctrl_rshift_toggle" "ctrl:ralt_rctrl" "terminate:ctrl_alt_bksp"];
    };

    file =  {
      ".ghci".text = builtins.readFile ./modules/dot/.ghci;
      ".haskeline".text = builtins.readFile ./modules/dot/.haskeline;
    };

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size =64;
    };
  };
}
