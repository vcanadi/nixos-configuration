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
    kernelModules = [ "coretemp" ];
    # kernelPackages = pkgs.linuxPackages_4_19;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  environment = {
    systemPackages = import ./modules/systemPackages.nix pkgs;

    shellAliases = {
      vi = "vim";
      gis = "git status";
      nixc = "cd /etc/nixos; vim configuration.nix";
      nixb = "cd /etc/nixos; nixos-rebuild switch";
      sc = "systemctl";
      hgrep = ''
        grep -rni \
          --include \*.hs \
          --include \*.cabal \
          --include \*.yaml \
          --include \*.nix \
          --exclude-dir .stack-work \
      '';
      scr = "sc restart";
      scsp = "sc stop";
      scsr = "sc start";
    };

    variables = {
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      HISTTIMEFORMAT="%d/%m/%y %T ";
      KEYBOARD_DELAY = "200";
      KEYBOARD_RATE = "100";
      ALTERNATE_EDITOR = "";
      WINDOW_MANAGER = "xmonad";
      JAVA_AWT_WM_NONREPARENTING = "1";
      XKB_DEFAULT_OPTIONS = "caps:escape,grp:rctrl_rshift_toggle,ctrl:ralt_rctrl,terminate:ctrl_alt_bksp";
    };

    etc = {
      "inputrc".text = ''
        set editing-mode vim
      '';
      "subuid".text = "vcanadi:100000:65536";
      "subgid".text = "vcanadi:100000:65536";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;

    packageOverrides = pkgs : {
      browsh-vim = pkgs.browsh.overrideDerivation (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "browsh-org";
          repo = "browsh";
          rev = "0c0b9073e459cfbae00a4466375bd03879b20b76";
          sha256 = "10q1il6qd9f6h7hc861kqsh3nvl948dwhlayw69wq54jjq1zqlv9";
        };
      });

      pkg-config = pkgs.pkg-config.overrideDerivation (args: {
      });

      nixos-stable = import <nixos-stable> { config = config.nixpkgs.config; };
    };
  };
  nix = {
    buildCores = 12;
    maxJobs = 12;
  };

  location = {
    latitude = 46.0;
    longitude = 16.0;
  };

  services = {

    # teamviewer.enable = true;

    openssh = {
      # enable = true;
      passwordAuthentication = false;
    };

    clipmenu.enable = true;

    # redshift = {
    #   enable = true;
    # };

    jupyter = {
      enable = false;
      password = "";
      kernels = {

        python3 = let
            env = (pkgs.python36.withPackages (pythonPackages: with pythonPackages; [
                    numpy
                    ipywidgets
                    matplotlib
                    # h5py
                    # scipy
                    # pillow
                    # pandas
                    # scikitlearn
                    tensorflowWithCuda
                    # psutil
                    # xgboost
                    (opencv3.override { enableUnfree = true; enableGtk2 = true;})
                  ]));
          in {

            displayName = "Python 3 for machine learning";

            argv = [
                  "${env.interpreter}"
                  "-m"
                  "ipykernel_launcher"
                  "-f"
                  "{connection_file}"
                ];
            language = "python";
          };

      };
    };
  };

  # Custom services
  systemd.services = {
    cpufreq-fixed = {
      description = "Set fixed CPU frequency";
      after = [ "systemd-modules-load.service" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.linuxPackages.cpupower ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = "no";
        ExecStart = "${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -u 3600000";
        SuccessExitStatus = "0 237";
      };
    };

    # For numba
    # jupyter = {
    #   wantedBy = [ "multi-user.target" ];
    #   environment = {
    #     NUMBAPRO_NVVM="${pkgs.cudatoolkit}/nvvm/lib64/libnvvm.so";
    #     NUMBAPRO_LIBDEVICE="${pkgs.cudatoolkit}/nvvm/libdevice/";
    #     NUMBAPRO_CUDA_DRIVER="${pkgs.linuxPackages_latest.nvidia_x11}/lib/libcuda.so";
    #   };
    # };
  };


  security = {
    polkit.enable = true;
  };

  programs = {
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      promptInit = ''
        DISABLE_AUTO_UPDATE="false"
        DISABLE_UNTRACKED_FILES_DIRTY="true"
        HIST_STAMPS="yyyy-mm-dd"
        mkdir -p $HOME/.zsh
        mkdir -p $HOME/.fzf
        rm $HOME/.fzf/shell -f
        ln -sf ${pkgs.fzf.outPath}/share/fzf $HOME/.fzf/shell
        export ZSH_CACHE_DIR="$HOME/.zsh"
        export COMPDUMPFILE="$HOME/.zsh"
        bindkey "^K" history-substring-search-up
        bindkey "^J" history-substring-search-down
        set -s escape-time 0
        my-cpufreq-info(){ watch -n -0.5 "cpufreq-info  | grep 'current CPU'"; }
        my-cpufreq-set(){ for i in $(seq 0 $(($(nproc) - 1))); do; cpufreq-set -c $i -u $1; done; }
      '';
      ohMyZsh = {
        enable = true;
        theme = "jreese";
        plugins= [ "common-aliases" "fasd" "git" "git-extras" "man" "systemd" "tmux" "vi-mode" "wd" "history-substring-search" "fzf" ];
        customPkgs = [ pkgs.deer ];
      };
    };
    java.enable = true;
    bash.enableCompletion = true;
    tmux = tmux-nix.tmux;
    sway = {
      enable = true;
    };
  };

  system = {
    activationScripts = utils.mkActivationScriptsForUsers [
      # tmux-nix.tmuxp.userActivationScript
    ];
  };

  hardware = {
    # bumblebee.enable = true;
    opengl.driSupport.enable = true;
    opengl.driSupport32Bit = true;
  };

  users = {
    defaultUserShell = pkgs.zsh;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  fonts = {
    enableDefaultFonts = true;
    enableFontDir = true;
  };

  console = {
    font = "lat9w-12";
    useXkbConfig = true;
    };

  # i18n = {
  #   consoleFont = "lat9w-12";
  #   consoleUseXkbConfig = true;
  #   };

  virtualisation = {
    docker = {
      # enable = true;
      liveRestore = false;
    };
    # virtualbox = {
    #   host.enable = true;
    #   guest.enable = true;
    # };
  };
}

