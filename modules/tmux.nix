pkgs :
let b = builtins; in
{
  tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    #terminal = "rxvt-unicode-256color";
    terminal = "screen-256color";
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

      # Vim split keys
      unbind-key s
      bind-key s split-window
      unbind-key v
      bind-key v split-window -h

      bind -n M-h select-pane -L \; display-pane
      bind -n M-j select-pane -D \; display-pane
      bind -n M-k select-pane -U \; display-pane
      bind -n M-l select-pane -R \; display-pane


    '';
  };

  tmuxinator = rec {
    userActivationScript = user :
    let
      cmdCreateProjectYamls = b.concatStringsSep "\n" (
        pkgs.lib.imap0 (i: yaml:
          let filePath = "config-${b.toString i}.yml"; in ''
            cp ${b.toFile "" yaml} ${filePath}
            chown ${user.name}:nogroup ${filePath}
          ''
        ) yamls
      );
    in ''
      cd ${user.home}
      if [ -d .tmuxinator ]; then rm .tmuxinator -r; fi
      mkdir .tmuxinator
      chown ${user.name}:nogroup .tmuxinator
      cd .tmuxinator
      ${cmdCreateProjectYamls}
    '';

    yamls = [''
      name: nixconf
      root: ~/

      windows:
        - nixconf:
            layout: main-vertical
            root: /etc/nixos
            panes:
              - vim configuration.nix
              -
    ''];
  };
}
