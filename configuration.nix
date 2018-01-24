{ config, pkgs, ... }:
let
  tmux-nix = import ./modules/tmux.nix pkgs;
  sakura-nix = import ./modules/sakura.nix;
  emacs-nix = import ./modules/emacs.nix { inherit config pkgs; };
  utils = import ./utils.nix config;
  b = builtins;
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/X.nix
    ./modules/locale.nix
    ./modules/touch.nix
    ./modules/net.nix
    ./modules/graphics.nix
    ./modules/audio.nix
    ./modules/jobs.nix
    ./modules/users.nix
   ];

  boot.kernelParams = ["quiet" "splash"];
  boot.loader.grub = {
  	enable = true;
  	version = 2;
  	device = "/dev/sda";
  	splashImage = null;
    extraEntries = ''
		  menuentry 'Ubuntu' {
		  insmod ext2
		  set root='(hd0,3)'
		  chainloader +1
		  }
		'';
  };

  fonts = {
    enableCoreFonts = true;
    fonts = with pkgs; [
      corefonts
      liberation_ttf
      dejavu_fonts
      terminus_font
      ubuntu_font_family
      gentium
      hasklig
    ];
  };

  environment={
    systemPackages = import ./modules/systemPackages.nix pkgs ++ [ emacs-nix.emacs emacs-nix.autostartEmacsDaemon ] ;

    shellAliases = {
      vi = "vim";
      gis = "git status";
      gid = "git diff";
      gil = "git log";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch;";
      nixrepl = ''nix-repl "<nixpkgs>" "<nixpkgs/nixos>"'';
      ux = "tmux";
      uxi = "tmuxinator";
      emacs = "emacs -nw";
    };

    interactiveShellInit = ''
      set -o vi
      xset r rate 250 40

      function shs () { grep --include=\*.{hs,cabal,yaml,nix} -rnw . -e "\w*"$1"\w*" --exclude-dir .stack-work; }

      set editing-mode vim

      synclient PalmDetect=1
      synclient PalmMinWidth=5
      synclient VertScrollDelta=170

      synclient VertEdgeScroll=1
      synclient TapButton2=0
      synclient TapButton3=0

      synclient AccelFactor=0.2
      synclient MaxSpeed=1.75

      synclient AreaLeftEdge=2000
      synclient AreaRightEdge=5000
      synclient AreaTopEdge=2500

      eval "$(direnv hook zsh)"
    '';

    variables = {
      PATH = ["$HOME/.local/bin"];
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      #HYDRA_DBI = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
      #HYDRA_DATA = "/var/lib/hydra";
      #HYDRA_CONFIG = "/var/lib/hydra/hydra.conf";
      NIX_REMOTE = "daemon";
      PGHOST = "localhost";
      PGUSER = "ale";
      PGDATABASE = "ale";
      PGPASSWORD = "ale";
      PGPORT = "5432";
      GRAPHITE_ROOT = "/var/db/graphite";
    };

    etc = {

      "zshrc.local".text = ''
        if [ -z "$TMUX" ]; then tmux; fi
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_AUTOQUIT=false
        DISABLE_AUTO_UPDATE="false"
        DISABLE_UNTRACKED_FILES_DIRTY="true"
        HIST_STAMPS="yyyy-mm-dd"
        plugins=( aws cabal catimg common-aliases dirpersist docker encode64 fasd git git-extras jsontools man per-directory-history sudo systemd tmux url-tools vi-mode wd zsh-syntax-highlighting )
        mkdir -p $HOME/.zsh
        export ZSH_CACHE_DIR="$HOME/.zsh"
        export COMPDUMPFILE="$HOME/.zsh"
      '';

      "inputrc".text = ''
        set editing-mode vim
      '';
    };
  };

  nix = {
    #package = pkgs.nixUnstable;

    extraOptions = ''
      trusted-users = hydra root hydra-evaluator hydra-queue-runner
    '';

    requireSignedBinaryCaches = false;

    useSandbox = false;
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs : {

      nixos-unstable = import <nixos-unstable> { config = config.nixpkgs.config; };
      nixos1703      = import <nixos1703>      { config = config.nixpkgs.config; };


    };
  };

  services = {
    openssh = {
      enable = true;
    };

    nixosManual.showManual = true;

    postgresql = {
      enable = true;
      package = pkgs.postgresql96;
      authentication = pkgs.lib.mkForce ''
        # Generated file; do not edit!
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
    '';
    };

  };

  programs = {
    zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "gentoo";
        # theme = "candy";
        plugins = [ "vi-mode" ];
      };
    };
    bash.enableCompletion = true;
    tmux = tmux-nix.tmux;
    ssh = {
     extraConfig = ''
        Host *
        ServerAliveInterval 60
      '';
    };


  };

  system = {
    stateVersion = "17.09";
    activationScripts = utils.mkActivationScriptsForUsers [
      tmux-nix.tmuxinator.userActivationScript
      #sakura-nix.userActivationScript
    ] // {
      synclient-setup = ''
      '';
    };
  };

  hardware.enableAllFirmware=true;
  security.polkit.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users = {
    defaultUserShell = pkgs.zsh;
    extraGroups.vboxusers.members = [ "bunkar" ];
  };

}
