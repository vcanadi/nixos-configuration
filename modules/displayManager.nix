{config, pkgs, ...}:{
  
    services.xserver = {
        enable = true;
        layout = "us";
        windowManager = {
            xmonad = { enable = true; };
            default = "xmonad";
        };
    };	
}
