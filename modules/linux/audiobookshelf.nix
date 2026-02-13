{ config, lib, ... }:

{
  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 8038;
    host = "0.0.0.0";
  };

  users.users.${config.services.audiobookshelf.user} =
    lib.optionalAttrs config.services.transmission.enable
      {
        extraGroups = [ config.services.transmission.group ];
      };
}
