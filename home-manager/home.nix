{ pkgs, config, ... }: 

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
    experimental-features = "nix-command";
    packageOverrides = pkgs: {
      discord = (pkgs.discord.overrideAttrs (attrs: { # Use the latest version because upstream updates break old versions
        src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz";
      }));
    };
  };

  home = {
    username = "ivv";
    homeDirectory = "/home/ivv";
    stateVersion = "22.05";
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = "nvim";
      TERMINAL = "alacritty";
    };
  };
  
  programs = {
    home-manager.enable = true;
    command-not-found.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    sm64ex = {
      enable = true;
      baserom = /mnt/hdd/roms/n64/baserom.us.z64; # TODO: set this from flake??
    };
  };
  
  fonts.fontconfig.enable = true;
  
  xsession = {
    enable = true;
    scriptPath = ".hm-xsession";
  };
}
