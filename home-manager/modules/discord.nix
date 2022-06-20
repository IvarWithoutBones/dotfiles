{ pkgs
, lib
, config
, ...
}:

let
  themes = [
    {
      # Theme from https://github.com/kira64xyz, thanks!
      name = "catppuccin";
      src = pkgs.fetchurl {
        name = "catppuccin-discord-theme";
        url = "https://gist.githubusercontent.com/IvarWithoutBones/51d7c30198a3d8b6d58963ec48ecd954/raw/fa4506a6516e767137322de57c741c38b08b5d4e/Catppuccin.theme.css";
        sha256 = "sha256-7sp6JE8TDA/bc93nL6w9EvoRiAxTLorLj/kO1KWxlLM=";
      };
    }
  ];

  plugins = [
    {
      # A plugin which allows you to translate messages
      name = "translator";
      src = pkgs.fetchurl {
        name = "translator-discord-plugin";
        url = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/a711d71105fe5f8bae243f4a7a85eb2bc62d57a4/Plugins/Translator/Translator.plugin.js";
        sha256 = "sha256-MmPD/w4lDsT89fVAlEVOQK41UjelfSGaGGSOl+V290Y=";
      };
    }
    {
      # A plugin which allows you to see the date an account was created
      name = "creationdate";
      src = pkgs.fetchurl {
        name = "creationdate-discord-plugin";
        url = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/5ec27dcd3c3bbd6366e93990bd7e8b3b07d080a4/Plugins/CreationDate/CreationDate.plugin.js";
        sha256 = "sha256-ExIRYWafehpljWmXQhnU/2EPp6LK3dPwTHOMRD+HBlU=";
      };
    }
    {
      # Dependency of translator and creation date plugins
      name = "0bdfdb";
      src = pkgs.fetchurl {
        name = "0bdfdb-discord-plugin";
        url = "https://raw.githubusercontent.com/mwittrien/BetterDiscordAddons/724e4047c86a616546d6e8e59fdca4d4be3ac0dc/Library/0BDFDB.plugin.js";
        sha256 = "sha256-4KP9EaS3h5dbzSjngF9PqGmnyJ9rMKqHc+TN3Y1k6ac=";
      };
    }
  ];
in
{
  home.packages = [ pkgs.discord ];

  # A activation script which installs BetterDiscord and the themes/plugins.
  # These cannot be symlinked because of a bug in BetterDiscord, so we have to copy them instead.
  home.activation.betterdiscord =
    let
      betterdiscordctl = "${pkgs.betterdiscordctl}/bin/betterdiscordctl";
    in
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Install BetterDiscord if it isnt already
      ${betterdiscordctl} status | grep -E 'installed|injected' | grep -q "no" && \
        $DRY_RUN_CMD ${betterdiscordctl} install

      $DRY_RUN_CMD mkdir -p "${config.xdg.configHome}/BetterDiscord{,/themes,/plugins}"
      $DRY_RUN_CMD pushd "${config.xdg.configHome}/BetterDiscord" >/dev/null

      # Copy the themes to their folder
      $DRY_RUN_CMD cd "themes"

      ${lib.concatMapStrings (theme: ''
      if ! [ -f "${theme.name}.theme.css" ]; then
        $DRY_RUN_CMD cat "${theme.src}" > "${theme.name}.theme.css";
      fi
      '') themes}
      $DRY_RUN_CMD cd ..

      # Copy the plugins to their folder
      $DRY_RUN_CMD cd "plugins"

      ${lib.concatMapStrings (plugin: ''
      if ! [ -f "${plugin.name}.plugin.js" ]; then
        $DRY_RUN_CMD cat "${plugin.src}" > "${plugin.name}.plugin.js";
      fi
      '') plugins}

      $DRY_RUN_CMD popd >/dev/null
    '';
}