{config, pkgs, ...}:
{
	
/*
    systemd.services.nvidia-control-devices = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi";
     };
	
	 	services.xserver.videoDrivers = [ 
        "nvidia" 
        "vesa"
        "nouveau"
	  ];
*/
		hardware.opengl.driSupport32Bit = true;
		hardware.opengl.enable=true;

}
