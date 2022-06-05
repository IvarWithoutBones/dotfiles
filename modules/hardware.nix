{ config
, pkgs
, lib
, cpu
, gpu
, sound
, touchpad
, bluetooth
, username
, ...
}:

{
  services = {
    blueman.enable = if bluetooth then true else false;

    xserver = {
      videoDrivers = [
        (
          if (gpu == "nvidia") then "nvidia"
          else if (gpu == "amd") then "amdgpu"
          else ""
        )
      ];

      # Fixes screentearing
      screenSection = lib.optionalString (gpu == "nvidia") ''
        Option "metamodes" "nvidia-auto-select +0+0 { ForceCompositionPipeline = On }"
      '';

      libinput = lib.optionalAttrs touchpad {
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
  boot.loader.systemd-boot.consoleMode = if (gpu == "nvidia") then "max" else "keep";

  hardware = {
    nvidia.package = lib.optionals (gpu == "nvidia") config.boot.kernelPackages.nvidiaPackages.beta;
    cpu.${cpu}.updateMicrocode = true;
  };

  sound.enable = sound;
  users.users.${username}.extraGroups = lib.optionals sound [ "audio" ];

  hardware = {
    enableRedistributableFirmware = true;

    opengl = {
      enable = true;
      driSupport32Bit = true;
      extraPackages32 = lib.optionals (gpu == "nvidia") [ pkgs.pkgsi686Linux.libva ];
    };

    pulseaudio = {
      enable = sound;
      support32Bit = sound;
    } // lib.optionalAttrs bluetooth {
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

    bluetooth = lib.optionalAttrs bluetooth {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };
  };
}
