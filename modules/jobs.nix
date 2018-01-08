{config, pkgs, ...}:
let
  utils = import ./../utils.nix config;
in
{
  systemd.services = {

    postgres-custom-setup = {
      description = "Create postgres users and databases.";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = false;
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [sudo postgresql];
      script = ''
        ${utils.pgCreateUserIfNotExistCmd "graphite" "graphite"}
        ${utils.pgCreateDbIfNotExistCmd "graphite" "graphite"}
      '';
    };

    influxdb-custom-setup = {
      description = "Create influxdb users and databases.";
      serviceConfig.Type = "oneshot";
      serviceConfig.RemainAfterExit = false;
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [sudo influxdb];
      after = [ "influxdb" ];
      script = ''
        ${utils.influxCreateUserIfNotExistCmd "influxdb" "influxdb"}
        ${utils.influxCreateDbIfNotExistCmd "metrics"}
      '';
    };

  };

}
