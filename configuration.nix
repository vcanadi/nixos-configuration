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
    ./modules/net.nix
    ./modules/users.nix
   ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;

  };


  environment = {
    systemPackages = import ./modules/systemPackages.nix pkgs;

    shellAliases = {
      vi = "vim";
      gis = "git status";
      gid = "git diff";
      gil = "git log";
      nixc = "cd /etc/nixos; vim configuration.nix";
      nixb = "cd /etc/nixos; nixos-rebuild switch";
      ec = "emacsclient -t -nw";
      sc = "systemctl";
      hgrep = ''
        grep -rni \
          --include \*.hs \
          --include \*.cabal \
          --include \*.yaml \
          --include \*.nix \
          --exclude-dir .stack-work \
      '';
    };

    interactiveShellInit = ''
      set editing-mode vim

      function ytloc () { yt org local --file $1 --yt-token $(cat /home/vcanadi/reports/vcanadi-yt-token); }
      function ytexport () { yt org export --file $1 --user vito.canadi --yt-token $(cat /home/vcanadi/reports/vcanadi-yt-token); }

    '';

    variables = {
      PATH = ["$HOME/.local/bin"];
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      HISTTIMEFORMAT="%d/%m/%y %T ";
      KEYBOARD_DELAY = "200";
      KEYBOARD_RATE = "100";
      ALTERNATE_EDITOR = "";
      XDG_CONFIG_HOME = "/home/vcanadi/.config";
      WINDOW_MANAGER = "xmonad";
    };

    etc = {

      "zshrc.local".text = ''
        if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi
        DISABLE_AUTO_UPDATE="false"
        DISABLE_UNTRACKED_FILES_DIRTY="true"
        HIST_STAMPS="yyyy-mm-dd"
        plugins=( aws cabal catimg common-aliases dirpersist docker encode64 fasd git git-extras jsontools man per-directory-history sudo systemd tmux url-tools vi-mode wd zsh-syntax-highlighting )
        mkdir -p $HOME/.zsh
        export ZSH_CACHE_DIR="$HOME/.zsh"
        export COMPDUMPFILE="$HOME/.zsh"
        bindkey "^K" history-substring-search-up
        bindkey "^J" history-substring-search-down
        set -s escape-time 0
        precmd() { print "" }
      '';

      "inputrc".text = ''
        set editing-mode vim
      '';

      current-nixos-config.source = ./.;

      "sensors.d/isa-coretemp".text = ''
         chip "coretemp-isa-0000"
           label temp2 "Core 0"
           compute temp2 @-20,@-20

           label temp3 "Core 1"
           compute temp3 @-20,@-20
           '';
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs : {
      nixos-stable = import <nixos-stable> { config = config.nixpkgs.config; };
    };
  };

  nix = {
    buildCores = 12;
    maxJobs = 12;
  };

  services = {
    openssh = {
      enable = true;
      passwordAuthentication = true;
    };
    nixosManual.showManual = true;
    acpid.enable = true;
    emacs.enable = true;
  };

  # systemd.services.ycmds = {
  #    enable = true;
  #    description = "ycmd";
  #    serviceConfig = {
  #      Type = "forking";
  #      ExecStart = "${pkgs.ycmd}/bin/ycmd --options_file ${pkgs.copyPathToStore ./conf/ycmd.json}";
  #      ExecStop = "";
  #      Restart = "on-failure";
  #    };
  #    wantedBy = [ "default.target" ];
  #  };


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
  };

  system = {
    stateVersion = "18.09";
    activationScripts = utils.mkActivationScriptsForUsers [
      tmux-nix.tmuxp.userActivationScript
    ];
  };

  hardware = {
    enableAllFirmware = true;
    cpu.intel.updateMicrocode = true;
    # nvidiaOptimus.disable = true;
    # bumblebee = {
    #   enable = true;
    #   connectDisplay = true;
    #   driver = "nouveau";
    # };
    opengl.driSupport.enable = true;
    opengl.driSupport32Bit = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
  };

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  # };

}
