{config, pkgs, ...}:
{  
	#	services.xserver.multitouch.enable=true; 
		services.xserver.synaptics.enable=true;   
		services.xserver.synaptics.palmDetect=true;   
		services.xserver.synaptics.twoFingerScroll=true; 
		services.xserver.synaptics.maxSpeed="5";
		services.xserver.synaptics.minSpeed="0.5";
		services.xserver.synaptics.accelFactor="0.03";
	#	services.xserver.synaptics.palmMinWidth=5;		
	#	services.xserver.synaptics.palmMinZ=30;
}