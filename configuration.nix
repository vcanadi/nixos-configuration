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
      gis = "git status";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch;";
      nodemon = "~/node_modules/.bin/nodemon"; 
      ac = "cd projects/ale-core";
      nixrepl = ''nix-repl "<nixpkgs>" "<nixpkgs/nixos>"''; 
    };

    interactiveShellInit = ''
      export PATH="$PATH:$HOME/.local/bin"
      export VISUAL=vim
      export EDITOR="$VISUAL"
      set editing-mode vi
      set keymap vi-command
      xset r rate 250 40
    '';

    variables = { 
      HYDRA_DBI = "dbi:Pg:dbname=hydra;host=localhost;user=hydra;";
      HYDRA_DATA = "/var/lib/hydra";
      NIX_REMOTE = "daemon";
    };
    
  }; 

  nix.extraOptions = '' 
    trusted-users = hydra root hydra-evaluator hydra-queue-runner
  '';

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.bash.enableCompletion = true;

  services = {
    openssh.enable = true; 
    nixosManual.showManual = true;
    postgresql.enable = true;
    postgresql.package = pkgs.postgresql94;
    postgresql.authentication = pkgs.lib.mkForce ''
        # Generated file; do not edit!
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
    '';
  };


  programs.fish.enable=true;
  users.defaultUserShell="/run/current-system/sw/bin/fish";
  users.extraUsers.user.shell="${pkgs.fish}/bin/fish";

  system.stateVersion = "17.09";
  hardware.enableAllFirmware=true;
  security.polkit.enable = true;
}
