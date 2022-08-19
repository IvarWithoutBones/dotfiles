{ config
, pkgs
, lib
, ...
}:

{
  programs.zsh = {
    enable = true;

    defaultKeymap = "viins";
    history.path = "$HOME/.cache/zsh/history";

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
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
      nixfzf = "${pkgs.nix-search-fzf}/bin/nix-search-fzf";
      ls = "ls --color=auto";
      cat = "${pkgs.bat}/bin/bat -p";
      diff = "diff --color=auto -u";
      dirdiff = "diff --color=auto -ENwbur";
      mp3 = "mpv --no-video";
      weather = "curl -S 'https://wttr.in/?1F'";
      diskusage = "df -ht ext4";
    } // lib.optionalAttrs pkgs.stdenvNoCC.isLinux rec {
      battery-left = "${pkgs.acpi}/bin/acpi | cut -d' ' -f5";
      viewimg = "${pkgs.i3-swallow}/bin/swallow ${pkgs.feh}/bin/feh \"$@\"";
      caps = "${pkgs.xdotool}/bin/xdotool key Caps_Lock";
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

    initExtra = ''
      ${pkgs.lib.optionalString config.programs.direnv.enable ''eval "$(direnv hook zsh)"''}

      # Changes working directory so has to be sourced upon shell init
      source ${pkgs.cd-file}/bin/cd-file

      # Show vim mode on the right side of the prompt
      function zle-line-init zle-keymap-select {
        RPS1="''${''${KEYMAP/vicmd/NORMAL}/(main|viins)/INSERT}"
        RPS2=$RPS1
        zle reset-prompt
      }
      zle -N zle-line-init
      zle -N zle-keymap-select
      export RPS1="" # On Darwin PWD is set by default otherwise

      get-git-root() {
        echo "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)"
      }

      cd-git-root() {
        cd "$(get-git-root)"
      }

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
