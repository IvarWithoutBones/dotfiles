{ lib
, pkgs
, config
, username
, ...
}:

{
  services.yabai = {
    enable = true;
    package = pkgs.yabai; # TODO: make this the default

    config = {
      layout = "bsp";
      focus_follows_mouse = "autofocus";
      auto_balance = "on";

      top_padding = 10;
      bottom_padding = 10;
      left_padding = 10;
      right_padding = 10;
      window_gap = 10;
    };

    extraConfig = ''
      yabai -m rule --add app='System Preferences' manage=off
      yabai -m rule --add app='Boot Camp Assistant' manage=off
      yabai -m rule --add app='System Information' manage=off
      yabai -m rule --add app='SwiftBar' manage=off
      yabai -m rule --add app='Widgets Manager' manage=off # From pock
      yabai -m rule --add app="Discord" space=3
    '';
  };

  # The scripting addition needs root access to load, which we want to do automatically when logging in.
  # This disables the password requirement for it, so that a user-agent can launch it.
  environment.etc."sudoers.d/yabai-load-sa".text = ''
    ${username} ALL = (root) NOPASSWD: sha256:${builtins.hashFile "sha256" pkgs.yabai.loadScriptingAddition} ${pkgs.yabai.loadScriptingAddition}
  '';

  launchd.user.agents.yabai-load-sa = {
    path = [ pkgs.yabai config.environment.systemPath ];
    command = "/usr/bin/sudo ${pkgs.yabai.loadScriptingAddition}";
    serviceConfig = {
      RunAtLoad = true;
      KeepAlive.SuccessfulExit = true;
    };
  };

  environment.systemPackages = [ pkgs.yabai-zsh-completions ];
}
