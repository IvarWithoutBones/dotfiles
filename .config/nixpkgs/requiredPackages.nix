pkgs:

# These packages are required by my dotfiles
with pkgs; [
  st
  dmenu
  xorg.xprop
  sysstat
  feh
  imagemagick
  speedtest-cli
  perl
  i3lock
  dconf # Required for some GTK based app's settings to be saved
  
  (python38.withPackages (pkgs: with pkgs; [
    setuptools
    dbus-python
  ]))
]
