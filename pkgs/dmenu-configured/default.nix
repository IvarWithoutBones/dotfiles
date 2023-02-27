{ lib
, stdenvNoCC
, fetchpatch
, makeWrapper
, dmenu
}:

let
  dmenuWithPatches = dmenu.override {
    patches = [
      # Fuzzy matching
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-4.9.diff";
        sha256 = "sha256-zfmsKfN791z6pyv+gA6trdfKvNnCCULazVtk1sibDgA=";
      })

      # Allow configuring the theme with Xresources
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/xresources/dmenu-xresources-4.9.diff";
        sha256 = "sha256-Np9I8hhnwmGA3W5v4tSrBN9Or8Q2Ag9x8H3yf8L9jDI=";
      })

      # Allow configuring the height of the statusline
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/line-height/dmenu-lineheight-5.2.diff";
        sha256 = "sha256-QdY2T/hvFuQb4NAK7yfBgBrz7Ii7O7QmUv0BvVOdf00=";
      })
    ];
  };
in
dmenuWithPatches.overrideAttrs (prevAttrs: {
  postPatch = prevAttrs.postPatch or "" + ''
    # Patch in the desired statusline height
    substituteInPlace config.def.h --replace \
      'static unsigned int lineheight = 0;' \
      'static unsigned int lineheight = 24;'
  '';

  passthru = {
    xresources = ''
      dmenu.background: #12121C
      dmenu.foreground: #CDD6F4
      dmenu.selbackground: #CBA6F7
      dmenu.selforeground: #12121C
    '';
  } // prevAttrs.passthru or { };
})
