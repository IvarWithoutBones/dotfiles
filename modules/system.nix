{ config
, lib
, pkgs
, agenix
, system
, username
, hardware
, ...
}:

{
  imports = [ agenix.nixosModule ];

  age.secrets = {
    cachix-config = {
      name = "cachix-config";
      file = ../secrets/cachix-config.age;
      owner = username;
    };
  };

  environment = {
    # links paths from derivations to /run/current-system/sw
    pathsToLink = [ "/libexec" "/share/zsh" ];

    systemPackages = with pkgs; [
      agenix.defaultPackage.${system}
      neovim
      git

      (pkgs.runCommand "cachix-configured"
        {
          nativeBuildInputs = [ makeWrapper ];
        } ''
        mkdir -p $out/bin

        makeWrapper ${pkgs.cachix}/bin/cachix $out/bin/cachix \
          --add-flags "--config ${config.age.secrets.cachix-config.path}"
      '')
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

    kernelPackages = pkgs.linuxPackages_5_18; # Nvidia drivers fail to build on 5.19
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
