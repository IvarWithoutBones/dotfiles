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

  home = {
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "alacritty";
    };
  };
  
  gtk = {
    enable = true;

    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };

    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };

    cursorTheme = {
      name = "capitaine-cursors";
      package = pkgs.capitaine-cursors;
    };
  };

  programs = {
    command-not-found.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
  
  fonts.fontconfig.enable = true;
}
