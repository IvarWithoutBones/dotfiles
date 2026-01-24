{ config
, pkgs
, lib
, ...
}:

{
  # The theme for the Fast Syntax Highlighting plugin
  xdg.configFile."fsh/catppuccin-mocha.ini".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/zsh-fsh/a9bdf479f8982c4b83b5c5005c8231c6b3352e2a/themes/catppuccin-mocha.ini";
    hash = "sha256-YuiWhbgxlIZRlLBB0ut5ge5KLmnPrqgrBhQ7PUswYU4=";
  };

  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh";
    history.path = "${config.xdg.cacheHome}/zsh/history";
    defaultKeymap = "viins";

    autosuggestion.enable = true;
    autocd = true;
    enableVteIntegration = true;

    plugins = [
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
      }
    ];

    localVariables = {
      # Looks like this: '~/some/path > '
      PS1 = "%F{magenta}%~%f > ";
      # Gets pushed to the home directory otherwise
      LESSHISTFILE = "/dev/null";
      # Make Vi mode transitions faster (in hundredths of a second)
      KEYTIMEOUT = 1;
    };

    shellAliases = {
      ls = "${lib.getExe pkgs.eza} --group-directories-first";
      ls-diskusage = "${lib.getExe pkgs.eza} --all --total-size --sort size --long --no-permissions --no-user --no-time";
      tree = "${lib.getExe pkgs.eza} --tree --icons --follow-symlinks --group-directories-first --git-ignore";
      cat = "${lib.getExe pkgs.bat} --plain";
      diff = "${lib.getExe' pkgs.diffutils "diff"} --color=auto --unified";
      dirdiff = "${lib.getExe' pkgs.diffutils "diff"} --color=auto -ENwbur";
      mp3 = "${lib.getExe pkgs.mpv} --no-video";
      diskusage = "${lib.getExe' pkgs.coreutils "df"} -ht ext4";
      mktar = "${lib.getExe pkgs.gnutar} -czvf";
      nix-locate-bin = "() { ${lib.getExe' pkgs.nix-index "nix-locate"} --type=x --whole-name --at-root \"\${@/#/\"/bin/\"}\" }"; # Prepend `/bin/` to each argument
      github-actions = "${lib.getExe pkgs.act} -s GITHUB_TOKEN=\"$(${lib.getExe pkgs.github-cli} auth token)\"";
      termtitle = "() { printf '\\e]2;%s\\a' \"\$*\"; }"; # Set the terminal window's title
    } // lib.optionalAttrs pkgs.stdenvNoCC.isLinux {
      copy =
        let
          wayland = "${lib.getExe' pkgs.wl-clipboard "wl-copy"} --trim-newline";
          x11 = "${lib.getExe pkgs.xclip} -selection clipboard";
        in
        lib.optionalString (config.xsession.enable || config.wayland.windowManager.sway.enable)
          (if config.wayland.windowManager.sway.enable then
            if config.xsession.enable then
              "() { [[ \${XDG_SESSION_TYPE:-} == 'wayland' ]] && ${wayland} || ${x11} }" # Pick at runtime
            else wayland
          else x11);
    };

    initContent = lib.mkAfter ''
      ${lib.optionalString pkgs.stdenvNoCC.hostPlatform.isDarwin ''
        source ${pkgs.iterm2-shell-integration}/share/zsh/iterm2.zsh
        RPS1="" # Set by default
      ''}

      # Cache completion results
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path "${config.xdg.cacheHome}/zsh/zcompcache"

      # Use the colors from 'ls' in completions
      zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}

      # Set the Fast Syntax Highlighting theme (installed above) and fixes a rendering issue:
      # https://github.com/zdharma-continuum/fast-syntax-highlighting/issues/78
      fast-theme XDG:catppuccin-mocha > /dev/null
      export FAST_HIGHLIGHT[chroma-git]="→chroma/-subcommand.ch"

      # Enter a 'nix shell' with packages selected by fzf
      source ${pkgs.nix-search-fzf.zsh-shell-widget}
      zle -N nix-search-fzf-shell-widget
      bindkey -M viins '^O' nix-search-fzf-shell-widget

      # Changes working directory so has to be sourced upon shell init
      source ${pkgs.cd-file}/bin/cd-file

      # Change the working directory to a git trees root
      pushd-git-root-widget() {
        setopt localoptions pipefail no_aliases 2> /dev/null
        local dir="$(${lib.getExe pkgs.git} rev-parse --show-toplevel 2>/dev/null)"
        if [[ -z "$dir" ]]; then
        	zle redisplay
        	return 0
        fi
        zle push-line
        BUFFER="builtin pushd -- ''${(q)dir}"
        zle accept-line
        local ret=$?
        unset dir
        zle reset-prompt
        return $ret
      }
      zle -N pushd-git-root-widget
      bindkey -M viins '^g' pushd-git-root-widget
    '';
  };
}
