{ config
, pkgs
, agenix
, system
, username
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

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;

    gc = {
      automatic = true;
      dates = "weekly";
    };

    settings = rec {
      auto-optimise-store = true;
      warn-dirty = false;

      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" username ];
      allowed-users = trusted-users;

      substituters = [
        "https://ivar.cachix.org"
        "https://ivar-personal.cachix.org"
      ];

      trusted-public-keys = [
        "ivar.cachix.org-1:oPUMlRJ2cwtWP3mdNUBe1esfL3+kw5aSWnkseeOn92o="
        "ivar-personal.cachix.org-1:xcf/K8QYcw2XR7Qz8QXNVVWxufSb6Lw5+rkh+CN4cTM="
      ];
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

    # Kernel 5.18 is broken with nvidia drivers
    kernelPackages = pkgs.linuxPackages_5_17;
    kernelParams = [
      "quiet"
      "boot.shell_on_fail"
    ];

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
