{ config, pkgs, lib, ... }:
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

    security.chromiumSuidSandbox.enable= true;

    environment.systemPackages = import ./modules/systemPackages.nix pkgs;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
    services.openssh.enable = true;
   
    services.redshift.enable = true;
    services.redshift.latitude = "46";
    services.redshift.longitude = "16";

    services.nixosManual.showManual = true;

    # postgres
    services.postgresql.enable = true;
    services.postgresql.package = pkgs.postgresql94;
    services.postgresql.authentication = lib.mkForce ''
      # Generated file; do not edit!
      # TYPE  DATABASE        USER            ADDRESS                 METHOD
      local   all             all                                     trust
      host    all             all             127.0.0.1/32            trust
      host    all             all             ::1/128                 trust
      '';

      nixpkgs.config.allowUnfree = true;	



    boot.kernelModules = [ "snd-seq" "snd-rawmidi" ];
    boot.extraModprobeConfig = ''options snd_hda_intel enable=0,1'';
    boot.blacklistedKernelModules = [ 
        "snd_pcsp" 
    #   "nouveau"
    #    "i915"
        ];

    boot.kernelParams=[
    #	"nomodeset"
    #	"video=vesa:off"
    #	"vga=normal"
        ];
    #boot.vesa=false;
        
    boot.loader.grub = {
        enable = true;
        version = 2;
        copyKernels = true; # copy kernels to /boot so hopefully other linuxes
		            # can detect them
    # Define on which hard drive you want to install Grub.
		      device = "/dev/sda";
		      extraEntries = ''
		        menuentry 'Ubuntu' {
		          insmod ext2
		          set root='(hd0,3)'   
		        chainloader +1
		      }  
		    '';
		  };


  
    # The NixOS release to be compatible with for stateful data such as databases.
    system.stateVersion = "17.03";


    security.polkit.enable=true;


    programs.fish.enable=true;
    users.defaultUserShell="/run/current-system/sw/bin/fish";
    users.extraUsers.user.shell="${pkgs.fish}/bin/fish";

}



