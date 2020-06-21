globalConfig: let
  pkgs = globalConfig.pkgs;
in
with pkgs; [ # These packages are required by my dotfiles
  st
  dmenu
  sysstat
  perl
  dconf # Required for some GTK based app's settings to be saved
  
  (python38.withPackages (pkgs: with pkgs; [
    setuptools
    dbus-python
  ]))
]
