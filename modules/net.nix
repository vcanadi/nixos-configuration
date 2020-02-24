{ config, pkgs, ...}: {
  networking = {
    networkmanager = {
      enable=true;
      extraConfig = ''
        [main]
        rc-manager=resolvconf
      '';
    };
   # wicd.enable = true;
    # dhcpcd.enable = false;
    # wireless.enable = false;
    enableIPv6 = false;

  };
}
