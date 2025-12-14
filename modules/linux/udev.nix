{ pkgs, ... }:

{
  # Ensure the `plugdev` group exists, which the udev rules give permissions to.
  users.groups.plugdev = { };

  services.udev = {
    packages = with pkgs; [
      # Keyboard firmware flashing/configuring
      qmk-udev-rules
      keychron-udev-rules

      # Embedded debug probes
      openocd
      probe-rs-udev-rules # From my overlay
    ];

    extraRules = ''
      # Keychron Q2 keyboard
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0111", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"

      # SayoDevice macropad
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="8089", ATTRS{idProduct}=="0007", MODE="0660", GROUP="plugdev", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
