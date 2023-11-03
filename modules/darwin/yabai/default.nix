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
      yabai -m rule --add app='System Settings' manage=off
      yabai -m rule --add app='Boot Camp Assistant' manage=off
      yabai -m rule --add app='System Information' manage=off
      yabai -m rule --add app='Ghidra' title!='^CodeBrowser$' manage=off
      yabai -m rule --add app='SwiftBar' manage=off
      yabai -m rule --add app='Widgets Manager' manage=off # From pock
      yabai -m rule --add app="Discord" space=3
    '';
  };

  # The scripting addition needs root access to load, which we want to do automatically when logging in.
  # Disable the password requirement for it so that a service can do so without user interaction.
  environment.etc."sudoers.d/yabai-load-sa".text = ''
    ${username} ALL = (root) NOPASSWD: sha256:${builtins.hashFile "sha256" "${pkgs.yabai}/bin/yabai"} ${pkgs.yabai}/bin/yabai
  '';

  launchd.user.agents.yabai-load-sa = {
    path = [ pkgs.yabai config.environment.systemPath ];
    command = "/usr/bin/sudo ${pkgs.yabai}/bin/yabai --load-sa";
    serviceConfig.RunAtLoad = true;
  };

  environment.systemPackages = [ pkgs.yabai-zsh-completions ];
}
