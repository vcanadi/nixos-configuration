{ config, pkgs, ...}: {
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us,hr";
    autoRepeatDelay = 200;
    autoRepeatInterval = 1000 / 100;
    videoDrivers = [ "modesetting" ];

    windowManager = {
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = with pkgs.haskellPackages; haskellPackages:
          [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit];
      };
    };

    xkbOptions = "caps:escape,grp:rctrl_rshift_toggle";

    config = '' '' ;

    synaptics = {
      enable = true;
      tapButtons = false;
      palmDetect = true;
      twoFingerScroll = true;
      maxSpeed = "5";
      minSpeed = "0.5";
      accelFactor = "0.2";
      palmMinWidth = 5;
      palmMinZ = 30;
      additionalOptions = ''
        Option "AreaBottomEdge" "0"
        Option "AreaLeftEdge" "300"
        Option "AreaRightEdge" "900"
        Option "AreaTopEdge" "400"
      '';
    };
  };

  i18n = {
    consoleFont = "lat9w-10";
    consoleUseXkbConfig = true;
  };
}
