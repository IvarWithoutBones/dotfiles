{ pkgs
, config
, nixpkgs
, ...
}:

{
  services.nix-daemon.enable = true;

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
