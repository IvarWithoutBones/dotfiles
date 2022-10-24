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
  # Package from my overlay
  home.packages = lib.toList pkgs.discord-with-openasar;

  # Install BetterDiscord and themes for it. Themes cannot be symlinked because of a bug in BetterDiscord,
  # so they are copied them instead.
  home.activation.betterdiscord =
    let
      betterdiscordctl = "${pkgs.betterdiscordctl}/bin/betterdiscordctl";
      themesPath = "${config.xdg.configHome}/BetterDiscord/themes";
    in
    lib.mkIf pkgs.stdenv.isLinux (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Install BetterDiscord if it isnt already
      ${betterdiscordctl} status | grep -E 'installed|injected' | grep -q "no" && \
          $DRY_RUN_CMD ${betterdiscordctl} install

      $DRY_RUN_CMD mkdir -p "${themesPath}"
      ${lib.concatMapStrings (theme: ''
      if ! [ -f "${themesPath}/${theme.name}.theme.css" ]; then
          $DRY_RUN_CMD cp "${theme.src}" "${themesPath}/${theme.name}.theme.css";
      fi
      '') themes}
    '');

  # This fixes an issue with Discord where being in a call for a long time causes the client to become unresponsive.
  # For more information see https://gist.github.com/Shika-B/fc15c63d66716347df8627c0d42959b5.
  home.activation.discord = lib.mkIf pkgs.stdenv.isLinux
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD eval "${pkgs.discord-with-openasar.noVoicechatLag.outPath}" 1>/dev/null
    '');
}
