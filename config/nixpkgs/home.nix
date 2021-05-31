{ config, pkgs, ... }: {

imports = [
  ./packages.nix
  ./modules/zsh.nix
  ./modules/nvim.nix
  ./modules/qutebrowser.nix
  ./modules/dunst.nix
  ./modules/i3/i3.nix
];

nixpkgs.config = {
  allowUnfree = true;
  packageOverrides = pkgs: {
    st = (pkgs.st.overrideAttrs (attrs: {
      pname = "luke-st";
      version = "unstable-2021-05-21";
      src = pkgs.fetchFromGitHub {
        owner = "LukeSmithxyz";
        repo = "st";
        rev = "ecd5e3f7984e194fe9d6956b2057be064d194895";
        sha256 = "05w49mjxl5lfxxbhhcnhph7zv740hkyc97b0va09q9pr077xbvz6";
      };
      buildInputs = attrs.buildInputs ++ [ pkgs.harfbuzz ];
      preInstall = ''
        substituteInPlace Makefile --replace "git" "#git" # For some reason, submodules are being fetched in the installPhase
        substituteInPlace st-urlhandler --replace "dmenu" "${pkgs.dmenu}/bin/dmenu"
      '';
    }));
    discord = (pkgs.discord.overrideAttrs (attrs: { # This always uses the latest version of Discord, which sometimes it won't boot without.
      src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz";
    }));
  };
};

home = {
  username = "ivv";
  homeDirectory = builtins.getEnv "HOME";
  stateVersion = "20.09";
};

programs = {
  home-manager.enable = true;
  command-not-found.enable = true;
};

services.lorri.enable = true;

fonts.fontconfig.enable = true;

xsession = {
  enable = true;
  scriptPath = ".hm-xsession";
};

xresources.properties = {
  "foreground" = "#F8F8F2";
  "background" = "#2f343f";
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
