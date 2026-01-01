final: prev:
let
  pkgs = final;
in
with pkgs; {
  cat-command = callPackage ./cat-command { };

  cd-file = callPackage ./cd-file { };

  copy-nix-derivation = callPackage ./copy-nix-derivation { };

  createScript = callPackage ./createScript { };

  discord-with-openasar = callPackage ./discord-with-openasar {
    inherit (nodePackages) asar;
  };

  dotfiles-tool = callPackage ./dotfiles-tool { };

  dmenu-configured = callPackage ./dmenu-configured { };

  git-add-fuzzy = callPackage ./git-add-fuzzy { };

  git-checkout-fuzzy = callPackage ./git-checkout-fuzzy { };

  git-submodule-reset = callPackage ./git-submodule-reset { };

  iterm2-shell-integration = callPackage ./iterm2-shell-integration { };

  loenn = callPackage ./loenn { };

  mkscript = callPackage ./mkscript { };

  nix-search-fzf = callPackage ./nix-search-fzf { };

  probe-rs-udev-rules = callPackage ./probe-rs-udev-rules { };

  proton-ge-runner = callPackage ./proton-ge-runner { };

  qutebrowser-scripts = lib.recurseIntoAttrs (callPackage ./qutebrowser/scripts { });

  read-macos-alias = callPackage ./read-macos-alias { };

  transcode-video = callPackage ./transcode-video { };

  yabai-zsh-completions = callPackage ./yabai-zsh-completions { };
}
