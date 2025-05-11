{ config
, pkgs
, ...
}:

{
  hardware = {
    nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      open = false; # Getting "probe failed with driver nvidia" errors upon startup
      modesetting.enable = true; # Allow the kernel driver to configure the display
    };

    # Required for some legacy applications
    graphics.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];

    # GPU support in containers such as Docker
    nvidia-container-toolkit.enable = true;
  };

  boot = {
    # Use the full resolution in systemd-boot
    loader.systemd-boot.consoleMode = "max";

    kernelParams = [
      # Required for VSync to work without lagging the system, see the Arch Wiki: https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks#Setting_static_2D/3D_clocks
      "nvidia.NVreg_RegistryDwords=\"PerfLevelSrc=0x2222\""
    ];
  };

  services.xserver = {
    videoDrivers = [ "nvidia" ];

    # Enable over/underclocking on nvidia GPUs, see the Arch Wiki: https://wiki.archlinux.org/title/NVIDIA/Tips_and_tricks#Enabling_overclocking
    # The value 24 is a bitset, here is how we configure each bit:
    #  0..=2 = 0: Irrelevant for us.
    #      3 = 1: Enables overclocking.
    #      4 = 1: Enables overvoltage.
    deviceSection = ''
      Option "Coolbits" "24"
    '';
  };

  systemd.services = {
    nvidia-gpu-power-limit = {
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = pkgs.writeShellScript "nvidia-gpu-power-limit" ''
          ${config.hardware.nvidia.package.bin}/bin/nvidia-smi --power-limit 200 # In watts
        '';
      };
    };
  };
}
