{ config, pkgs, ...}:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  environment.systemPackages = [ nvidia-offload ];
  hardware.nvidia = {
    modesetting.enable = true;
    prime = {
      # offload.enable = true;
      sync.enable = true;
      amdgpuBusId = "PCI:5:0:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services = {

    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
      };
    };

    xserver = {
      enable = true;
      enableCtrlAltBackspace = true;
      autorun = true;
      dpi = 110;
      autoRepeatDelay = 220;
      autoRepeatInterval = 1000 / 90;
      exportConfiguration = true;
      videoDrivers = [ "nvidia" ];

      xkb = {
        options = "caps:escape,grp:rctrl_rshift_toggle,ctrl:swap_lwin_lctrl,terminate:ctrl_alt_bksp";
        layout = "us,hr";
      };
      displayManager.sessionCommands = let
        layout = pkgs.writeText "xkb-layout" ''
            keycode 108 = Shift_L

            remove Control = Control_R
            keycode 105 = Control_R NoSymbol Control_R
            keycode 135 = Control_R NoSymbol Control_R
            add Control = Control_R

          '';
      in "${pkgs.xorg.xmodmap}/bin/xmodmap ${layout}";

      windowManager = {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = with pkgs.haskellPackages; haskellPackages:
            [ xmonad-contrib xmonad-extras xmonad xmobar conduit http-conduit ];
        };
      };

      monitorSection = ''
        Option "DPMS" "true"
      '';

      serverFlagsSection = ''
        Option "BlankTime" "0"
      '';

      serverLayoutSection = ''
        Option "StandbyTime" "120"
      '';

    };

    picom = {
      enable = true;
      vSync = true;
      fade = true;
      fadeDelta = 3;
      fadeSteps = [ 0.01 0.02 ];
    };
  };
}
