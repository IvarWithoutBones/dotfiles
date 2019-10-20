#!vim:ft=config
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
  
  # Networking options.
  networking = {
	hostName = "nixos";
	networkmanager.enable = true;
  };

  # Enable automatic updates.
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";
  system.autoUpgrade.enable = true;

  # Select internationalisation properties.
  i18n = {
  	consoleFont = "Lat2-Terminus16";
  	consoleKeyMap = "us";
  	defaultLocale = "en_US.UTF-8";
   };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # System packages.
  environment.systemPackages = with pkgs; [
  	wget 
  	vim
 	cudatoolkit
  	(steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ]; nativeOnly = true; }).run
  ];

  # Always update the linux kernel to the latest version.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  
  # Enable 32bit support for OpenGL and Pulseaudio, this is required by some Steam games.
  hardware = {
	opengl.enable = true;
	opengl.extraPackages = with pkgs; [
		vaapiIntel
		vaapiVdpau
		libvdpau-va-gl
	];
  	opengl.driSupport32Bit = true;
	pulseaudio.enable = true;
  	pulseaudio.support32Bit = true;
  };

  # Configure the Xserver.
  services.xserver = {
	enable = true;
  	layout = "us";
  	xkbOptions = "eurosign:e";
	videoDrivers = [ "nvidiaBeta" ];
	displayManager.slim.enable = true;
	windowManager.i3.package = pkgs.i3-gaps;
	windowManager.i3.enable = true;
  };

  # Enable sound.
  sound.enable = true;

  # Define user accounts.
  users.users.ivar = {
  	isNormalUser = true;
  	extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ and network managing permissions for the user.
	shell = pkgs.zsh;
  };

  system.stateVersion = "19.03"; # Do not change unless told to. 
}
