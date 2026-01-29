{ ... }:

{
  services.audiobookshelf = {
    enable = true;
    openFirewall = true;
    port = 8038;
    host = "0.0.0.0";
  };
}
