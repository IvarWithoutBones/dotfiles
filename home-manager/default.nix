{ ... }:

{
  # Applies inside of the home-manager config
  nixpkgs.config = {
    allowUnfree = true;
    experimental-features = "nix-command flakes";
  };

  # Applies for imperative commands
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    }
  '';

  programs = {
    command-not-found.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
