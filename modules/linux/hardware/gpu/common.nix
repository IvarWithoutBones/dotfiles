{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Required for some legacy applications
    extraPackages = [ pkgs.libva ];
    extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
  };
}
