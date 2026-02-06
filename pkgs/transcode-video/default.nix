{ createScript
, jellyfin-ffmpeg
, coreutils
}:

createScript "transcode-video" ./transcode-video.sh {
  dependencies = [
    jellyfin-ffmpeg # Has some fixes for OPUS encoding
    coreutils
  ];

  meta.description = "transcode videos to HEVC/OPUS, with compression and hardware acceleration";
}
