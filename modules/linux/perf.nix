{ config
, pkgs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.perf
    valgrind
    kcachegrind
  ];
}
