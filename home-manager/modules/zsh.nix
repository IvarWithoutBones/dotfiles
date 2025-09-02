{ config
, pkgs
, lib
, ...
}:

{
  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    history.path = "${config.xdg.cacheHome}/zsh/history";

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;

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
    } // lib.optionalAttrs pkgs.stdenvNoCC.isLinux rec {
      copy = "${lib.getExe pkgs.xclip} -selection clipboard";
      battery-left = "${lib.getExe pkgs.acpi} | cut -d' ' -f5";
      open = "${pkgs.xdg-utils}/bin/xdg-open";
      caps = "${lib.getExe pkgs.xdotool} key Caps_Lock";
      CAPS = caps;
    };

    plugins = [{
      name = "zsh-vi-mode";
      file = "zsh-vi-mode.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "jeffreytse";
        repo = "zsh-vi-mode";
        rev = "3eeca1bc6db172edee5a2ca13d9ff588b305b455";
        sha256 = "0na6b5b46k4473c53mv1wkb009i6b592gxpjq94bdnlz1kkcqwg6";
      };
    }];

    initContent = ''
      ${lib.optionalString pkgs.stdenvNoCC.hostPlatform.isDarwin ''
        source ${pkgs.iterm2-shell-integration}/share/zsh/iterm2.zsh
        RPS1="" # Set by default
      ''}

      # Enter a 'nix shell' with packages selected by fzf
      source ${pkgs.nix-search-fzf.zsh-shell-widget}
      zle -N nix-search-fzf-shell-widget
      bindkey -M viins '^O' nix-search-fzf-shell-widget

      # Changes working directory so has to be sourced upon shell init
      source ${pkgs.cd-file}/bin/cd-file

      get-git-root() {
        echo "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)"
      }

      cd-git-root() {
        pushd "$(get-git-root)"
      }

      # Change the working directory to a git trees root
      pushd-git-root-widget() {
        setopt localoptions pipefail no_aliases 2> /dev/null
        local dir="$(eval "get-git-root")"
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

      find-in-store() {
        STORE_PATHS="$(find /nix/store -maxdepth 1 -name "*$1*" -not -name "*.drv")"

        if [[ -z "''${STORE_PATHS}" ]]; then
          echo "error: no results found!"
          return
        fi

        STORE_PATH="$(echo "''${STORE_PATHS}" | ${pkgs.fzf}/bin/fzf --preview 'tree {}')"

        if [[ -d "''${STORE_PATH}" ]]; then
          pushd "''${STORE_PATH}"
        else
          echo "''${STORE_PATH}"
        fi
      }
    '';
  };
}
