{ pkgs
, config
, username
, ...
}:

{
  imports = [
    ./packages.nix
    ./modules/alacritty.nix
    ./modules/discord.nix
    ./modules/zsh.nix
    ./modules/nvim.nix
    ./modules/qutebrowser.nix
    ./modules/dunst.nix
    ./modules/mpv.nix
    ./modules/i3-sway
  ];

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
