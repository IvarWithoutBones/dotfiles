{ config
, pkgs
, ...
}:

{
  home = {
    # Package provided from my overlay, maps to binary from mic92/nix-index-database's cache
    file.".cache/nix-index/files".source = pkgs.nix-index-database;

    packages = [
      pkgs.nix-index
    ];
  };
}
