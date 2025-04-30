{ config
, lib
, pkgs
, ...
}:

{
  programs = {
    fzf = {
      enable = true;
      fileWidgetCommand = "${lib.getExe pkgs.fd} --type f";
      changeDirWidgetCommand = "${lib.getExe pkgs.fd} --type d";

      # Theme taken from: https://github.com/catppuccin/fzf/blob/895df5b036add4cfa0dcfa4d826ad1db79ebc08f/mocha.md
      colors = {
        bg = "#1e1e2e";
        "bg+" = "#313244";
        fg = "#cdd6f4";
        "fg+" = "#cdd6f4";
        hl = "#f38ba8";
        "hl+" = "#f38ba8";
        spinner = "#f5e0dc";
        header = "#f38ba8";
        info = "#cba6f7";
        pointer = "#f5e0dc";
        marker = "#f5e0dc";
        prompt = "#cba6f7";
      };
    };

    zsh.initContent = ''
      # The default fzf cd keybinding is alt+c, but that is already used by my terminal
      bindkey -M viins '^x' fzf-cd-widget
    '';
  };
}
