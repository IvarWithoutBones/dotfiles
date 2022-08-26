{ config
, pkgs
, ...
}:

# Display the currently active space in the menu bar. Note that the location to the scripts directory can only be provided through the GUI sadly.

{
  environment.etc."swiftbar/space.100ms.sh".source = pkgs.writeShellScript "swiftbar-space" ''
    ${pkgs.yabai}/bin/yabai -m query --spaces | ${pkgs.jq}/bin/jq -r '.[] | select(."has-focus" == true) | .index'
  '';

  launchd.user.agents.swiftbar = {
    path = [ config.environment.systemPath pkgs.swiftbar ];
    command = "${pkgs.swiftbar}/bin/SwiftBar";
    serviceConfig = {
      KeepAlive = true;
      ProcessType = "Interactive";
    };
  };
}
