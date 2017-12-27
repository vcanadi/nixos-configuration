config :
let b = builtins; in
rec {
  userWithHomes = b.filter (u: u.createHome) (b.attrValues config.users.extraUsers);

  mkActivationScriptsForUsers = activationScriptCreators: b.listToAttrs (b.map (user: {
     name = "${user.name}-script";
     value = b.concatStringsSep "\n" (b.map (asc: asc user ) activationScriptCreators) ;
    }) userWithHomes);

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
    psql -U postgres -tc "SELECT 1 FROM pg_database WHERE datname = '${db}'" | grep -q 1 || psql -U postgres -c "CREATE DATABASE ${db} WITH OWNER ${owner}"
  '';

}
