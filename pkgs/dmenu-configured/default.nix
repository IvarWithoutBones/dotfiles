{ fetchpatch
, dmenu
}:

let
  patched = dmenu.override {
    patches = [
      # Fuzzy matching
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff";
        sha256 = "sha256-uPuuwgdH2v37eaefnbQ93ZTMvUBcl3LAjysfOEPD1Y8=";
      })

      # Allow configuring the height of the statusline
      (fetchpatch {
        url = "https://tools.suckless.org/dmenu/patches/bar_height/dmenu-bar-height-5.2.diff";
        sha256 = "sha256-3YcVmQqqKb5GEfujq6iZYpeuezfvRmSRMSNhyIELUAI=";
      })
    ];
  };
in
patched.overrideAttrs (prev: {
  # Required for the fuzzymatch patch to compile, it doesn't appear to pass this flag correctly to all compiled objects.
  NIX_CFLAGS_COMPILE = prev.NIX_CFLAGS_COMPILE or [ ] ++ [ "-lm " ];

  postPatch = prev.postPatch or "" + ''
    # Patch in the desired bar height
    substituteInPlace config.def.h \
      --replace-fail 'static const int user_bh = 0;' 'static const int user_bh = 10;'

    # Configure what colors are used. Foreground comes first, then background.
    substituteInPlace config.def.h \
      --replace-fail '[SchemeNorm] = { "#bbbbbb", "#222222" },' '[SchemeNorm] = { "#cdd6f4", "#12121c" },' \
      --replace-fail '[SchemeSel] = { "#eeeeee", "#005577" },'  '[SchemeSel] = { "#12121c", "#cba6f7" },'
  '';
})
