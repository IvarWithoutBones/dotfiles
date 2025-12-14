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

      # 8BitDo Ultimate 2 Dongle/2.4Ghz receiver (DInput)
      KERNEL=="hidraw*", ATTRS{idVendor}=="2dc8", ATTRS{idProduct}=="6012", MODE="0660", TAG+="uaccess"

      # 8BitDo Ultimate 2 Bluetooth (DInput)
      KERNEL=="hidraw*", KERNELS=="*2DC8:6012*", MODE="0660", TAG+="uaccess"
    '';
  };
}
