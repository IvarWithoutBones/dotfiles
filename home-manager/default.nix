{ ... }:

{
  # Applies for imperative commands
  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    }
  '';

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
