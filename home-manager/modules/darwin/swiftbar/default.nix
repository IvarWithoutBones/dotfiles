{ config
, lib
, pkgs
, ...
}:

{
  # TODO: remove when https://github.com/nix-community/home-manager/pull/3207 is merged
  imports = [ ./module.nix ];

  programs.swiftbar = {
    enable = true;

    plugins = [
      {
        # Show the current space in the bar
        name = "show-space-index";
        refreshRate = "100ms";

        plugin = pkgs.writeShellScript "show-space-index" ''
          ${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | select(."has-focus" == true) | .index'
        '';

        meta.swiftbar = {
          hideAbout = true;
          hideRunInTerminal = true;
          hideLastUpdated = true;
          hideSwiftBar = true;
        };
      }
    ];
  };
}
