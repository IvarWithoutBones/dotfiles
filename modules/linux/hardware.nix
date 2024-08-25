{ lib
, hardware
, ...
}:

{
  services = {
    blueman.enable = if (hardware.bluetooth or false) then true else false;

    xserver = {
      # See /modules/linux/nvidia.nix for the nvidia driver
      videoDrivers = lib.optionals (hardware.gpu == "amd") [ "amdgpu" ];

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

  hardware = {
    enableRedistributableFirmware = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };

    bluetooth = lib.optionalAttrs (hardware.bluetooth or false) {
      enable = true;
      settings.General.Enable = "Source,Sink,Media,Socket";
    };

    cpu = lib.optionalAttrs (hardware.cpu or null != null) {
      ${hardware.cpu}.updateMicrocode = true;
    };
  };
}
