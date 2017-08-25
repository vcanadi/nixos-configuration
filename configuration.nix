{ config, pkgs, ... }:
{
    imports = [ # Include the results of the hardware scan.
        ./hardware-configuration.nix	
        ./modules/displayManager.nix
        ./modules/locale.nix
        ./modules/touch.nix	
        ./modules/net.nix
        ./modules/video.nix
        ./modules/audio.nix
        ./modules/jobs.nix
        ./modules/users.nix
        ];

environment.systemPackages = import ./modules/systemPackages.nix pkgs;

nixpkgs.config.packageOverrides = super: 
    let self = super.pkgs; in
    let hspkg = self.haskell.packages.ghc801; in {
/*    ghc = hspkg.ghcWithHoogle
                     (hsss: with hspkg; [

                       	stack

                     ]);


    torbrowser = super.torbrowser.override {
      extraPrefs = ''
        lockPref("browser.tabs.remote.autostart", false);
        lockPref("browser.tabs.remote.autostart.2", false);
      '';
    };
*/
    };
    
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
    services.openssh.enable = true;
   
    services.nixosManual.showManual = true;

#    services.postgresql.enable = true;
#    services.postgresql.package = pkgs.postgresql94;
#    services.postgresql.authentication = "local all all ident";
#    services.postgresql.dataDir = "/var/db/postgresql/9.5/";

#-----------------UNFREE-----------------------
#----------------------------------------------
nixpkgs.config.allowUnfree = true;	


# Boot
# -------------------------------------------
# -------------------------------------------
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
			

# Use the gummiboot efi boot loader.
#    boot.loader.gummiboot.enable = true;
#    boot.loader.efi.canTouchEfiVariables = true;
#    boot.loader.grub.device="/dev/sda";
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

# browser plugins
#--------------------------------------------
#-------------------------------------------- 

#	nixpkgs.config.firefox = {
#		 enableGoogleTalkPlugin = true;
#		 enableAdobeFlash = true;
#		};
/*
	 nixpkgs.config.chromium = {
		 enablePepperFlash = true; 
		 enablePepperPDF = true;
		};
*/
/*
programs.zsh.interactiveShellInit = ''
  export ZSH=${pkgs.oh-my-zsh}/share/oh-my-zsh/

  # Customize your oh-my-zsh options here
  ZSH_THEME="steeef"
  plugins=(git)
  source $ZSH/oh-my-zsh.sh
'';
#programs.zsh.promptInit = "";

programs.zsh.enable=true;
users.defaultUserShell="/run/current-system/sw/bin/zsh";
*/

programs.fish.enable=true;
users.defaultUserShell="/run/current-system/sw/bin/fish";
users.extraUsers.user.shell="${pkgs.fish}/bin/fish";


}



