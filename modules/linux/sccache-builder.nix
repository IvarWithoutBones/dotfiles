{
  config,
  lib,
  pkgs,
  ...
}:

# Build server for distributed compilation with sccache.

let
  port = 10501;
  package = (pkgs.sccache.override { distributed = true; }).overrideAttrs (old: {
    # Support for automatically packaging Nix's C compilers: https://github.com/mozilla/sccache/pull/2698
    patches = old.patches or [ ] ++ [
      (pkgs.fetchpatch {
        url = "https://github.com/IvarWithoutBones/sccache/commit/b4efffa6a1e6731314ccfb80b40290b9c50a4a15.patch";
        hash = "sha256-6/svDyv3JihE7mYQSrkERWQHSM6yuysyrKCYudJo87k=";
      })
    ];
  });
in
{
  systemd.services.sccache-builder = {
    description = "sccache builder for distributed compilation";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    environment.SCCACHE_LOG = "info";

    serviceConfig = {
      ExecStart = "${lib.getExe' package "sccache-dist"} server --config \"\${STATE_DIRECTORY}/config.toml\"";

      # Generate the config file every time the service starts. Needed because we inject secrets into the configuration file.
      ExecStartPre = pkgs.writeShellScript "sccache-builder-generate-config" ''
        set -euo pipefail

        {
          echo "scheduler_url = \"$(cat "$CREDENTIALS_DIRECTORY/scheduler-url")\""
          echo "public_addr = \"$(cat "$CREDENTIALS_DIRECTORY/public-addr"):${toString port}\""
          echo "cache_dir = \"$STATE_DIRECTORY/toolchains\""
          echo ""
          echo "[builder]"
          echo "type = \"overlay\""
          echo "build_dir = \"$RUNTIME_DIRECTORY/build\""
          echo "bwrap_path = \"${lib.getExe pkgs.bubblewrap}\""
          echo ""
          echo "[scheduler_auth]"
          cat "$CREDENTIALS_DIRECTORY/scheduler-auth"
        } | install -D -m 600 /dev/stdin "$STATE_DIRECTORY/config.toml"
      '';

      LoadCredential = [
        "public-addr:${config.sops.secrets."sccache-builder/public-addr".path}"
        "scheduler-url:${config.sops.secrets."sccache-builder/scheduler-url".path}"
        "scheduler-auth:${config.sops.secrets."sccache-builder/scheduler-auth".path}"
      ];

      UMask = "0077"; # Ensure files created by sccache are only accessible by the service user.
      RuntimeDirectory = [ "sccache-builder" ];
      StateDirectory = [ "sccache-builder" ];

      # Running as root is required as of sccache 0.15.0.
      User = "root";
      Restart = "always";
      RestartSec = 5;

      # Isolate the service from the host's filesystem.
      RootDirectory = "/run/sccache-builder";
      BindReadOnlyPaths = [
        builtins.storeDir
      ];

      # Limit the service's capabilities and access to the system as much as possible.
      NoNewPrivileges = true;
      MemoryDenyWriteExecute = true;
      LockPersonality = true;
      SystemCallArchitectures = "native";
      ProtectSystem = true;
      ProtectHome = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      ProtectClock = true;
      PrivateTmp = true;
      PrivateMounts = true;
      PrivateDevices = true;
      PrivateUsers = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_NETLINK"
      ];

      # For creating kernel namespaces with bubblewrap
      CapabilityBoundingSet = [
        "CAP_SYS_ADMIN"
        "CAP_SETFCAP"
        "CAP_DAC_OVERRIDE"
      ];
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ port ];
    allowedUDPPorts = [ port ];
  };

  environment.systemPackages = [ package ];

  sops.secrets."sccache-builder/public-addr".sopsFile =
    ../../secrets/${config.networking.hostName}/host.yaml;

  sops.secrets."sccache-builder/scheduler-url".sopsFile =
    ../../secrets/${config.networking.hostName}/host.yaml;

  sops.secrets."sccache-builder/scheduler-auth".sopsFile =
    ../../secrets/${config.networking.hostName}/host.yaml;
}
