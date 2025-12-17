{ ... }:

# Sets extra options specific to nvidia GPUs.

{
  wayland.windowManager.sway = {
    extraOptions = [ "--unsupported-gpu" ];
    extraSessionCommands = ''
      # Use the NVidia GLX/GBM backends
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export GBM_BACKEND=nvidia-drm

      # Forcibly use the Vulkan driver for FNA3D applications,
      # prevents some applications defaulting to Mesa's software renderer.
      export FNA3D_FORCE_DRIVER=vulkan
    '';
  };
}
