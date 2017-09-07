
{config, pkgs, ...}:
{  
	# Select internationalisation properties.
		
		i18n = {
			consoleFont = "Lat2-Terminus16";
			consoleKeyMap = "us";
			defaultLocale = "en_US.UTF8";
		};

	# Set your time zone.
		
		time.timeZone = "Europe/Zagreb";
		
} 