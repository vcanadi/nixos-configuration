{config, pkgs, ...}:{
  
  services.xserver = {
    enable = true;
    layout = "us,hr";
    windowManager = {
      xmonad = { 
        enable = true; 
        enableContribAndExtras = true;
        extraPackages = with pkgs.haskellPackages; haskellPackages: [ xmobar ];
      };
      default = "xmonad";
    };
    xkbOptions = "caps:escape,grp:rctrl_rshift_toggle";
    config = '' '' ;
  };	

  i18n = {
			consoleFont = "lat9w-10";
      consoleUseXkbConfig = true;
		};


}
