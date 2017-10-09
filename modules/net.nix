{config, pkgs, ...}:
{
 
	#networking.hostName = "vnix"; # Define your hostname.
	#networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  #networking.useDHCP = true;
  #  networking.wicd.enable=true;
  	networking.networkmanager.enable=true;
  # 	networking.firewall.enable=false;
	#	networking.connman.enable=true;
  networking.extraHosts=''
    127.0.0.1 l1 
    127.0.0.2 l2 
    127.0.0.3 l3 
    127.0.0.4 l4 
    127.0.0.5 l5 
    127.0.0.6 l6 
    127.0.0.7 l7 
    127.0.0.8 l8 
    127.0.0.9 l9 
    127.0.0.10 l10 
  '';
}
