{
  pkgs,
  ...
}:

{
  gtk = {
    enable = true;

    theme = {
      name = "Colloid-Purple-Dark-Catppuccin";
      package = pkgs.colloid-gtk-theme.override {
        tweaks = [ "catppuccin" ];
        themeVariants = [ "purple" ]; # Matches Catppuccin's mauve
        colorVariants = [ "dark" ];
      };
    };

    iconTheme = {
      name = "Arc";
      package = pkgs.arc-icon-theme;
    };
  };
}
