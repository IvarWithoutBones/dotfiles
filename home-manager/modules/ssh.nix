{ config, ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ config.sops.secrets."ssh/hosts".path ];
  };

  sops.secrets."ssh/hosts" = { };
}
