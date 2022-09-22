{ config
, username
, hardware
, ...
}:

{
  virtualisation.docker = {
    enable = true;
    enableNvidia = if (hardware.gpu or "" == "nvidia") then true else false;
    enableOnBoot = false; # Use socket activation
  };

  users.users.${username}.extraGroups = [ "docker" ];
}
