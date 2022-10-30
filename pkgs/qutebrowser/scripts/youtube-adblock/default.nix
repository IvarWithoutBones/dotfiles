{ fetchurl }:

fetchurl {
  name = "youtube-adblock.js";

  url = "https://raw.githubusercontent.com/afreakk/greasemonkeyscripts/1d1be041a65c251692ee082eda64d2637edf6444/youtube_adblock.js";
  sha256 = "sha256-EuGTJ9Am5C6g3MeTsjBQqyNFBiGAIWh+f6cUtEHu3iI=";

  meta.description = "Remove ads on YouTube more reliably than with the default adblock";
}
