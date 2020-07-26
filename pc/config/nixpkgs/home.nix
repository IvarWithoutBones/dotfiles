{ config, pkgs, ... }:
let
  requiredPackages = import ./requiredPackages.nix;
  zshSettings = import ./programs/zsh.nix;
  vimSettings = import ./programs/nvim.nix;
  quteSettings = import ./programs/qutebrowser.nix;
  dunstSettings = import ./programs/dunst.nix;
  i3Settings = import ./programs/i3/i3.nix;

  globalConfig = {
    pkgs = pkgs;
    homeDir = builtins.getEnv "HOME";
    backgroundColor = "#2f343f";
  };
in
{
  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      st = (pkgs.st.overrideAttrs (attrs: {
        pname = "luke-st";
        version = "unstable-2020-07-08";
        src = pkgs.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "e187610a230803ddca6b86fe0620cacdee177ac3";
          sha256 = "1aricnhcaxglyiyvcgfaf0g3glxis6rs84h9hd13ccmh181v0mkz";
        };
        buildInputs = attrs.buildInputs ++ [ pkgs.harfbuzz ];
      }));
    };
  };

  home = {
    username = "ivar";
    homeDirectory = globalConfig.homeDir;
    stateVersion = "20.09";
    packages = with pkgs; requiredPackages globalConfig ++ [
      # General utils
      htop gotop
      wget git
      unar
      neofetch
      tree
      bat

      # Nix specific utils
      nix-index
      nix-prefetch-git
      direnv

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
      arc-theme capitaine-cursors arc-icon-theme
      discord
      transmission-gtk
      pentablet-driver
      mupdf
    ];
  };

  programs = {
    home-manager.enable = true;
    command-not-found.enable = true;
    neovim = vimSettings globalConfig;
    zsh = zshSettings globalConfig;
    qutebrowser = quteSettings globalConfig;
  };

  services = {
    dunst = dunstSettings globalConfig;
    lorri.enable = true;
  };

  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
    windowManager.i3 = i3Settings globalConfig;
  };

  xresources.properties = {
    "foreground" = "#F8F8F2";
    "background" = globalConfig.backgroundColor;
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
