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
    kernelParams = [ "acpi_backlight=vendor" ]; # Fixes backlight on laptop
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
    openssh.enable = true;
    blueman.enable = true;
    fstrim.enable = true;
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      videoDrivers = [ "amdgpu" ];
      libinput = {
        enable = true;
        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelProfile = "flat";
        };
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
    opengl = {
    	enable = true;
	    driSupport32Bit = true;
  	  extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio = { # For bluetooth headphones
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = "
        load-module module-switch-on-connect
      ";
    };
    bluetooth = {
      enable = true;
      settings = { General = { Enable = "Source,Sink,Media,Socket"; }; };
    };
  };

  users.users.ivv = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    shell = pkgs.zsh;
  };

  nix = {
    allowedUsers = [ "@wheel" "ivv" ];
    trustedUsers = [ "@wheel" "ivv" ];
    autoOptimiseStore = true;
  };

  system.stateVersion = "20.09";
}
