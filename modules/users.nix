{config, pkgs, ...}:
{
    users = {
#        mutableUsers = false;
        extraUsers = { 
            bunkar = { 
                createHome=true;
                home = "/home/bunkar";
                name="bunkar";
                useDefaultShell = true;
                extraGroups = [ "wheel" "networkmanager" "tty" ];
                initialPassword="initpass";
            };

            dundofar = { 
                createHome=true;
                home = "/home/dundofar";
                name="dundofar";
                #shell = "/run/current-system/sw/bin/fish";
                useDefaultShell = true;
                extraGroups = [ "wheel" "networkmanager" ];
                openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... dundofar@vnix" ];
                initialPassword="initpass";
            };
        };
    };
}
