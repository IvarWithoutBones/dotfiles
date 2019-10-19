with import <nixpkgs> {};

python3.withPackages (ps: with ps; [ setuptools dbus-python requests psutil ])
