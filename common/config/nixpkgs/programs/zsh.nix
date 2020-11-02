globalConfig: let
  pkgs = globalConfig.pkgs;
in
{
  enable = true;

  defaultKeymap = "viins";
  dotDir = ".config/zsh";
  history.path = "${globalConfig.homeDir}/.cache/zsh/history";

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
    watch = "watch -n0 -c";
    killdiscord = "pkill Discord && pkill Discord"; # For some reason you need to kill it twice?
    update-system = "${globalConfig.homeDir}/.scripts/update-system.sh";
    dotconfig = "nvim \$(find ${globalConfig.homeDir}/.config/ -type f | ${pkgs.fzf}/bin/fzf -m)";
    sm64 = "cd ${globalConfig.homeDir}/misc/sm64/ && ./sm64 --skip-intro && cd ~";
    battery-left="${pkgs.acpi}/bin/acpi | cut -d' ' -f5";
    caps="${pkgs.xdotool}/bin/xdotool key Caps_Lock";
    build-nixos-package = "nix-build -E '((import <nixpkgs> {}).callPackage (import ./default.nix) { })'";
    build-nixos-package-qt = "nix-build -E '((import <nixpkgs> {}).libsForQt5.callPackage (import ./default.nix) { })'";
    build-nixos-package-py = "nix-build -E '((import <nixpkgs> {}).python3Packages.callPackage (import ./default.nix) { })'";
  };

  plugins = [{
    name = "zsh-syntax-highlighting";
    src = pkgs.fetchFromGitHub {
      owner = "zsh-users";
      repo = "zsh-syntax-highlighting";
      rev = "0.7.1";
      sha256 = "03r6hpb5fy4yaakqm3lbf4xcvd408r44jgpv4lnzl9asp4sb9qc0";
    };
  }];

  initExtra = ''
    copy-nix-derivation() {
      if [ -z "$2" ]; then
        EDITOR=cat nix edit nixpkgs.$1 > default.nix && nvim default.nix
      else
        EDITOR=cat nix edit nixpkgs.$1 > $2 && nvim $2
      fi
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
}
