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
        version = "unstable-2020-08-07";
        src = pkgs.fetchFromGitHub {
          owner = "LukeSmithxyz";
          repo = "st";
          rev = "de6fd85eeb544548ed5ad23a639eedd6af510036";
          sha256 = "1xyrbi857435dln7i6qb9ys2jizv43a2zq6fx4dr8z52ramxzyky";
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

      # Media
      ncspot spotify
      firefox # Have to keep this installed for the 1password extension, unfortunately
      mpv

      # Applications
      discord
      dolphinEmu
      pavucontrol
      arc-theme capitaine-cursors arc-icon-theme
      transmission-gtk
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
