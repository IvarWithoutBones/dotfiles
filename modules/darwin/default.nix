{ pkgs
, config
, ...
}:

{
  services.nix-daemon.enable = true;

  nix = {
    package = pkgs.nixUnstable;

    registry.nixpkgs.flake = nixpkgs;

    # The `settings` attribute is not exposed by nix-darwin. Temporarily configure it here until i backport the module from nixpkgs
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
      noto-fonts-emoji
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];
  };

  # This line is required; otherwise, on shell startup, you won't have Nix stuff in the PATH.
  programs.zsh.enable = true;

  users.users.ivv = {
    name = "ivv";
    home = "/Users/ivv";
  };
}
