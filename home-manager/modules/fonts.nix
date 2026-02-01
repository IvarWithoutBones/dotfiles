{ pkgs, ... }:

{
  fonts.fontconfig = {
    enable = true;
    antialiasing = true;
    hinting = "slight";

    defaultFonts = {
      monospace = [ "FiraCode Nerd Font" ];
      emoji = [ "Noto Color Emoji" "FiraCode Nerd Font" ];
      serif = [ "Noto Serif" ];
      sansSerif = [ "Noto Sans" ];
    };
  };

  home.packages = with pkgs; [
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
    corefonts
    vista-fonts
  ];
}
