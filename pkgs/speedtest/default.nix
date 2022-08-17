{ createScript
, speedtest-cli
, iputils
, coreutils
, gnugrep
}:

createScript "speedtest" ./speedtest.sh {
  dependencies = [
    speedtest-cli
    iputils
    coreutils
    gnugrep
  ];

  meta.description = "shell utility to test ping and upload/download speeds";
}
