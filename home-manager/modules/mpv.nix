{ config
, pkgs
, ...
}:

{
  programs.mpv = {
    enable = true;

    config = {
      profile = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
      save-position-on-quit = true;
    };
  };
}
