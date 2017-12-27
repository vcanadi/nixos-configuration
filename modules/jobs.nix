{config, pkgs, ...}:
let
  utils = import ./../utils.nix config;
in
{
  systemd.services.postgres-custom-setup = {
    description = "Create postgres users and databases.";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = false;
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [sudo postgresql];
    script = ''
      sudo -u postgres psql < ${utils.createUserIfNotExistDOTsql "graphite" "graphite"}
      ${utils.createDbIfNotExistCmd "graphite" "graphite"}
    '';
  };

}
