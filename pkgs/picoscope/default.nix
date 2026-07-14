{
  lib,
  oldPicoscope,
  patchelfUnstable, # We need unstable for `--clear-execstack`
}:

oldPicoscope.overrideAttrs (oldAttrs: {
  postInstall = oldAttrs.postInstall or "" + ''
    # Remove the executable stack flag. Modern dynamic loaders will refuse to load binaries with it set,
    # which causes PicoScope to segfault. The program still seems to work fine without it.
    # Taken from: https://www.picotech.com/support/viewtopic.php?t=43186
    ${lib.getExe patchelfUnstable} --clear-execstack $out/lib/libpicoipp.so
  '';
})
