{ lib
, pkgs
, ...
}:

{
  environment = {
    # links paths from derivations to /run/current-system/sw
    pathsToLink = [ "/libexec" "/share/zsh" ];

    systemPackages = with pkgs; [
      neovim
      git
    ];
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # See https://github.com/NixOS/nixpkgs/issues/23926
      };

      efi.canTouchEfiVariables = false;
    };

    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  time.timeZone = "Europe/Amsterdam";
  programs.zsh.enable = true;

  services = {
    fstrim.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];
  };
}
