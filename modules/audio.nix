{ config, pkgs, ...}: {
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioLight.override { jackaudioSupport = true; };
  };
}
