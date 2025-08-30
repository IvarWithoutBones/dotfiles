{ ... }:

{
  imports = [ ./common.nix ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for some legacy applications
  };
}
