{ config, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # links paths from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" "/share/zsh" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    extraModulePackages = with config.boot.kernelPackages; [ rtl8821ce ];
    kernelParams = [ "acpi_backlight=vendor" ];
  };

  networking = {
    hostName = "nixos-laptop";
    networkmanager.enable = true;
  };

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  time.timeZone = "Europe/Amsterdam";

  services = {
    blueman.enable = true;
    tlp.enable = true;
    fstrim.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      videoDrivers = [ "amdgpu" ];
      libinput = {
        enable = true;
        tapping = false;
        naturalScrolling = true;
        accelProfile = "flat";
      };
      displayManager.lightdm.enable = true;
      desktopManager.session = [ {
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} $HOME/.hm-xsession &
          waitPID=$!
        '';
      } ];
    };
  };

  sound.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    cpu.amd.updateMicrocode = true;
    opengl.enable = true;
    pulseaudio.enable = true;
    bluetooth.enable = true;
  };

  users.users.ivar = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  nix = {
    allowedUsers = [ "@wheel" ]; # Allow users in the "wheel" group to control the nix deamon
    autoOptimiseStore = true;
  };

  system.stateVersion = "20.09";
}
