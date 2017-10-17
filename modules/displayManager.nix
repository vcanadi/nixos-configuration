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
  };	
}
