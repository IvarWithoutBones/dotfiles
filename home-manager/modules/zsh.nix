{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
  
    defaultKeymap = "viins";
    history.path = "$HOME/.cache/zsh/history";

    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    autocd = true;
  
    localVariables = {
      PS1 = "%F{magenta}%~%f > ";
      LESSHISTFILE = "/dev/null";
    };
  
    shellAliases = rec {
      ls = "ls --color=auto";
      cat = "bat -p";
      diff = "diff --color=auto -u";
      dirdiff = "diff --color=auto -ENwbur";
      speedtest = "printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && ${pkgs.speedtest-cli}/bin/speedtest | grep -E 'Download|Upload'";
      mp3 = "mpv --no-video";
      battery-left = "${pkgs.acpi}/bin/acpi | cut -d' ' -f5";
      viewimg = "${pkgs.i3-swallow}/bin/swallow ${pkgs.feh}/bin/feh \"$@\"";
      caps = "${pkgs.xdotool}/bin/xdotool key Caps_Lock";
      CAPS = caps;
    };
  
    plugins = [ {
      name = "zsh-vi-mode";
      file = "zsh-vi-mode.plugin.zsh";
      src = pkgs.fetchFromGitHub {
        owner = "jeffreytse";
        repo = "zsh-vi-mode";
        rev = "3eeca1bc6db172edee5a2ca13d9ff588b305b455";
        sha256 = "0na6b5b46k4473c53mv1wkb009i6b592gxpjq94bdnlz1kkcqwg6";
      };
    } ];

    initExtra = ''
      ${pkgs.lib.optionalString config.programs.direnv.enable ''eval "$(direnv hook zsh)"''}

      get-git-root() {
        echo "$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null)"
      }

      cd-git-root() {
        cd "$(get-git-root)"
      }

      mkscript() {
        if (( $# > 1 )); then
          echo "error: more than one argument supplied!"
          return
        fi

        touch "$1"
        chmod +x "$1"
        $EDITOR "$1"
      }

      cleanbuild() {
        if [ "''${get-git-root}" ]; then
          cd-git-root
        fi

        rm -rf build
        mkdir build
        cd build
        cmake ..
        make -j
      }

      callPackage() {
        if [ -z "$1" ]; then
          FILE="default.nix"
        else
          FILE="$1"
        fi

        nix-build -E "((import <nixpkgs> {}).callPackage (import $(realpath "$FILE")) { })"
      }

      copy-nix-derivation() {
        if [ -z "$2" ]; then
          FILE="default.nix"
        else
          FILE=$2
        fi
        if [ -f "$FILE" ]; then
          PNAME=$(grep pname $FILE | head -1 | cut -d'"' -f2)
          read ANSWER\?"$FILE exists, which most likely contains a derivation for $PNAME. Do you wish to override? [Y/N] "
          case $ANSWER in
            [yY]* ) echo "Overwriting $FILE...";;
            [nN]* ) return;;
            * )     echo "Not a valid answer, exiting..."; return;;
          esac
        fi
        EDITOR=cat nix edit nixpkgs#$1 > $FILE && nvim $FILE
      }
    '';
  };
}
