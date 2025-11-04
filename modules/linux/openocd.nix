{ pkgs, ... }:

{
  # Ensure the `groupdev` group exists, required for the udev rules to function properly.
  users.groups.plugdev = { };
  services.udev.packages = [ pkgs.openocd ];
}
