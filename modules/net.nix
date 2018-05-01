{ config, pkgs, ...}: {
  networking = {
    networkmanager.enable=true;
    enableIPv6 = false;
  };
}
