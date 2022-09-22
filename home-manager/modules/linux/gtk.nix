{ config
, pkgs
, ...
}:

{
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Purple-Dark";
      package = pkgs.catppuccin-gtk;
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
}

