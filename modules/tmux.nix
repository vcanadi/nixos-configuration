pkgs :
let b = builtins; in
{
  tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    terminal = "rxvt-unicode-256color";
    clock24 = true;
    customPaneNavigationAndResize = true;
    aggressiveResize = true;
    escapeTime = 0;
    historyLimit = 100000;
    extraTmuxConf = ''

      # Vim style
      #bind-key -t vi-copy y copy-pipe "xsel -i -p -b"
      bind-key p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"

      # Status bar
      set -g status on
      bind-key S set-option -g status

      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g base-index 1
      set-option -g prefix `

      unbind-key s
      bind-key s set-window-option synchronize-panes

      unbind-key v
      bind-key v split-window -h

      bind -n M-h select-pane -L \; display-pane
      bind -n M-j select-pane -D \; display-pane
      bind -n M-k select-pane -U \; display-pane
      bind -n M-l select-pane -R \; display-pane

      bind \ split-window -h -c '#{pane_current_path}'  # Split panes horizontal
      bind - split-window -v -c '#{pane_current_path}'  # Split panes vertically

      bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"
    '';
  };

  tmuxp = rec {
    userActivationScript = user :
    let
      cmdCreateProjectYamls = b.concatStringsSep "\n" (
        pkgs.lib.mapAttrsToList (n: yaml:
          let filePath = "${n}.yml"; in ''
            cp ${b.toFile "" yaml} ${filePath}
            chown ${user.name}:nogroup ${filePath}
          ''
        ) yamls
      );
    in ''
      cd ${user.home}
      if [ -d .tmuxp ]; then rm .tmuxp -r; fi
      mkdir .tmuxp
      chown ${user.name}:nogroup .tmuxp
      cd .tmuxp
      ${cmdCreateProjectYamls}
    '';

    yamls = {
      work = ''
        session_name: main
        windows:
        - window_name: projects
          layout: tiled
          shell_command_before:
            - cd ~/projects
          panes:
            - l
            - l
            - l


        - window_name: reports
          layout: tiled
          shell_command_before:
            - cd ~/reports
          panes:
            - shell_command:
                - emacs -nw .
      '';

      nix = ''
        session_name: nix
        windows:
        - window_name: nix
          layout: tiled
          shell_command_before:
            - cd /etc/nixos
          panes:
            - shell_command:
                - sudo vim configuration.nix
            - su
      '';
    };
  };
}
