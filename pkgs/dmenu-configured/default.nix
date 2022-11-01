{ runCommand
, dmenu
, fetchpatch
, makeWrapper
}:

# A wrapped version of dmenu using the same theme used by i3/sway, using with the same height as the bar
runCommand "dmenu-configured"
{
  _dmenu = dmenu.override {
    patches = [
      # Allow configuring the height of the window with "-h"
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.2.diff";
        sha256 = "sha256-QdY2T/hvFuQb4NAK7yfBgBrz7Ii7O7QmUv0BvVOdf00=";
      })
    ];
  };
  nativeBuildInputs = [ makeWrapper ];
} ''
  mkdir -p $out/bin
  for bin in $_dmenu/bin/*; do
    # TODO: inherit these colors somehow
    makeWrapper $bin $out/bin/$(basename ''${bin}) \
      --add-flags "-nf '#cdd6f4' -nb '#12121c' -sb '#cba6f7' -sf '#12121c' -h 23"
  done
''
