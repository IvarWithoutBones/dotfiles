{ config
, pkgs
, ...
}:

{
  hardware = {
    nvidia = {
      # Temporarily using beta to work around the following issue: https://github.com/NixOS/nixpkgs/issues/357643
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = false; # Getting "probe failed with driver nvidia" errors upon startup
    };

    # Required for some legacy applications
    graphics.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
    # GPU support in containers such as Docker. TODO: Re-enable once its not broken anymore
    # nvidia-container-toolkit.enable = true;
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
