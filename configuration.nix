{ config, pkgs, ... }:

{
  # TODO: do this cleanly
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # links paths from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" "/share/zsh" ];

  nixpkgs.config.allowUnfree = true;

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  programs = {
    steam.enable = true;
    zsh.enable = true;
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # See https://github.com/NixOS/nixpkgs/issues/23926
      };
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_5_15; # This is because of nvidia driver. TODO: set this in a more appropriate place
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  networking = {
    networkmanager.enable = true;
  };

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  time.timeZone = "Europe/Amsterdam";

  networking.firewall.enable = true;

  services = {
    xserver = {
      enable = true;
      libinput = {
        enable = true;
        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelProfile = "flat";
        };
      };
      displayManager.lightdm.enable = !(config.services.greetd.enable);
      displayManager.startx.enable = config.services.greetd.enable; # Required for greetd, it doesn't start the xserver
      desktopManager.session = [ {
        name = "home-manager";
        start = ''
          ${pkgs.runtimeShell} ${pkgs.lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-xsession &
          waitPID=$!
        '';
      } ];
    };

    greetd = {
      enable = true;
      vt = config.services.xserver.tty;
      settings = {
        default_session.command = "${pkgs.greetd.tuigreet}/bin/tuigreet --sessions \"${config.services.xserver.displayManager.sessionData.desktops}/share/xsessions\" --time";
      };
    };

    zerotierone = {
      enable = false;
      port = 7777;
    };

    openssh.enable = true;
    blueman.enable = true;
    fstrim.enable = true;
  };

  sound.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = with pkgs.pkgsi686Linux; [ libva ];
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ]; # For bluetooth headphones
      extraConfig = "
        load-module module-switch-on-connect
      ";
    };
    bluetooth = {
      enable = true;
      settings = { General.Enable = "Source,Sink,Media,Socket"; };
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

  system.stateVersion = "22.05";
}
