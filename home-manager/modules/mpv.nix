{ pkgs, ... }:

{
  programs.mpv = {
    enable = true;
    package = pkgs.mpv.override { youtubeSupport = false; }; # TODO: Re-enable once fixed in nixpkgs.

    config = {
      profile = "gpu-hq";
      ytdl-format = "bestvideo+bestaudio";
      save-position-on-quit = true;
    };
  };
}
