{
  allowUnfree = true;
  fonts.fontconfig.defaultFonts.emoji = "Twitter Color Emoji";
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
