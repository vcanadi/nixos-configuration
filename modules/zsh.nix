{ pkgs }:
{
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      defaultKeymap="viins";
      initExtra = ''
        DISABLE_AUTO_UPDATE="false"
        DISABLE_UNTRACKED_FILES_DIRTY="true"
        HIST_STAMPS="yyyy-mm-dd"
        bindkey "^K" history-substring-search-up
        bindkey "^J" history-substring-search-down
        set -s escape-time 0
        fqget(){ watch -n -0.5 "cpufreq-info  | grep 'current CPU'"; }
        fqset(){ for i in $(seq 0 $(($(nproc) - 1))); do; cpufreq-set -c $i -u $1; done; }
        PS1="$PS1<$IN_NIX_SHELL> ";
        arun(){
          PROJ="$1"
          CORE="$2"
          DEV="$3"
          echo "\$1: $1"
          echo "\$2: $2"
          echo "\$3: $3"
          COMPILE_CMD="arduino-cli compile --fqbn arduino:avr:$CORE $HOME/arps/$PROJ"
          UPLOAD_CMD="arduino-cli upload -p $DEV --fqbn arduino:avr:$CORE $HOME/arps/$PROJ"
          SERIAL_OUTPUT_CMD="cat $DEV"
          echo "COMPILE CMD: $COMPILE_CMD"
          echo "UPLOAD CMD: $UPLOAD_CMD"
          echo "SERIAL OUTPUT CMD: $SERIAL_OUTPUT_CMD"
          echo "$HOME/arps/$1/$1.ino" | entr -sr "$COMPILE_CMD; $UPLOAD_CMD && $SERIAL_OUTPUT_CMD"
        }
      '';
      plugins = [
        {
          name = "zsh-nix-shell";
          file = "nix-shell.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "chisui";
            repo = "zsh-nix-shell";
            rev = "v0.1.0";
            sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
          };
        }
      ];
      oh-my-zsh = {
        enable = true;
        theme = "jreese";
        plugins= [ "common-aliases" "fasd" "git" "git-extras" "man" "systemd" "tmux" "vi-mode" "wd" "history-substring-search" "fzf" ];
      };
      shellAliases = {
        nixc = "cd /etc/nixos; vim configuration.nix";
        nixb = "cd /etc/nixos; nixos-rebuild switch";
        sc = "systemctl";
        scr = "sc restart";
        scsp = "sc stop";
        scsr = "sc start";
        tmux= "tmux -f /etc/tmux.conf";
        em = "emacs -nw";
        myxmobar = "xmobar /home/vcanadi/.xmonad/xmobar.hs";
        ns = "nix-shell";
      };
      sessionVariables = {
        VISUAL = "vim";
        EDITOR = "$VISUAL";
        HISTTIMEFORMAT="%d/%m/%y %T ";
        KEYBOARD_DELAY = "200";
        KEYBOARD_RATE = "100";
        ALTERNATE_EDITOR = "";
        WINDOW_MANAGER = "xmonad";
        JAVA_AWT_WM_NONREPARENTING = "1";
        XKB_DEFAULT_OPTIONS = "caps:escape,grp:rctrl_rshift_toggle,ctrl:ralt_rctrl,terminate:ctrl_alt_bksp";
        PS1 = "$PS1<$IN_NIX_SHELL> ";
      };
    }
