{ createScript
, ffmpeg-full
, coreutils
}:

createScript "compress-video" ./compress-video.sh {
  dependencies = [
    ffmpeg-full
    coreutils
  ];

  meta.description = "a script to compress video files using ffmpeg";
}
