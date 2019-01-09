{ config, pkgs, ...}: {
  hardware.nvidia = {
    modesetting.enable = true;

    optimus_prime = {
      enable = true;
      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  services = {
    xserver = {
      enable = true;
      autorun = true;
      layout = "us,hr";
      autoRepeatDelay = 200;
      autoRepeatInterval = 1000 / 100;
      videoDrivers = [ "nvidia" ];

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = with pkgs.haskellPackages; haskellPackages:
            [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit];
        };
      };

      xkbOptions = "caps:escape,grp:rctrl_rshift_toggle,ctrl:ralt_rctrl,terminate:ctrl_alt_bksp";

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

    compton = {
      enable = true;
      inactiveOpacity = "0.7";
      fade = true;
      extraOptions = ''
        inactive-opacity-override = true;
      '';
    };
  };

  i18n = {
    consoleFont = "lat9w-10";
    consoleUseXkbConfig = true;
  };
}
