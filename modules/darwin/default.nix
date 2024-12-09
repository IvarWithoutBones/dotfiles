{ pkgs
, username
, ...
}:

{
  services.nix-daemon.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts-emoji
    nerd-fonts.fira-code
  ];

  # This line is required; otherwise, on shell startup, you won't have Nix stuff in the PATH.
  programs.zsh.enable = true;

  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };

  system.stateVersion = 5;
}
