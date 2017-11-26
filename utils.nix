let b = builtins; in
{
  userWithHomes = config: b.filter (u: u.createHome) (b.attrValues config.users.extraUsers); 
}
