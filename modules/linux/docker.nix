{
  config,
  lib,
  ...
}:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Use socket activation
  };

  # Add the "docker" group to every normal (i.e. interactive) user.
  users.extraGroups."docker".members = lib.attrNames (
    lib.filterAttrs (_username: config: config.isNormalUser) config.users.extraUsers
  );
}
