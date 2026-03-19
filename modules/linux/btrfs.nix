{ config, lib, ... }:

# Support for the BTRFS filesystem

{
  boot.supportedFilesystems.btrfs = true;

  # Automatically check for file consistency if we have any btrfs filesystem pernamently mounted
  services.btrfs.autoScrub.enable = lib.any (fs: fs.fsType == "btrfs") (
    lib.attrValues config.fileSystems
  );
}
