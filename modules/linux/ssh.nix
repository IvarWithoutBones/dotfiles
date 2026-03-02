{ config, ... }:

{
  programs.mosh.enable = true;

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;

    hostKeys = [
      {
        path = config.sops.secrets."ssh/host/ed25519".path;
        type = "ed25519";
      }
    ];
  };

  programs.ssh.extraConfig = ''
    Include ${config.sops.secrets."ssh/hosts".path}
  '';

  sops.secrets."ssh/host/ed25519".sopsFile = ../../secrets/${config.networking.hostName}/host.yaml;
  sops.secrets."ssh/hosts".mode = "0444";
}
