{ config, pkgs, ... }:
let
  requiredPackages = import ./requiredPackages.nix;
  zshSettings = import ./programs/zsh.nix;
  vimSettings = import ./programs/nvim.nix;
  quteSettings = import ./programs/qutebrowser.nix;
  dunstSettings = import ./programs/dunst.nix;
  i3Settings = import ./programs/i3/i3.nix;
in
{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      st = (pkgs.st.overrideAttrs (attrs: {
        pname = "luke-st";
        version = "unstable-2020-05-17";
        src = pkgs.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "22c71c355ca4f4e965c3d07e9ac37b0da7349255";
          sha256 = "0hnzm0yqbz04y95wg8kl6mm6cik52mrygm8s8p579fikk6vlq3bx";
        };
      }));
    };
  };

  home = {
    username = "ivar";
    homeDirectory = "/home/ivar";
    stateVersion = "20.09";
    packages = with pkgs; requiredPackages pkgs ++ [
      # General utils
      unar unzip
      cmake gnumake
      wget
      git
      htop
      neofetch
      tree
      fzf

      # Nix specific utils
      nix-index
      nix-prefetch-git
      direnv
      nixpkgs-review

      # Games
      snes9x-gtk mupen64plus dolphinEmu
      steam

      # Media
      kdenlive obs-studio
      ncspot spotify
      firefox # Have to keep this installed for the 1password extension, unfortunately
      tor-browser-bundle-bin
      mpv
      ffmpeg

      # Applications
      pavucontrol
      lxappearance
      arc-theme
      capitaine-cursors
      arc-icon-theme
      discord
      transmission-gtk
      pentablet-driver
      mupdf
    ];
  };

  programs = {
    home-manager.enable = true;
    neovim = vimSettings pkgs;
    zsh = zshSettings pkgs;
    qutebrowser = quteSettings;
  };

  services = {
    dunst = dunstSettings;
    lorri.enable = true;
  };

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = i3Settings pkgs;
  };

  xresources.properties = {
    "foreground" = "#F8F8F2";
    "background" = "#282A36";
    "color0" = "#000000";
    "color1" = "#FF5555";
    "color2" = "#50FA7B";
    "color3" = "#F1FA8C";
    "color4" = "#BD93F9";
    "color5" = "#FF79C6";
    "color6" = "#8BE9FD";
    "color7" = "#BFBFBF";
    "color8" = "#4D4D4D";
    "color9" = "#FF6E67";
    "color10" = "#5AF78E";
    "color11" = "#F4F99D";
    "color12" = "#CAA9FA";
    "color13" = "#FF92D0";
    "color14" = "#9AEDFE";
    "color15" = "#E6E6E6";
  };
}
