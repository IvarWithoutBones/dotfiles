{ pkgs
, config
, username
, ...
}:

{
  imports = [
    ./packages.nix
    ./modules/alacritty.nix
    ./modules/zsh.nix
    ./modules/nvim.nix
    ./modules/qutebrowser.nix
    ./modules/dunst.nix
    ./modules/i3/i3.nix
  ];
  
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (pkg: true);
    experimental-features = "nix-command flakes";
    packageOverrides = pkgs: {
      discord = (pkgs.discord.overrideAttrs (attrs: { # Use the latest version because upstream updates break old versions
        src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz";
      }));
    };
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
  
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
  };
}
