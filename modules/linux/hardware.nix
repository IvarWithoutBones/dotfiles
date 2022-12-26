{ config
, pkgs
, lib
, hardware
, username
, ...
}:

{
  services = {
    blueman.enable = if (hardware.bluetooth or false) then true else false;

    xserver = {
      videoDrivers = [
        (
          if (hardware.gpu == "nvidia") then "nvidia"
          else if (hardware.gpu == "amd") then "amdgpu"
          else ""
        )
      ];

      # Fixes screentearing
      screenSection = lib.optionalString (hardware.gpu == "nvidia") ''
        Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
      '';

      libinput = lib.optionalAttrs (hardware.touchpad or false) {
        enable = true;

        touchpad = {
          tapping = false;
          naturalScrolling = true;
          accelProfile = "flat";
        };
      };
    };
  };

  # Fixes tty resolution
  boot.loader.systemd-boot.consoleMode = if (hardware.gpu == "nvidia") then "max" else "keep";

  sound.enable = hardware.sound or false;
  users.users.${username}.extraGroups = lib.optionals hardware.sound [ "audio" ];

  hardware = {
    nvidia.package = lib.optionals (hardware.gpu == "nvidia") config.boot.kernelPackages.nvidiaPackages.stable;
    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = lib.optionals (hardware.gpu == "nvidia") [ pkgs.pkgsi686Linux.libva ];
    };

    pulseaudio = {
      enable = hardware.sound;
      support32Bit = hardware.sound;
    } // lib.optionalAttrs (hardware.bluetooth or false) {
      # For bluetooth headphones
      package = pkgs.pulseaudioFull;
      extraConfig = "
        load-module module-switch-on-connect
      ";
    };

    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };

    bluetooth = lib.optionalAttrs (hardware.bluetooth or false) {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  } // lib.optionalAttrs (hardware.cpu or "" != "") {
    cpu.${hardware.cpu}.updateMicrocode = true;
  };
}
