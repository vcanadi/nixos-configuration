{config, pkgs, ...}:
{
	#	environment.etc."asound.conf".pcm.louder {
	#		type plug
	#		slave.pcm "dmix"
	#		ttable.0.0 2.0
	#		ttable.1.1 2.0
	#	};

	#	environment.etc."asound.conf".pcm.!default "louder";
  
		hardware.pulseaudio = 
		{
		  enable = true;
		  #package = pkgs.pulseaudioFull;
		  # or use
		   package = pkgs.pulseaudioLight.override { jackaudioSupport = true; };
		};	
	
}