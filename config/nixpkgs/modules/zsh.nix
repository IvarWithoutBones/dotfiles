{ pkgs, ... }: {

programs.zsh = {
  enable = true;

  defaultKeymap = "viins";
  dotDir = ".config/zsh";
  history.path = "${builtins.getEnv "HOME"}/.cache/zsh/history";

  sessionVariables = {
    VISUAL = "nvim";
    EDITOR = "nvim";
    TERMINAL = "st";
    PS1 = "%F{magenta}%~%f > ";
    LESSHISTFILE = "/dev/null";
  };

  shellAliases = {
    ls = "ls --color=auto";
    la = "ls --color=auto -A";
    diff = "diff --color=auto -u";
    dirdiff = "diff --color=auto -ENwbur";
    speedtest = "printf 'Ping: ' && ping google.com -c 1 | grep time= | cut -d'=' -f4 && ${pkgs.speedtest-cli}/bin/speedtest | grep -E 'Download|Upload'";
    mp3 = "mpv --no-video";
    update-system = "${builtins.getEnv "HOME"}/.scripts/update-system.sh";
    dotconfig = "nvim \$(find ${builtins.getEnv "HOME"}/.config/ -type f | ${pkgs.fzf}/bin/fzf -m)";
    battery-left="${pkgs.acpi}/bin/acpi | cut -d' ' -f5";
    caps="${pkgs.xdotool}/bin/xdotool key Caps_Lock";
    build-nixos-package = "nix-build -E '((import <nixpkgs> {}).callPackage (import ./default.nix) { })'";
    build-nixos-package-qt = "nix-build -E '((import <nixpkgs> {}).libsForQt5.callPackage (import ./default.nix) { })'";
    build-nixos-package-py = "nix-build -E '((import <nixpkgs> {}).python3Packages.callPackage (import ./default.nix) { })'";
  };

  plugins = [{
    name = "zsh-syntax-highlighting";
    src = pkgs.zsh-syntax-highlighting;
    file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
  }];

  initExtra = ''
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
      EDITOR=cat nix edit nixpkgs.$1 > $FILE && nvim $FILE
    }

    autoload -U compinit
    zstyle ':completion:*' menu select
    zmodload zsh/complist
    compinit
    bindkey -v
    export KEYTIMEOUT=1

    # Use vim keys in tab complete menu:
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -v '^?' backward-delete-char
    
    # Change cursor shape for different vi modes.
    function zle-keymap-select {
      if [[ $KEYMAP == vicmd ]] ||
         [[ $1 = 'block' ]]; then
        echo -ne '\e[1 q'
      elif [[ $KEYMAP == main ]] ||
           [[ $KEYMAP == viins ]] ||
           [[ $KEYMAP = "" ]] ||
           [[ $1 = 'beam' ]]; then
        echo -ne '\e[5 q'
      fi
    }
    zle -N zle-keymap-select
    zle-line-init() {
        zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
        echo -ne "\e[5 q"
    }
    zle -N zle-line-init
    echo -ne '\e[5 q' # Use beam shape cursor on startup.
    preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

    eval "$(direnv hook zsh)"
  '';
}; }
