{ lib, pkgs, ... }:

{
  programs.mpv = {
    enable = true;

    config = {
      profile = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
      save-position-on-quit = true;
    }
    // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      # Use the GPU for video decoding and rendering on Linux, preferably with Vulkan.
      gpu-context = "waylandvk,wayland,x11vk,x11egl,displayvk,drm";
      gpu-api = "vulkan,opengl";
      vo = "gpu-next,"; # Trailing comma makes mpv try options not in the list as a fallback.
      hwdec = "nvdec,vaapi,drm,vulkan,auto,auto-copy";
    };
  };
}
