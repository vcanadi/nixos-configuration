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
    systemPackages = import ./modules/systemPackages.nix pkgs ++ emacs-nix.emacsAndDaemon;

    shellAliases = {
      vi = "vim";
      resx = "systemctl restart service display-manager.service";
      resnet = "systemctl restart service network-manager.service";
      gis = "git status";
      gid = "git diff";
      gil = "git log";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch;";
      ac = "cd projects/ale-core";
      an = "cd projects/ale-nixops";
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

      emacs = pkgs.emacs.overrideDerivation (args: rec {
        withGTK3 = true;
        withGTK2 = false;
        pythonPath = [];
        buildInputs = with pkgs; (args.buildInputs ++
        [
          makeWrapper
          python
          python27Packages.setuptools
          python27Packages.pip
          python27Packages.ipython
          python27Packages.numpy
        ]);

        postInstall = with pkgs.python27Packages; (args.postInstall + ''
        echo "This is PYTHONPATH: " $PYTHONPATH
        wrapProgram $out/bin/emacs \
        --prefix PYTHONPATH : "$(toPythonPath ${python}):$(toPythonPath ${ipython}):$(toPythonPath ${setuptools}):$(toPythonPath ${pip}):$(toPythonPath ${numpy}):$PYTHONPATH";
        '');
      });

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

    influxdb = {
      enable = true;
      extraConfig = {
        host = "127.0.0.1";
        port = 8086;
        version =  "0.9";

        database = "metrics";
        username = "root";
        password = "root";
        flush.enable = true;
        proxy = {
          enable= false;
          suffix= "raw";
          flushInterval= 1000;
        };
        backends = ["./backends/console"];
        debug= true;
        legacyNamespace= false;
        admin = {
          enabled = true;
          bind-address = ":     8083";
        };
      };

    };

    graphite = {

      api = {
        enable = true;
        port = 8888;
        finders = [ pkgs.python27Packages.graphite_influxdb ];
        extraConfig = ''
          allowed_origins:
            - dashboard.example.com
          cheat_times: true
          influxdb:
            host: localhost
            port: 8086
            user: influxdb
            pass: influxdb
            db: metrics

        '';
      };

      carbon = {
        enableCache = true;
        # save disk usage by restricting to 1 bulk update per second
        config = ''
          [cache]
          MAX_CACHE_SIZE = inf
          MAX_UPDATES_PER_SECOND = 1
          MAX_CREATES_PER_MINUTE = 50
          '';
        storageSchemas = ''
          [carbon]
          pattern = ^carbon\.
          retentions = 60:90d

          [default]
          pattern = .*
          retentions = 60s:30d,300s:1y
          '';
      };
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
      sakura-nix.userActivationScript
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
