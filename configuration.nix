


# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
		imports =
		[ # Include the results of the hardware scan.
			./hardware-configuration.nix	
			./customConfs/displayManager.nix
			./customConfs/locale.nix
			./customConfs/touch.nix	
			./customConfs/net.nix
			./customConfs/video.nix
			./customConfs/audio.nix
		];

		




	#nixpkgs.config.allowBroken=true;



# -----------------PACKAGES------------------
# -------------------------------------------
# -------------------------------------------
  

	# List packages installed in system profile. To search by name, run:
	# $ nix-env -qaP | grep wget
	   
	environment.systemPackages = with pkgs; 
	[
		wget
		nox			#search nix packages
		
	#osnovno 

		chromium
	#	firefox
		firefoxWrapper
		transmission_gtk
		mplayer
		smplayer
		vlc
		skype
		

	#text editori

		vim
		geany
		sublime	

	#prog

		git
		octave	
		ghc
		swiProlog
		nix-repl
		pari
		python3		
		pythonPackages.numpy
		#pythonPackages.tensorflow
		
		docker
		python35Packages.docker

		#sage
		/*
		(lib.overrideDerivation sage (attrs:{
			src = fetchurl {
			url = "http://mirror.switch.ch/mirror/sagemath/";
			sha256="0kbzs0l9q7y34jv3f8rd1c2mrjsjkdgaw6mfdwjlpg9g4gghmq5y";
			};
		}))
		*/    
		
#		teyjus
#		mueval
#		ocaml


		
	#tools

		#terminal
		terminator
		
		#connman gui
		cmst

		dhcpcd
		
		wpa_supplicant
		unzip
		qjackctl

		gparted

		lshw
		hwinfo		
		conky
		atop

		intel-gpu-tools
		cudatoolkit
		
		dmenu
		gmrun
		jdk

		wine
		winetricks
		scrot			# screenshot
		feh 			# image viewer
		psmisc	
		linuxPackages_3_10.nvidiabl

		x2goclient
		


		#xmonad sranja
		haskellPackages.xmobar
		haskellPackages.xmonad
		
		



	];
   

	virtualisation.virtualbox.host.enable=true;
 	virtualisation.docker.enable = true;
 	
 nixpkgs.config.packageOverrides = super: let self = super.pkgs; in
  {
    ghc = self.haskellPackages.ghcWithHoogle
                     (haskellPackages: with haskellPackages; [
                       # libraries
                       ghc-mod
                       mtl QuickCheck
                       arrows async cgi criterion
                       #mueval
                       show
                       #accelerate
                       random
                       random-shuffle
					   bindings-GLFW
					   GLFW
					   netwire
					   core
					   event
                       graphics-drawingcombinators

                       
                     ]);


    

    myPythonEnv = self.myEnvFun {
        name = "mypython";
        buildInputs =  [
          self.python35
          #self.pythonPackages.tensorflow
          #python33Packages.jinja2
        ];
    };
  };
    
  
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
   services.openssh.enable = true;
   
  # Enable CUPS to print documents.
  # services.printing.enable = true;
  
	services.nixosManual.showManual = true;






	
	 
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
		#	"nouveau"
		#	"i915"
			];

		boot.kernelParams=[
		#	"nomodeset"
		#	"video=vesa:off"
		#	"vga=normal"
		];
		#boot.vesa=false;
			




		




	# Use the gummiboot efi boot loader.
	#	boot.loader.gummiboot.enable = true;
	#	boot.loader.efi.canTouchEfiVariables = true;
	#	boot.loader.grub.device="/dev/sda";
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
		          set root='(hd0,3)'   # sda4. y u got dumb nums, grub?
		        chainloader +1
		      }  
		    '';
		  };


  


  
# The NixOS release to be compatible with for stateful data such as databases.
	system.stateVersion = "16.09";


 security.polkit.enable=true;

# browser plugins
#--------------------------------------------
#-------------------------------------------- 

	nixpkgs.config.firefox = {
		 enableGoogleTalkPlugin = true;
		 enableAdobeFlash = true;
		};

	 nixpkgs.config.chromium = {
		 enablePepperFlash = true; # Chromium removed support for Mozilla (NPAPI) plugins so Adobe Flash no longer works
		 enablePepperPDF = true;
		};


}












