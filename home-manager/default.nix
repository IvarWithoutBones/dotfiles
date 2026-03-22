{ ... }:

{
  xdg.configFile = {
    # Applies for imperative commands.
    "nixpkgs/config.nix".text = "{ allowUnfree = true; }";
    "nix/config.nix".text = "{ allowUnfree = true; }";

    # Per-user Nix configuration. Disables imperative configuration and registry additions.
    "nix/nix.conf".text = "experimental-features = nix-command flakes";
    "nix/registry.json".text = ''
      {
        "flakes": null,
        "version": 2
      }
    '';
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
