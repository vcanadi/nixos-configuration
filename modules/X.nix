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
      # tty = 2;
      enable = true;
      enableCtrlAltBackspace = true;
      autorun = true;
      layout = "us,hr";
      autoRepeatDelay = 200;
      autoRepeatInterval = 1000 / 100;
      videoDrivers = [ "nvidia" ];
      # videoDrivers = [ "modesetting" ];

      xkbOptions = "caps:escape,grp:rctrl_rshift_toggle,ctrl:ralt_rctrl,terminate:ctrl_alt_bksp";

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = with pkgs.haskellPackages; haskellPackages:
            [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit xmonad-wallpaper];
        };
        # default = "none";
      };

      # desktopManager.gnome3.enable = true;
      displayManager = {
        gdm.wayland = true;
        defaultSession = "none+xmonad";
      };

      synaptics = {
        enable = true;
        tapButtons = false;
        palmDetect = true;
        twoFingerScroll = true;
        maxSpeed = "7";
        minSpeed = "0.9";
        accelFactor = "0.3";
        palmMinWidth = 5;
        palmMinZ = 30;
        additionalOptions = ''
          Option "AreaBottomEdge" "0"
          Option "AreaLeftEdge" "300"
          Option "AreaRightEdge" "900"
          Option "AreaTopEdge" "400"
        '';
      };

      monitorSection = ''
        Option "DPMS" "true"
      '';

      serverLayoutSection = ''
        Option "StandbyTime" "120"
      '';
    };

    compton = {
      enable = true;
      # vSync = true;
    };
  };

}
