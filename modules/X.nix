{ config, pkgs, ...}: {
  hardware.nvidia = {
    modesetting.enable = true;
  };

  services = {
    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      autorun = true;
      layout = "us,hr";
      autoRepeatDelay = 185;
      autoRepeatInterval = 1000 / 100;
      exportConfiguration = true;
      videoDrivers = [ "nvidia" ];

      xkbOptions = "caps:escape,grp:rctrl_rshift_toggle,ctrl:ralt_rctrl,terminate:ctrl_alt_bksp";

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = with pkgs.haskellPackages; haskellPackages:
            [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit xmonad-wallpaper ];
        };
      };
    };

    compton = {
      enable = true;
      vSync = true;
    };
  };

}
