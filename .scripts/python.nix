with import <nixpkgs> {};

python38.withPackages (ps: with ps; [ setuptools dbus-python ])
