{
  createScript,
  replaceVars,
  gnused,
  jq,
  fzf,
  nix,
  coreutils,
  bash,
  nix-search-fzf,
  writeShellScript,
}:

let
  previewText = createScript "fzf-preview" ./fzf-preview.sh { };
  src = replaceVars ./nix-search-fzf.sh {
    previewText = "${previewText}/bin/fzf-preview";
  };
in
createScript "nix-search-fzf" src {
  dependencies = [
    gnused
    jq
    fzf
    nix
    coreutils
    bash
  ];

  # Enter a 'nix shell' with packages selected by this script
  passthru.zsh-shell-widget = writeShellScript "nix-search-fzf-shell-widget" ''
    nix-search-fzf-shell-widget() {
      setopt localoptions pipefail no_aliases 2> /dev/null
      local cmd="$(eval "${nix-search-fzf}/bin/nix-search-fzf -c")"
      if [[ -z "$cmd" ]]; then
      	zle redisplay
      	return 0
      fi
      zle push-line
      BUFFER="''${cmd}"
      zle accept-line
      local ret=$?
      unset cmd
      zle reset-prompt
      return $ret
    }
  '';

  meta.description = "a wrapper around 'nix {run,shell,edit}' with autocomplete using fzf";
}
