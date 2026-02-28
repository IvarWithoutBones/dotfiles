{ ivar-dotfiles, ... }:

{
  imports = [ ivar-dotfiles.inputs.nix-index-database.homeModules.nix-index ];
  programs.nix-index.enable = true;
}
