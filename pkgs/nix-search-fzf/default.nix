{ createScript
, gnused
, jq
, fzf
, nix
, coreutils
, bash
}:

createScript "nix-search-fzf" ./nix-search-fzf.sh {
  dependencies = [
    gnused
    jq
    fzf
    nix
    coreutils
    bash
  ];

  meta.description = "a wrapper around 'nix {run,shell,edit}' with autocomplete using fzf";
}
