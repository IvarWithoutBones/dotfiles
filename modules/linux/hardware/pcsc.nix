{ pkgs, ... }:

# Support for PC/SC smart-card readers/writers.

{
  services.pcscd = {
    enable = true;
    ignoreReaderNames = [ "YubiKey" ];
    plugins = [
      pkgs.ccid # Generic CCID
      pkgs.acsccid # ACS CCID
    ];
  };

  environment.systemPackages = [
    pkgs.pcsc-tools
  ];
}
