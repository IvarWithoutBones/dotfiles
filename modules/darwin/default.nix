{
  pkgs,
  ...
}:

{
  # Set the Nix build group ID to it's old default value, matching the state Nix was installed with.
  ids.gids.nixbld = 30000;

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    nerd-fonts.fira-code
  ];

  # This line is required; otherwise, on shell startup, you won't have Nix stuff in the PATH.
  programs.zsh.enable = true;
}
