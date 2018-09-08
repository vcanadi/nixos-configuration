{ config, pkgs, ...}: {
  services.xserver = {
    enable = true;
    autorun = true;
    layout = "us,hr";
    autoRepeatDelay = 200;
    autoRepeatInterval = 1000 / 100;
    videoDrivers = [ "intel" ];

    # desktopManager.xterm.enable = true;
    displayManager = {
      lightdm = {
        enable = true;
      };
      xserverArgs = [ "-logfile" "/var/log/X.log" ];
    };

    windowManager = {
      # i3.enable=true;
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = with pkgs.haskellPackages; haskellPackages:
          [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit];
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
