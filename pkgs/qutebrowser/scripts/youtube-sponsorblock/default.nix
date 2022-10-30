{ lib
, fetchurl
}:

fetchurl {
  name = "youtube-sponsorblock.js";

  url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/1d1be041a65c251692ee082eda64d2637edf6444/youtube_sponsorblock.js";
  sha256 = "sha256-e3QgDPa3AOpPyzwvVjPQyEsSUC9goisjBUDMxLwg8ZE=";

  meta.description = "Skip sponsor segments on YouTube";
}
