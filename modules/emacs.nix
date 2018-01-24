{ config, pkgs, ... }:

let

  emacsPackages =
    pkgs.emacsPackagesNg.overrideScope
    (self: super: {
      evil = self.melpaPackages.evil;
      haskell-mode = self.melpaPackages.haskell-mode;
      flycheck-haskell = self.melpaPackages.flycheck-haskell;
      idris-mode = self.melpaPackages.idris-mode;
      use-package = self.melpaPackages.use-package;
    });
in
rec {
  emacs = pkgs.emacsPackagesNg.emacsWithPackages (epkgs: with epkgs; [
    use-package

    # Interface
    bind-key
    company
    helm
    helm-descbinds  # describe-bindings in helm
    helm-projectile
    projectile  # project management
    visual-fill-column
    which-key  # display keybindings after incomplete command
    winum eyebrowse # window management

    # Themes
    diminish
    spaceline # modeline beautification

    # Delimiters
    rainbow-delimiters smartparens

    # Evil
    avy
    evil
    evil-surround
    evil-indent-textobject
    evil-cleverparens
    undo-tree

    # Git
    magit
    git-timemachine

    # LaTeX
    auctex
    cdlatex
    company-math
    helm-bibtex

    auto-compile
    flycheck

    markdown-mode
    pkgs.ledger
    yaml-mode

    # Haskell
    haskell-mode
    flycheck-haskell
    company-ghci  # provide completions from inferior ghci

    # Org
    org org-ref

    # Rust
    rust-mode cargo flycheck-rust

    # Mail
    notmuch messages-are-flowing

    # Nix
    pkgs.nix nix-buffer

    # Maxima
    pkgs.maxima

  ]);

  autostartEmacsDaemon = pkgs.writeTextFile {
    name = "autostart-emacs-daemon";
    destination = "/etc/xdg/autostart/emacs-daemon.desktop";
    text = ''
      [Desktop Entry]
      Name=Emacs Server
      Type=Application
      Exec=${emacs}/bin/emacs --daemon
    '';
  };
}
