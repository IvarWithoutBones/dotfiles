{ config, pkgs, ... }:
{
  # Include the results of the hardware scan. You can generate this with nixos-generate-config.
  imports = [
    ./hardware-configuration.nix
  ];

  # links /libexec from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Networking options.
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Enable automatic updates.
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";
  system.autoUpgrade.enable = true;

  # Internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    consoleKeyMap = "us";
    consoleFont = "Lat2-Terminus16";
  };

  # Set the time zone to Amsterdam.
  time.timeZone = "Europe/Amsterdam";

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # System packages.
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
  ];

  # Always update the Linux packages to their latest versions.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Configure services
  services = {
    openssh.enable = true; # Enable the OpenSSH daemon.
    blueman.enable = true; # Enable the blueman applet
    xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e";
      videoDrivers = [ "nvidiaBeta" ];
      displayManager.lightdm.enable = true;
      windowManager.i3 = {
      	package = pkgs.i3-gaps;
      	enable = true;
	extraPackages = with pkgs; [
	  i3blocks
	  i3status
	  i3lock
	  dmenu
	];
      };
      desktopManager.session = [ {
 	manage = "desktop";
	name = "i3";
      	start = ''
          ${pkgs.i3}/bin/i3
      	'';
      } ];
      desktopManager.default = "i3";
    };
  };

  programs.dconf.enable = true;

  # Enable sound.
  sound.enable = true;

  # Configure hardware options. Note that 32-bit support is enabled as some Steam games require this.
  hardware = {
    opengl.enable = true;
    opengl.driSupport32Bit = true;
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true;
    bluetooth.enable = true;
  };

  # Define user accounts.
  users.users = {
    ivar = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ and network managing permissions for the user.
      shell = pkgs.zsh;
    };
  };

  nix.allowedUsers = [ "@wheel" ];

  system.stateVersion = "20.03"; # Do not change this unless told to. 
}
