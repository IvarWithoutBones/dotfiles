{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Networking options
  networking = {
	hostName = "nixos";
	wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # Use the unstable channel
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";

  # Select internationalisation properties.
  i18n = {
  	consoleFont = "Lat2-Terminus16";
  	consoleKeyMap = "us";
  	defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  environment.systemPackages = with pkgs; [
  	wget vim
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

 # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set up bumblebee
  hardware.bumblebee.enable = true;
  hardware.bumblebee.connectDisplay = true;
  
  services.xserver = {
	enable = true;
  	layout = "us";
  	xkbOptions = "eurosign:e";
	videoDrivers = [ "intel" "nvidiaBeta" ];
	displayManager.sddm.enable = true;
	windowManager.i3.package = pkgs.i3-gaps;
	windowManager.i3.enable = true;
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ivar = {
  	isNormalUser = true;
  	extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	shell = pkgs.zsh;
  };

  system.stateVersion = "19.03"; # Do not change unless told to. 
}
