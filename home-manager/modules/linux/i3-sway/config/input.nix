{ config, lib, ... }:

# Input configuration for various devices. Note that we cannot configure this for i3 through home-manager,
# we do so from NixOS in `modules/linux/desktop/xserver.nix`.

{
  # Note that the identifiers come from `swaymsg -t get_inputs`.
  wayland.windowManager.sway.config.input = lib.mkIf config.wayland.windowManager.sway.enable {
    # Swap capslock <-> escape on all keyboards.
    "type:keyboard".xkb_options = "caps:swapescape";

    # Don't swap capslock <-> escape on keyboards which have their layout configured differently.
    "36125:41874:splitkb.com_Halcyon_Elora_rev2".xkb_options = "caps:capslock";
    "13364:273:Keychron_Q2_Keyboard".xkb_options = "caps:capslock";

    # Internal keyboard on Apple laptops.
    "1452:636:Apple_Inc._Apple_Internal_Keyboard_/_Trackpad".xkb_options = lib.concatStringsSep "," [
      "caps:swapescape" # Option above gets overwritten.
      "altwin:swap_lalt_lwin" # Swap left Option <-> left Command to mimic a regular layout.
    ];

    # Halycon Elora trackpad module.
    "36125:41874:splitkb.com_Halcyon_Elora_rev2_Mouse" = {
      accel_profile = "flat";
      pointer_accel = "0.7";
      scroll_factor = "2.0";
    };
  };
}
