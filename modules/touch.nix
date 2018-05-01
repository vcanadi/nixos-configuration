{ config, pkgs, ...}: {
  services.xserver.synaptics = {
    enable = true;
    palmDetect = true;
    twoFingerScroll = true;
    maxSpeed = "5";
    minSpeed = "0.5";
    accelFactor = "0.03";
    palmMinWidth = 5;
    palmMinZ = 30;
    additionalOptions = ''
      Option "AreaBottomEdge" "0"
      Option "AreaLeftEdge" "2500"
      Option "AreaRightEdge" "3500"
      Option "AreaTopEdge" "3000"
    '';
  };
}
