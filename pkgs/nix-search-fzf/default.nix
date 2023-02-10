{ createScript
, substituteAll
, gnused
, jq
, fzf
, nix
, coreutils
, bash
}:

let
  previewText = createScript "fzf-preview" ./fzf-preview.sh { };
  src = substituteAll {
    src = ./nix-search-fzf.sh;
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

  meta.description = "a wrapper around 'nix {run,shell,edit}' with autocomplete using fzf";
}
