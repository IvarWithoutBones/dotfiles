{ config, pkgs, ... }:
let
  # Required till https://github.com/NixOS/nixpkgs/pull/88809 is merged, version currently in nixpkgs does not compile with more recent kernels.
  wifi = (config.boot.kernelPackages.rtl8821ce.overrideAttrs (attrs: {
    version = "5.5.2_34066.20200325";
    src = pkgs.fetchFromGitHub {
      owner = "tomaspinho";
      repo = "rtl8821ce";
      rev = "69765eb288a8dfad3b055b906760b53e02ab1dea";
      sha256 = "17jiw25k74kv5lnvgycvj2g1n06hbrpjz6p4znk4a62g136rhn4s";
    };
  }));
in
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
    extraModulePackages = [ wifi ];
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
    tlp.enable = true;
    # Without this it uses like 80% of a thread, and i only got 2. No idea what it does tbh
    journald.extraConfig = ''
      GRUB_CMDLINE_LINUX_DEFAULT="quiet splash pci=nomsi,pcie_aspm=off"
    '';
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
    opengl.enable = true;
    pulseaudio.enable = true;
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
