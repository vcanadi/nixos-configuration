{ config, pkgs, ... }:
let
  myNeovim = import ./modules/vim.nix;
  myZsh = import ./modules/zsh.nix;
  pkgsStable = import <nixos-stable> {};
  pkgsSmall = import <nixos-unstable-small> {};
in
{
  programs = {
    home-manager = {
      enable = true;
    };
    zsh = myZsh { inherit pkgs; };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    git = {
      enable = true;
      userEmail = "vito.canadi@gmail.com";
      userName = "Vito Canadi";
      delta.enable = true;
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
    # emacs = {
    #   enable = true;
    #   extraPackages = epkgs: with epkgs; [
    #     evil
    #     evil-org
    #     evil-leader

    #     evil-search-highlight-persist
    #     fzf

    #     helm
    #     helm-projectile
    #     helm-w3m

    #     lsp-mode
    #     lsp-ui
    #     lsp-haskell
    #     lsp-treemacs
    #     lsp-ivy
    #     flycheck
    #     company
    #     helm-lsp
    #     dap-mode
    #     haskell-mode
    #     agda2-mode

    #     neotree
    #     treemacs
    #     treemacs-evil
    #     tmux-pane
    #     undo-tree
    #     undo-fu
    #     xclip
    #   ];
    #   extraConfig = ''
    #     ;; Enable Evil
    #     (require 'evil)
    #     (evil-mode 1)

    #     ;; auto-load agda-mode for .agda and .lagda.md
    #     (setq auto-mode-alist
    #        (append
    #          '(("\\.agda\\'" . agda2-mode)
    #            ("\\.lagda.md\\'" . agda2-mode))
    #          auto-mode-alist))
    #   '';
    # };
    htop.enable = true;
    qutebrowser = {
      enable = true;
      extraConfig = builtins.readFile ./modules/qutebrowser/config.py;
      package = pkgs.qutebrowser.override {
          enableVulkan = false;
        };
    };
    chromium.enable = true;
    rofi.enable = true;
    feh.enable = true;
  };
  services = {
  };

  manual.manpages.enable = true;

  home = {
    stateVersion = "24.05";
    keyboard = {
      layout = "us,hr";
      options = [ "caps:escape" "ctrl:ralt_rctrl" ];
    };

    file =  {
      ".ghci".text = builtins.readFile ./modules/dot/.ghci;
      ".haskeline".text = builtins.readFile ./modules/dot/.haskeline;
      ".wallpaper".source = ./modules/dot/.wallpaper;
      ".fehbg".text = ''
        #!/usr/bin/env bash
        feh --bg-fill --no-fehbg ~/.wallpaper
      '';
      ".inputrc".text = ''
        set editing-mode vi
        '';
    };

    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size =64;
    };
  };
}
