{config, pkgs, ...}:
{
 # xmonad 
 services.xserver = {
        enable = true;
        layout = "hr";
        xkbOptions = "eurosign:e";

        displayManager= 
        {
			lightdm.enable = true;     
		};

        windowManager.xmonad.enable = true;
        windowManager.xmonad.enableContribAndExtras = true;
    #   windowManager.xmonad.extraPackages = self: [ self.xmonadContrib ];
        windowManager.default = "xmonad";
    #  desktopManager.default = "xfce";
    
    };

 # gnome 
 /*services.xserver = {
        enable = true;
        layout = "hr";
        xkbOptions = "eurosign:e";


        desktopManager.gnome3.enable = true;
        desktopManager.default = "gnome3";
      
    };
*/
}	
