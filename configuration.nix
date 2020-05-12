{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  # links /libexec from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  # Allow unfree packages. Required for the propietary Nvidia driver
  nixpkgs.config.allowUnfree = true;

  time.timeZone = "Europe/Amsterdam";

  services = {
    openssh.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      videoDrivers = [ "nvidiaBeta" ];
      digimend.enable = true;
      displayManager.lightdm.enable = true;
      windowManager.i3 = {
        package = pkgs.i3-gaps;
        enable = true;
        extraPackages = with pkgs; [
	  i3blocks
	  i3lock
          dmenu
	];
      };
    };
  };

  # Required for some GTK based app's settings to be saved
  programs.dconf.enable = true;

  sound.enable = true;

  # 32-bit support is enabled as some Steam games require this
  hardware = {
    opengl.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
  };

  users.users = {
    ivar = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
  };

  nix = {
    allowedUsers = [ "@wheel" ]; # Allow users in the "wheel" group to control the nix deamon
    autoOptimiseStore = true;
  };

  system.stateVersion = "20.09";
}
