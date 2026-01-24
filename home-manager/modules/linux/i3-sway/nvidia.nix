{ lib, config, ... }:

# Sets extra options specific to nvidia GPUs.

let
  beforeSessionStart = ''
    # Use the NVidia GLX/GBM backends
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export GBM_BACKEND=nvidia-drm

    # Forcibly use the Vulkan driver for FNA3D applications,
    # prevents some applications defaulting to Mesa's software renderer.
    export FNA3D_FORCE_DRIVER=vulkan

    # Fixes rendering issues in WebKit applications, like those using Tauri:
    # https://github.com/tauri-apps/tauri/issues/9394
    export WEBKIT_DISABLE_DMABUF_RENDERER=1
  '';
in
{
  wayland.windowManager.sway = lib.mkIf config.wayland.windowManager.sway.enable {
    extraOptions = [ "--unsupported-gpu" ];
    extraSessionCommands = beforeSessionStart;
  };

  xsession.profileExtra = lib.mkIf config.xsession.enable beforeSessionStart;
}
