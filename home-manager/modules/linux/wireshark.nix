{ pkgs, ... }:

# System configuration for Wireshark, a network protocol analyzer.
# Used in conjunction with `modules/linux/wireshark.nix`.

{
  home.packages = [ pkgs.wireshark ];

  # Plugin to decode ISO 15118 V2G messages.
  home.file.".local/lib/wireshark" = {
    recursive = true;
    source = pkgs.fetchzip {
      url = "https://github.com/dspace-group/dsV2Gshark/releases/download/v2.0.0/dsV2Gshark_Files_Linux_x86_64.zip";
      hash = "sha256-3zSi3NPO7I2tWCGhFiv8R6Ujd9rhmpJEMSlnslmiNhM=";
      stripRoot = false;
    };
  };

  # Wireshark profile for dsV2Gshark.
  xdg.configFile."wireshark/profiles/dsV2Gshark".source =
    pkgs.fetchzip {
      url = "https://github.com/dspace-group/dsV2Gshark/releases/download/v2.0.0/dsV2Gshark_profile.zip";
      hash = "sha256-9bzbCwNS3QWxQyLHRYu8ZaRtXDnXFB8R6oP8QA0n+hY=";
    }
    + "/profiles/dsV2Gshark";
}
