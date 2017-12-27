{config, pkgs, ...}:
let
  baseDir = /root;
  createUserIfNotExistDOTsql = user: pass: builtins.toFile "" ''
    DO
    $body$
    BEGIN
       IF NOT EXISTS (
          SELECT                       -- SELECT list can stay empty for this
          FROM   pg_catalog.pg_user
          WHERE  usename = '${user}') THEN

          CREATE ROLE ${user} LOGIN PASSWORD '${pass}';
       END IF;
    END
    $body$;
  '';

  createDbIfNotExistCmd = db: owner: ''
    psql -u postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${db}'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE ${db} WITH OWNER ${owner}"
  '';
in
{
  systemd.services.postgres-custom-setup = {
    description = "Create postgres users and databases.";
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = false;
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [sudo postgresql];
    script = ''
      sudo -u postgres psql < ${createUserIfNotExistDOTsql "graphite" "graphite"}
      ${createDbIfNotExistCmd "graphite" "graphite"}
    '';
  };

}
