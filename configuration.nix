{ config, pkgs, ... }:

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
    systemPackages = import ./modules/systemPackages.nix pkgs;
    
    shellAliases = {
      vi = "vim";
      resx = "systemctl restart service display-manager.service";
      resnet = "systemctl restart service network-manager.service";
      gis = "git status";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch;";
      ac = "cd projects/ale-core";
      nixrepl = ''nix-repl "<nixpkgs>" "<nixpkgs/nixos>"''; 
    };

    interactiveShellInit = ''
      set editing-mode vi
      set keymap vi-command
      xset r rate 250 40
    '';

    variables = { 
      PATH = ["$HOME/.local/bin"]; 
      VISUAL = "vim";
      EDITOR = "$VISUAL";
      #HYDRA_DBI = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
      #HYDRA_DATA = "/var/lib/hydra";
      #HYDRA_CONFIG = "/var/lib/hydra/hydra.conf";
      #NIX_REMOTE = "daemon";
      PGHOST = "localhost";
      PGUSER = "ale";
      PGDATABASE = "ale";
      PGPASSWORD = "ale";
      PGPORT = "5432";
    };

    etc = {
      #"tmux.conf".source = "/etc/nixos/tmux.conf";
    };
  }; 

  #nix.package = pkgs.nixUnstable;  

  nix.extraOptions = '' 
    trusted-users = hydra root hydra-evaluator hydra-queue-runner
  '';

  nix.requireSignedBinaryCaches = false;

  nixpkgs.config = {
    allowUnfree = true;
  };


  services = {
    openssh.enable = true; 
    nixosManual.showManual = true;
    postgresql.enable = true;
    postgresql.package = pkgs.postgresql96;
    postgresql.authentication = pkgs.lib.mkForce ''
        # Generated file; do not edit!
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
    '';
  };


  programs = {
    fish.enable=true;
    bash.enableCompletion = true;
    tmux = {
      enable = true;
      shortcut = "a";
      keyMode = "vi";
      terminal = "rxvt-unicode-256color";
      #terminal = "screen";
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

        set -g pane-border-fg '#4d5057'
        set -g pane-active-border-fg '#4d5057'
        set -g window-style 'bg=colour255'
        set -g window-active-style 'fg=colour234,bg=colour231'

        bind -n M-h select-pane -L
        bind -n M-j select-pane -D 
        bind -n M-k select-pane -U
        bind -n M-l select-pane -R
      
      '';
    };
  };
  users.defaultUserShell="/run/current-system/sw/bin/fish";
  users.extraUsers.user.shell="${pkgs.fish}/bin/fish";

  system.stateVersion = "17.09";
  hardware.enableAllFirmware=true;
  security.polkit.enable = true;

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "bunkar" ];

}
