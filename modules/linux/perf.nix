{ config
, lib
, pkgs
, ...
}:

{
  environment.systemPackages = lib.toList config.boot.kernelPackages.perf;
}
