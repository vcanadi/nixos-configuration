{config, pkgs, ...}:
{  
		services.xserver.synaptics = { 
        enable=true;   
		    palmDetect=true;   
		    twoFingerScroll=true; 
		    maxSpeed="5";
		    minSpeed="0.5";
		    accelFactor="0.03";
		    palmMinWidth=5;		
		    palmMinZ=30;

        additionalOptions = ''
          Option "LeftEdge" "120"
          Option "TopEdge" "120"
          Option "RightEdge" "120"
          Option "BottomEdge" "120"
        '';
      };
}
