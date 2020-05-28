pkgs:

# These packages are required by my dotfiles
with pkgs; [
  st
  dmenu
  sysstat
  imagemagick
  speedtest-cli
  perl
  i3lock
  maim # Required for lock script & screenshots
  dconf # Required for some GTK based app's settings to be saved
  
  (python38.withPackages (pkgs: with pkgs; [
    setuptools
    dbus-python
  ]))
]
