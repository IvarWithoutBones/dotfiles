{ config
, pkgs
, cpu
, gpu
, touchpad
, ...
}:

let
  inherit (pkgs) lib;
in
{
  services.xserver = {
    videoDrivers = [(
      if (gpu == "nvidia") then "nvidia"
      else if (gpu == "amd") then "amdgpu"
      else null
    )];

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

  hardware = {
    nvidia.package = lib.optionals (gpu == "nvidia") config.boot.kernelPackages.nvidiaPackages.beta;
    cpu.${cpu}.updateMicrocode = true;
  };

  # Fixes tty resolution
  boot.loader.systemd-boot.consoleMode = if (gpu == "nvidia") then "max" else "keep";
}
