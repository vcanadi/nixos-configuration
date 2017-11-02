{config, pkgs, ...}:{
  
  services.xserver = {
    enable = true;
    layout = "us";
    windowManager = {
      xmonad = { 
        enable = true; 
        enableContribAndExtras = true;
        extraPackages = with pkgs.haskellPackages; haskellPackages: [ xmobar ];
      };
      default = "xmonad";
    };
    xkbOptions = "caps:escape";
    config = '' '' ;
  };	

  i18n = {
			consoleFont = "lat9w-10";
      consoleUseXkbConfig = true;
		};


}
