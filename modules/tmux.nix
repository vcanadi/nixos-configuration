pkgs :
let
  b = builtins;
  plugins = pkgs.tmuxPlugins;
in
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
    extraTmuxConf =
      let
        # Windows/workspace key values and their shifted values
        windows' = {
          "0" = ")";
          "1" = "!";
          "2" = "@";
          "3" = "#";
          "4" = "$";
          "5" = "%";
          "6" = "^";
          "7" = "&";
          "8" = "*";
          "9" = "(";
        };
        windows = b.attrNames windows';
        withShift = i: windows'.${i};
        mod = "M";
        tmux-dir = pkgs.copyPathToStore ./tmux;
        tmux-cpu = ./tmux-plugins/tmux-cpu;
    in
    ''

      # Remove all bindings
        unbind -a

      # Copy/Paste
        bind p run "xsel -o | tmux load-buffer - ; tmux paste-buffer"
        bind -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "xclip -i -f -selection primary | xclip -i -selection clipboard"

      # Don't rename after first command
        set -g automatic-rename on

      # Status bar
        set -g status on

      # Status bar
        set -g status-bg black
        set -g status-fg white
        set -g status-interval 2
        set -g status-left-length 30

        set-option -g status-attr default

      # Status bar's window title colors
        set -g window-status-fg green
        set -g window-status-bg default
        set -g window-status-attr dim
        set -g window-status-current-fg green
        set -g window-status-current-bg colour240
        set -g window-status-current-attr bright

      # Active pane/border fg and bg
        set -g window-style default
        set -g window-active-style default
        set-option -g pane-border-fg colour58
        set-option -g pane-active-border-fg colour1

      # Message text
        set-option -g message-bg colour235 #base02
        set-option -g message-fg colour166 #orange

      # pane number display
        set-option -g display-panes-active-colour colour1
        set-option -g display-panes-colour colour58

      # Clock
        set-window-option -g clock-mode-colour green #green
        set -g base-index 0

      # Synchronized control over multiple panes
        unbind-key s
        bind s set-window-option synchronize-panes
        set -g display-time 4000

      # When window 3 is deleted, rename windows 1,2,4 to 1,2,3
        set-option -g renumber-windows on

      # Manually replace prefixed commands that require two key strokes with single mod key (e.g. M-w replaces C-a + w )

        # Reload config
          bind -n ${mod}-r source-file /etc/tmux.conf \; display-message

        # Select/Swap windows
          ${b.concatStringsSep "\n" (map (i: "bind -n ${mod}-${i} select-window -t ${i}") windows)}
          ${b.concatStringsSep "\n" (map (i: "bind -n '${mod}-${withShift i}' swap-window -t ${i}") windows)}

        # Select pane
          bind -n ${mod}-h select-pane -L \; display-pane
          bind -n ${mod}-j select-pane -D \; display-pane
          bind -n ${mod}-k select-pane -U \; display-pane
          bind -n ${mod}-l select-pane -R \; display-pane

        # Create/Delete/Rename pane/window
          bind -n ${mod}-x confirm-before -p "kill-pane #P? (y/n)" kill-pane
          bind -n ${mod}-n new-window
          bind -n ${mod}-v split-window -v -c '#{pane_current_path}'
          bind -n ${mod}-b split-window -h -c '#{pane_current_path}'
          bind -n ${mod}-, command-prompt -I "#W" "rename-window -- '%%'"

        # Resize pane
          bind -n ${mod}-Y resize-pane -L
          bind -n ${mod}-U resize-pane -D
          bind -n ${mod}-I resize-pane -U
          bind -n ${mod}-O resize-pane -R
          bind -n ${mod}-z resize-pane -Z

        # Swap panes
          bind -n ${mod}-J swap-pane -D
          bind -n ${mod}-K swap-pane -U

        # Detach session
          bind -n ${mod}-d detach-client

        # Copy mode
          bind -n ${mod}-[ copy-mode
          bind -n ${mod}-] paste-buffer

        # Cmd
          bind -n ${mod}-: command-prompt

      # Status bar

        # run-shell ${plugins.cpu + ./share/tmux-plugins/cpu/cpu.tmux}

      # Name windows with directory path
        set-window-option -g window-status-current-format '#[fg=white,bold] #{window_index} #[fg=green]#(echo "#{pane_current_path}" | rev | cut -d'/' -f-1 | rev) #[fg=white]|'
        set-window-option -g window-status-format         '#[fg=white,bold] #{window_index} #[fg=blue]#(echo "#{pane_current_path}" | rev | cut -d'/' -f-1 | rev) #[fg=white]|'
    '';
  };

  tmuxp = rec {
    userActivationScript = user :
    let
      userProjPaths = let projsPath = user.home + "/./tmux-projects.nix";
          in if b.pathExists projsPath then import projsPath else [];

      userProjTemp = proj: ''
          - window_name: ${proj}
            layout: tiled
            shell_command_before:
              - cd ~/projects/${proj}
            panes:
              - vim
              - vim
              - ls

            '';
      userProjs = b.concatStringsSep "\n" (map userProjTemp userProjPaths);

      yamls = {
        main = ''
          session_name: main
          windows:
          - window_name: Reports
            layout: tiled
            shell_command_before:
              - cd ~/reports
            panes:
              - shell_command:
                  - emacsclient -nw .
              - ls

          ${userProjs}
          - window_name: NixConf
            layout: tiled
            shell_command_before:
              - cd /etc/nixos
            panes:
              - su
              - su

          - window_name: Music
            layout: tiled
            shell_command_before:
              - cd downloads/streams
            panes:
              - shell_command:
                 - mpv $(ls | sort -R | head -n 1)

        '';
      };
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

  };
}
