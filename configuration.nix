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
  };

  environment={
    systemPackages = import ./modules/systemPackages.nix pkgs;
    
    shellAliases = {
      gis = "git status";
      nixc = "cd /etc/nixos";
      nixb = "nixos-rebuild switch; . /etc/keys";
      nodemon = "~/node_modules/.bin/nodemon"; 
    };

    interactiveShellInit = ''
    export PATH="$PATH:$HOME/.local/bin"
    '';
  }; 

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "radivarig" ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.bash.enableCompletion = true;

  services.openssh.enable = true; 

  programs.fish.enable=true;
  users.defaultUserShell="/run/current-system/sw/bin/fish";
  users.extraUsers.user.shell="${pkgs.fish}/bin/fish";

  system.stateVersion = "17.03";
}
