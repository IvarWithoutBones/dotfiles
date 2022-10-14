{ pkgs
, lib
, config
, ...
}:

let
  # Theme from https://github.com/kira64xyz, thanks!
  themes = [
    {
      name = "catppuccin";
      src = pkgs.fetchurl {
        name = "catppuccin-discord-theme";
        url = "https://gist.githubusercontent.com/IvarWithoutBones/51d7c30198a3d8b6d58963ec48ecd954/raw/fa4506a6516e767137322de57c741c38b08b5d4e/Catppuccin.theme.css";
        sha256 = "sha256-7sp6JE8TDA/bc93nL6w9EvoRiAxTLorLj/kO1KWxlLM=";
      };
    }
  ];
in
{
  home.packages = lib.toList (pkgs.discord.override {
    withOpenASAR = true;
  });

  # A activation script which installs BetterDiscord and the themes/plugins.
  # These cannot be symlinked because of a bug in BetterDiscord, so we have to copy them instead.
  home.activation.betterdiscord =
    let
      betterdiscordctl = "${pkgs.betterdiscordctl}/bin/betterdiscordctl";
    in
    lib.mkIf pkgs.stdenv.isLinux (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Install BetterDiscord if it isnt already
      ${betterdiscordctl} status | grep -E 'installed|injected' | grep -q "no" && \
          $DRY_RUN_CMD ${betterdiscordctl} install

      $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/BetterDiscord/themes"
      $DRY_RUN_CMD pushd "${config.xdg.configHome}/BetterDiscord/themes" >/dev/null

      ${lib.concatMapStrings (theme: ''
      if ! [ -f "${theme.name}.theme.css" ]; then
          $DRY_RUN_CMD cp "${theme.src}" "${theme.name}.theme.css";
      fi
      '') themes}

      $DRY_RUN_CMD popd >/dev/null
    '');
}
