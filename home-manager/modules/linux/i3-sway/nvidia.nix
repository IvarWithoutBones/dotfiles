{ ... }:

# Sets extra options specific to nvidia GPUs.

{
  wayland.windowManager.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraSessionCommands = ''
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export GBM_BACKEND=nvidia-drm
      export WLR_NO_HARDWARE_CURSORS=1
    '';
  };
}
