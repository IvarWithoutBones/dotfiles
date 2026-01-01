{ createScript
, ffmpeg-full
, coreutils
}:

createScript "transcode-video" ./transcode-video.sh {
  dependencies = [
    ffmpeg-full
    coreutils
  ];

  meta.description = "transcode videos to HEVC/OPUS, with compression and hardware acceleration";
}
