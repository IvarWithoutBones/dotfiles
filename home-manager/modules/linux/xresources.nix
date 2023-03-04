{ config
, pkgs
, ...
}:

let
  catppuccin-theme = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/xresources/d82c02323e05158ad35f302771e3695affafab78/mocha.Xresources";
    sha256 = "sha256-p2vDNHLhjQM+JnrmuLRRmoR/7Rq4NIgdR4YYGiDqPT0=";
  };
in
{
  xresources = {
    extraConfig = ''
      #include "${catppuccin-theme}"
      ${pkgs.dmenu-configured.xresources}
    '';
  };
}
