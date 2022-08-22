{ config
, pkgs
, ...
}:

{
  programs = {
    fzf = {
      enable = true;
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f";
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d";
    };

    zsh.initExtra = ''
      # The default fzf cd keybinding is alt+c, but thats already used by my terminal
      bindkey -M viins '^x' fzf-cd-widget

      # `programs.zsh.defaultOptions` doesn't work, it sets `home.sessionVariables` which for some reason isnt respected by zsh
      # Theme taken from https://github.com/catppuccin/fzf/blob/895df5b036add4cfa0dcfa4d826ad1db79ebc08f/mocha.md
      export FZF_DEFAULT_OPTS=" \
          --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
          --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
          --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
    '';
  };
}
