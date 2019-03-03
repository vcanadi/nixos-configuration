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
    };

    variables = {
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      HISTTIMEFORMAT="%d/%m/%y %T ";
      KEYBOARD_DELAY = "200";
      KEYBOARD_RATE = "100";
      ALTERNATE_EDITOR = "";
      WINDOW_MANAGER = "xmonad";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };

    etc = {
      "zshrc.local".text = ''
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
        my-cpufreq-info(){ watch -n -0.5 "cpufreq-info  | grep 'current CPU'"; }
        my-cpufreq-set(){ for i in $(seq 0 $(($(nproc) - 1))); do; cpufreq-set -c $i -u $1; done; }
      '';

      "inputrc".text = ''
        set editing-mode vim
      '';
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

    clipmenu.enable = true;

    redshift = {
      enable = true;
      latitude = "46";
      longitude = "16";
    };

    jupyter = {
      enable = true;
      password = "";
      kernels = {

        python3 = let
            env = (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
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
    jupyter = {
      wantedBy = [ "multi-user.target" ];
      environment = {
        NUMBAPRO_NVVM="${pkgs.cudatoolkit}/nvvm/lib64/libnvvm.so";
        NUMBAPRO_LIBDEVICE="${pkgs.cudatoolkit}/nvvm/libdevice/";
        NUMBAPRO_CUDA_DRIVER="${pkgs.linuxPackages_latest.nvidia_x11}/lib/libcuda.so";
      };
    };
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
      ohMyZsh = {
        enable = true;
        theme = "jreese";
        plugins = [ "vi-mode" "history-substring-search" ];
      };
    };
    bash.enableCompletion = true;
    tmux = tmux-nix.tmux;
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

  i18n = {
    consoleFont = "lat9w-12";
    consoleUseXkbConfig = true;
    consoleColors = [
      "FFFFFF" #white
      "E5E5E5" #lightgrey
      "44C9C9" #cyan
      "5FAFAF" #darkcyan
      "D633B2" #magenta
      "BD53A5" #darkmagenta
      "FFD75F" #yellow
      "D75F5F" #darkred
      "7373C9" #blue
      "D7AF87" #brown
      "232323" #darkgrey
      "2B2B2B" #darkgrey
      "E33636" #red
      "87AF5F" #darkgreen
      "98E34D" #green
      "8787AF" #darkblue
    ];
  };
}

