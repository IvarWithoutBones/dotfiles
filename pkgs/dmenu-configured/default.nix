{ runCommand
, dmenu
, fetchpatch
, makeWrapper
}:

# A wrapped version of dmenu configured to match the theme used by i3/sway, and with the size configured to be the same as my bar
runCommand "dmenu-configured"
{
  _dmenu = dmenu.override {
    patches = [
      (fetchpatch {
        # Allow configuring the height of the window with "-h"
        url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.0.diff";
        sha256 = "sha256-St1x4oZCqDnz7yxw7cQ0eUDY2GtL+4aqfUy8Oq5fWJk=";
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
