{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = lib.mkIf (!pkgs.stdenv.hostPlatform.isAarch64) [ "aarch64-linux" ];

    loader = {
      efi.canTouchEfiVariables = false;

      limine = {
        enable = true;
        maxGenerations = 10; # See https://github.com/NixOS/nixpkgs/issues/23926
      };
    };
  };

  environment.systemPackages = lib.optionals config.boot.loader.limine.secureBoot.enable [
    config.boot.loader.limine.secureBoot.sbctl
  ];
}
