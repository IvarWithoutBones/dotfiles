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
	wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  };

  # Use the unstable channel.
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-unstable/";

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
  	(steam.override { extraPkgs = pkgs: [ mono gtk3 gtk3-x11 libgdiplus zlib ]; nativeOnly = true; }).run
  ];

  # Always update the linux kernel to the latest version.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  
  # Enable 32bit support for OpenGL and Pulseaudio, this is required by some Steam games.
  hardware = {
  	opengl.driSupport32Bit = true;
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
  hardware.pulseaudio.enable = true;

  # Enable the zsh shell.
  programs.zsh.enable = true;

  # Define user accounts.
  users.users.ivar = {
  	isNormalUser = true;
  	extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
	shell = pkgs.zsh;
  };

  system.stateVersion = "19.03"; # Do not change unless told to. 
}
