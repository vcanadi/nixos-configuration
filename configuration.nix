{ config, pkgs, ... }:
let
  tmux-nix = import ./modules/tmux.nix pkgs;
  utils = import ./utils.nix config;
in
{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/X.nix
    ./modules/locale.nix
    ./modules/audio.nix
    ./modules/touch.nix
    ./modules/net.nix
    ./modules/users.nix
   ];

  boot.kernelParams = ["quiet" "splash"];
  boot.kernelModules =  ["snd-seq" "snd-rawmidi" ];
  boot.loader.grub = {
  	enable = true;
  	version = 2;
  	device = "/dev/sda";
  	splashImage = null;
    extraEntries = ''
	  menuentry 'Win' {
	    insmod ntfs
	    set root='(hd0,3)'
        chainloader +1
	  }
    '';
  };

  environment = {
    systemPackages = import ./modules/systemPackages.nix pkgs;

    shellAliases = {
      vi = "vim";
      gis = "git status";
      gid = "git diff";
      gil = "git log";
      nixc = "cd /etc/nixos";
      ec = "emacsclient -t";
    };

    interactiveShellInit = ''
      set -o vi

      function shs () { grep --include=\*.{hs,cabal,yaml,nix} -rnw . -e "\w*"$1"\w*" --exclude-dir .stack-work; }
      function ytloc () { yt org local --file $1 --yt-token $(cat /home/bunkar/reports/vcanadi-yt-token); }
      function ytexport () { yt org export --file $1 --user vito.canadi --yt-token $(cat /home/bunkar/reports/vcanadi-yt-token); }

      set editing-mode vim

      if [ -n "$DISPLAY" ]; then

        xset r rate 200 100

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

      fi
    '';

    variables = {
      PATH = ["$HOME/.local/bin"];
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      HISTTIMEFORMAT="%d/%m/%y %T ";
      KEYBOARD_RATE = "180";
      KEYBOARD_DELAY = "200";
      ALTERNATE_EDITOR = "";
      XDG_CONFIG_HOME = "/home/bunkar/.config";
    };

    etc = {

      "zshrc.local".text = ''
        if [ -z "$TMUX" ]; then tmux; fi
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        ZSH_TMUX_AUTOSTART=true
        ZSH_TMUX_AUTOQUIT=true
        DISABLE_AUTO_UPDATE="false"
        DISABLE_UNTRACKED_FILES_DIRTY="true"
        HIST_STAMPS="yyyy-mm-dd"
        plugins=( aws cabal catimg common-aliases dirpersist docker encode64 fasd git git-extras jsontools man per-directory-history sudo systemd tmux url-tools vi-mode wd zsh-syntax-highlighting )
        mkdir -p $HOME/.zsh
        export ZSH_CACHE_DIR="$HOME/.zsh"
        export COMPDUMPFILE="$HOME/.zsh"
        bindkey "^K" history-substring-search-up
        bindkey "^J" history-substring-search-down
      '';

      "inputrc".text = ''
        set editing-mode vim
      '';
    };

  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs : {
      nixos-stable = import <nixos-stable> { config = config.nixpkgs.config; };
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

  security = {
    polkit.enable = true;
    chromiumSuidSandbox.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      ohMyZsh = {
        enable = true;
        theme = "gentoo";
        plugins = [ "vi-mode" "history-substring-search" ];
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
    stateVersion = "18.03";
    activationScripts = utils.mkActivationScriptsForUsers [
      tmux-nix.tmuxp.userActivationScript
    ];
  };

  hardware = {
    enableAllFirmware=true;
    cpu.intel.updateMicrocode=true;
  };

  virtualisation.virtualbox.host.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
  };
}
