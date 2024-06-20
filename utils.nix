config :
let b = builtins; in
rec {
  userWithHomes = b.filter (u: u.createHome) (b.attrValues config.users.extraUsers);
  # mkActivationScriptsForUsers = activationScriptCreators: b.listToAttrs (b.map (user: {
  #    name = "${user.name}-script";
  #    value = b.concatStringsSep "\n" (b.map (asc: asc user ) activationScriptCreators) ;
  #   }) userWithHomes);
}
