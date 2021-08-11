{ config, pkgs, ... }:
let
  myNeovim = import ./modules/vim.nix;
  myZsh = import ./modules/zsh.nix;
  myTmux = import ./modules/tmux.nix;
in
{
  programs = {
    emacs = {
      enable = true;
      extraPackages = epkgs: with epkgs; [
        evil
        evil-org
        evil-leader

        evil-search-highlight-persist
        fzf

        helm
        helm-projectile
        helm-w3m

        lsp-mode
        lsp-ui
        lsp-haskell
        lsp-treemacs
        lsp-ivy
        flycheck
        company
        helm-lsp
        dap-mode
        haskell-mode

        neotree
        treemacs
        treemacs-evil
        tmux-pane
        undo-tree
        xclip
      ];
    };
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    feh.enable = true;
    chromium.enable = true;
    # gpg = { enable = true; };
    git = {
      enable = true;
      userEmail = "vito.canadi@gmail.com";
      userName = "Vito Canadi";
      # signing = {
      #   key = "";
      #   signByDefault = true;

      # };
    };
    urxvt = {
      enable = true;
      fonts = ["xft:Bitstream Vera Sans Mono:pixelsize=12"];
      extraConfig = {
        "perl-ext-common" = "resize-font";
      };
    };
    terminator.enable = true;
    home-manager.enable = true;
    htop.enable = true;
    neovim = myNeovim { inherit pkgs; };

    qutebrowser = {
      enable = true;
      extraConfig = builtins.readFile ./modules/qutebrowser/config.py;
    };
    firefox.enable = true;
    rofi.enable = true;
    zsh = myZsh { inherit pkgs; };
  };
  services = {
  };

  manual.manpages.enable = true;

  home = {
    keyboard = {
      layout = "us,hr";
      options = [ "caps:escape" "grp:rctrl_rshift_toggle" "ctrl:ralt_rctrl" "terminate:ctrl_alt_bksp"];
    };
    file.".ghci" = {
      text = builtins.readFile ./modules/dot/.ghci;
    };
  };
}
