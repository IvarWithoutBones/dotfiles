{ lib
, discord
, writeShellScript
, coreutils
, findutils
, gnused
, asar # from nodePackages
}:

let
  noVoicechatLag = writeShellScript "fix-discord-voicechat-lag" ''
    # This fixes an issue where being in a call for a long time causes the client to become unresponsive.
    # For more information see https://gist.github.com/Shika-B/fc15c63d66716347df8627c0d42959b5

    set -euo pipefail

    export PATH="${lib.makeBinPath [
      coreutils
      findutils
      gnused
      asar
    ]}"

    path="$(find "$HOME/.config/discord" -name discord_desktop_core -type d | tail -n1)"
    if [ -d "$path/core-patched" ]; then
        echo "already patched, doing nothing"
        exit 0
    fi

    tmpdir=$(mktemp -dt asar-XXXXXXXXXX)
    trap 'rm -rf "$tmpdir"' EXIT

    echo "patching $path/core.asar"
    asar extract "$path/core.asar" "$tmpdir"
    sed -i '/^function setTrayIcon.*/a return;' "$tmpdir/app/systemTray.js"

    echo "copying patched module to $path/core-patched"
    cp -r "$tmpdir" "$path/core-patched"

    echo "replacing reference to core.asar with the patched module"
    sed -i.bak "s/require('.\/core\.asar')/require('.\/core-patched')/g" "$path/index.js"
    echo "wrote a backup of index.js to $path/index.js.bak"

    echo "patching was successful. you can now restart discord"
  '';
in
(discord.override {
  withOpenASAR = true;
}).overrideAttrs (old: {
  passthru = old.passthru or { } // {
    inherit noVoicechatLag;
  };

  meta = old.meta or { } // {
    longDescription = old.meta.longDescription or "" + ''
      This includes a script to fix lag after being in a voice call for a long time. you
      can build it with 'nix-build -A discord.noVoicechatLag', and then run it with './result'.
    '';
  };
})
