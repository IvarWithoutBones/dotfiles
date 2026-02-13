{ config, lib, ... }:

{
  services = {
    # Media player
    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Series manager for jellyfin/jellyseerr
    sonarr = {
      enable = true;
      openFirewall = true;
    };

    # Movie manager for jellyfin/jellyseerr
    radarr = {
      enable = true;
      openFirewall = true;
    };

    # Subtitle manager for sonarr/radarr
    bazarr = {
      enable = true;
      openFirewall = true;
    };

    # Request manager for jellyfin
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    # Provides the indexers for sonarr and radarr
    prowlarr = {
      enable = true;
      openFirewall = true;
    };

    # Bypasses cloudfare for indexers
    flaresolverr = {
      enable = true;
      openFirewall = true;
    };
  };

  users.users = {
    ${config.services.jellyfin.user}.extraGroups = [
      config.services.sonarr.group
      config.services.radarr.group
      config.services.bazarr.group
    ]
    ++ lib.optionals config.services.transmission.enable [
      config.services.transmission.group
    ];

    ${config.services.sonarr.user}.extraGroups = [
      config.services.jellyfin.group
      config.services.bazarr.group
    ]
    ++ lib.optionals config.services.transmission.enable [
      config.services.transmission.group
    ];

    ${config.services.radarr.user}.extraGroups = [
      config.services.jellyfin.group
      config.services.bazarr.group
    ]
    ++ lib.optionals config.services.transmission.enable [
      config.services.transmission.group
    ];

    ${config.services.bazarr.user}.extraGroups = [
      config.services.jellyfin.group
      config.services.sonarr.group
      config.services.radarr.group
    ]
    ++ lib.optionals config.services.transmission.enable [
      config.services.transmission.group
    ];
  };
}
