{ pkgs
, ...
}:

{
  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-dark";
      package = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = [ "mauve" ];
        size = "standard";
      };
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

