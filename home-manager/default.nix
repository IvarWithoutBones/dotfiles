{ config
, ...
}:

{
  nixpkgs.config = {
    allowUnfree = true;
    experimental-features = "nix-command flakes";
  };

  programs = {
    command-not-found.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
