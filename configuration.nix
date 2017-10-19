{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix	
    ./modules/displayManager.nix
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

  environment={
    systemPackages = import ./modules/systemPackages.nix pkgs;
    
    shellAliases = {
      gis = "git status";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch; . /etc/keys";
      nodemon = "~/node_modules/.bin/nodemon"; 
      ac = "cd projects/ale-core";
    };

    interactiveShellInit = ''
      export PATH="$PATH:$HOME/.local/bin"
      export VISUAL=vim
      export EDITOR="$VISUAL"
      export HYDRA_DBI="dbi:Pg:dbname=hydra;host=localhost;user=hydra;"
      export HYDRA_DATA=/var/lib/hydra
      set editing-mode vi
      set keymap vi-command
      #. /etc/keys
    '';
  }; 

  nix.extraOptions = '' 
    trusted-users = hydra hydra-evaluator hydra-queue-runner
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
