{ ... }:

{
  # Media player, hosts a web interface
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Request manager for jellyfin, unifying series and movies
  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # Series manager, interfaces with jellyseerr
  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  # Movie manager, interfaces with jellyseerr
  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  # Provides the indexers for sonarr and radarr
  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
