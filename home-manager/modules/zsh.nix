{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
  
    defaultKeymap = "viins";
    history.path = "$HOME/.cache/zsh/history";
  
    sessionVariables = {
      PS1 = "%F{magenta}%~%f > ";
      LESSHISTFILE = "/dev/null";
    };
  
    shellAliases = rec {
      ls = "ls --color=auto";
      cat = "bat -p";
      grep = "${pkgs.ripgrep}/bin/rg -p --with-filename";
      diff = "diff --color=auto -u";
      dirdiff = "diff --color=auto -ENwbur";
      speedtest = "printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && ${pkgs.speedtest-cli}/bin/speedtest | grep -E 'Download|Upload'";
      mp3 = "mpv --no-video";
      battery-left = "${pkgs.acpi}/bin/acpi | cut -d' ' -f5";
      caps = "${pkgs.xdotool}/bin/xdotool key Caps_Lock";
      CAPS = caps;
    };
  
    plugins = [ {
      name = "zsh-syntax-highlighting";
      src = pkgs.zsh-syntax-highlighting;
       file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
     } {
      # TODO: upstream this
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
