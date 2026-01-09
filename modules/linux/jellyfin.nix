{ ... }:

{
  services = {
    # Media player, hosts a web interface
    jellyfin = {
      enable = true;
      openFirewall = true;
    };

    # Request manager for jellyfin, unifying series and movies
    jellyseerr = {
      enable = true;
      openFirewall = true;
    };

    # Series manager, interfaces with jellyseerr
    sonarr = {
      enable = true;
      openFirewall = true;
    };

    # Movie manager, interfaces with jellyseerr
    radarr = {
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
}
