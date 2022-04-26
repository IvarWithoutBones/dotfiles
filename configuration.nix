{ config
, pkgs
, lib
, bluetooth
, ...
}:

{
  # TODO: do this cleanly
  imports = [ /etc/nixos/hardware-configuration.nix ];

  # links paths from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" "/share/zsh" ];

  nix = {
    package = pkgs.nixUnstable;
    settings = rec {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "@wheel" "ivv" ];
      allowed-users = trusted-users;
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 10; # See https://github.com/NixOS/nixpkgs/issues/23926
      };
      efi.canTouchEfiVariables = false;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = [ "aarch64-linux" ];
  };

  console = {
    keyMap = "us";
    font = "Lat2-Terminus16";
  };

  time.timeZone = "Europe/Amsterdam";

  programs = {
    steam.enable = true;
    zsh.enable = true;
    dconf.enable = true;
  };

  services = {
    openssh.enable = true;
    blueman.enable = if bluetooth then true else false;
    fstrim.enable = true;
    udev.packages = [ pkgs.qmk-udev-rules ];

    zerotierone = {
      enable = true;
      joinNetworks = [
         # Personal network
        "12ac4a1e719ff42c"
        # queens & co
        "8286ac0e47868413"
      ];
    };

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
          ${pkgs.runtimeShell} ${lib.optionalString config.services.xserver.displayManager.startx.enable "startx"} $HOME/.hm-xsession &
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
  };

  networking.networkmanager.enable = true;
  sound.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
    } // lib.optionalAttrs bluetooth { # For bluetooth headphones
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      extraConfig = "
        load-module module-switch-on-connect
      ";
    };
    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
    bluetooth = lib.optionalAttrs bluetooth {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  };

  users.users.ivv = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" ];
    shell = pkgs.zsh;
  };

  system.stateVersion = "22.05";
}
