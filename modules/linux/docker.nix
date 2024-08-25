{ username
, ...
}:

{
  virtualisation.docker = {
    enable = true;
    enableOnBoot = false; # Use socket activation
  };

  users.users.${username}.extraGroups = [ "docker" ];
}
