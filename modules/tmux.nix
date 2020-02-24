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
    extraConfig =
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
        set -g status-position top
        set -g status-style "bg=black"
        set -g status-style "fg=white"
        set -g status-interval 2
        set -g status-left-length 30
        set -g status-style "default"
        set -g status-right "#(cut -d ' ' -f -3 /proc/loadavg) %H:%M %d-%b-%y"

      # Status bar's window title colors
        set -g window-status-style "fg=green"
        set -g window-status-style "bg=default"
        set -g window-status-style "default"
        set -g window-status-current-style "fg=green"
        set -g window-status-current-style "bg=colour240"
        set -g window-status-current-style "default"

      # Active pane/border fg and bg
        set -g window-style "bg=#DDDDDD"
        set -g window-active-style "bg=#FFFFFF"
        set -g pane-border-style "bg=white"
        set -g pane-active-border-style "bg=green"
        set -g pane-active-border-style "fg=black"
        set -g pane-border-status bottom
        set -g pane-border-format '#{pane_title}'

      # Message text
        set -g message-style "bg=colour235" #base02
        set -g message-style "fg=colour166" #orange

      # Clock
        set-window-option -g clock-mode-colour green #green
        set -g base-index 0

      # Synchronized control over multiple panes
        unbind-key s
        bind s set-window-option synchronize-panes
        set -g display-time 4000

      # When window 3 is deleted, rename windows 1,2,4 to 1,2,3
        set -g renumber-windows on

      # Manually replace prefixed commands that require two key strokes with single mod key (e.g. M-w replaces C-a + w )

        # Reload config
          bind -n ${mod}-r source-file /etc/tmux.conf \; display-message

        # Select/Swap windows
          ${b.concatStringsSep "\n" (map (i: "bind -n ${mod}-${i} select-window -t ${i}") windows)}
          ${b.concatStringsSep "\n" (map (i: "bind -n '${mod}-${withShift i}' swap-window -t ${i}") windows)}

        # Select pane
          bind -n ${mod}-h select-pane -L
          bind -n ${mod}-j select-pane -D
          bind -n ${mod}-k select-pane -U
          bind -n ${mod}-l select-pane -R

        # Create/Delete/Rename pane/window
          bind -n ${mod}-x confirm-before -p "kill-pane #P? (y/n)" kill-pane
          bind -n ${mod}-n new-window
          bind -n ${mod}-u split-window -v -c '#{pane_current_path}'
          bind -n ${mod}-o split-window -h -c '#{pane_current_path}'
          bind -n ${mod}-i split-window -vb -c '#{pane_current_path}'
          bind -n ${mod}-y split-window -hb -c '#{pane_current_path}'
          bind -n ${mod}-, command-prompt -I "#W" "rename-window -- '%%'"

        # Resize pane
          bind -n ${mod}-H resize-pane -L
          bind -n ${mod}-J resize-pane -D
          bind -n ${mod}-K resize-pane -U
          bind -n ${mod}-L resize-pane -R
          bind -n ${mod}-z resize-pane -Z

        # Swap panes
          bind -n ${mod}-U swap-pane -D
          bind -n ${mod}-I swap-pane -U

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
      userProjPaths = let projsPath = user.home + "/.tmux-projects.nix";
          in if b.pathExists projsPath then import projsPath else [];

      userProjTemp = proj: ''
          - window_name: ${proj}
            start_directory: ~/projects/${proj}
            layout: tiled
            panes:
              - vim
              - vim
              - ls
            '';
      userProjs = b.concatStringsSep "\n" (map userProjTemp userProjPaths);

      htoprc0 = b.toFile "htoprc0" ''
        fields=48 46 47 49 1
        sort_key=46
        sort_direction=1
        hide_threads=1
        hide_kernel_threads=1
        hide_userland_threads=1
        shadow_other_users=1
        show_thread_names=0
        show_program_path=1
        highlight_base_name=0
        highlight_megabytes=1
        highlight_threads=1
        tree_view=0
        header_margin=1
        detailed_cpu_time=0
        cpu_count_from_zero=0
        update_process_names=0
        account_guest_in_cpu_meter=0
        color_scheme=3
        delay=10
        left_meters=LeftCPUs2 LeftCPUs2
        left_meter_modes=1 3
        right_meters=RightCPUs2 RightCPUs2 Tasks LoadAverage Uptime
        right_meter_modes=1 3 2 2 2
      '';

      htoprc1 = b.toFile "htoprc0" ''
        fields=48 46 47 49 1
        sort_key=46
        sort_direction=1
        hide_threads=1
        hide_kernel_threads=1
        hide_userland_threads=1
        shadow_other_users=1
        show_thread_names=0
        show_program_path=1
        highlight_base_name=0
        highlight_megabytes=1
        highlight_threads=1
        tree_view=0
        header_margin=1
        detailed_cpu_time=0
        cpu_count_from_zero=0
        update_process_names=0
        account_guest_in_cpu_meter=0
        color_scheme=3
        delay=10
        left_meters=Memory Swap
        left_meter_modes=1 1
        right_meters=Memory
        right_meter_modes=3
      '';

      yamls = {
        main = ''
          session_name: main
          windows:
          - window_name: NixConf
            start_directory: /etc/nix
            layout: tiled
            panes:
              - su
              - su
              - su

          ${userProjs}
          '';

        monitor = ''
          session_name: monitor
          windows:
          - window_name: monitorwin
            layout: even-horizontal
            shell_command_before:
            - tmux split-window -h
            - tmux split-window -h
            - tmux select-layout even-horizontal
            - tmux select-pane -t 0
            - tmux resize-pane -L 60
            - tmux split-window -v
            - tmux select-pane -t 3
            - tmux resize-pane -R 60
            - tmux split-window -v
            - tmux send -t 0 'HTOPRC=${htoprc0} htop --sort-key=PERCENT_CPU' Enter
            - tmux send -t 1 'HTOPRC=${htoprc1} htop --sort-key=PERCENT_MEM' Enter
            - tmux send -t 3 'nvidia-smi -l 1' Enter
            - tmux send -t 4 'nvtop' Enter
            panes:
            - null
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
