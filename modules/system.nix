{ config
, lib
, pkgs
, system
, username
, hardware
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

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
    ] ++ lib.optional (hardware.gpu or "" == "nvidia")
      "nvidia-drm.modeset=1"; # Required for wayland support with propietary nvidia drivers

    binfmt.emulatedSystems = [ "aarch64-linux" ];
    supportedFilesystems = [ "ntfs" ];
  };

  time.timeZone = "Europe/Amsterdam";
  programs.zsh.enable = true;

  services = {
    fstrim.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];
  };

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "plugdev" ];
    shell = pkgs.zsh;
  };
}
