{ config, pkgs, ...}: {
  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull; # pkgs.pulseaudioLight.override { jackaudioSupport = true; };
  };
  # services.jack = {
  #     jackd.enable = true;
  #     # support ALSA only programs via ALSA JACK PCM plugin
  #     alsa.enable = false;
  #     # support ALSA only programs via loopback device (supports programs like Steam)
  #     loopback = {
  #       enable = true;
  #       # buffering parameters for dmix device to work with ALSA only semi-professional sound programs
  #       dmixConfig = ''
  #         period_size 2048
  #       '';
  #     };
  #   };
}
