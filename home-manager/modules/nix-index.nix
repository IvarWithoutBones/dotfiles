{ nix-index-database, ... }:

{
  imports = [ nix-index-database.hmModules.nix-index ];
  programs.nix-index.enable = true;
}
